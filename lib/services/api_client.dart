import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/match.dart';
import '../models/match_event.dart';
import '../models/poll.dart';
import '../models/prediction.dart';
import '../models/status_post.dart';
import '../models/user.dart';
import '../utils/config.dart';
import 'auth_storage.dart';

class ApiClient {
  ApiClient(this._storage) {
    _dio.options.baseUrl = '${AppConfig.apiBase}/api/v1';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 20);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final t = await _storage.readAccess();
          if (t != null) options.headers['Authorization'] = 'Bearer $t';
          handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            final refreshed = await _tryRefresh();
            if (refreshed) {
              // Le token a été mis à jour, on doit réinjecter le NOUVEAU token
              // dans les headers de la requête clonée avant de la rejouer !
              final newAccess = await _storage.readAccess();
              final options = e.requestOptions;
              if (newAccess != null) {
                options.headers['Authorization'] = 'Bearer $newAccess';
              }

              final clone = await _dio.fetch(options);
              return handler.resolve(clone);
            } else {
              // Refresh failed — clear in-memory auth state so the router
              // sends the user back to /login instead of leaving them on a
              // half-broken page with stale state.
              onSessionExpired?.call();
              return handler.reject(
                DioException(
                  requestOptions: e.requestOptions,
                  error: 'Session expired, please reconnect.',
                  type: DioExceptionType.badResponse,
                  response: e.response,
                ),
              );
            }
          }
          handler.next(e);
        },
      ),
    );
  }

  final AuthStorage _storage;
  final Dio _dio = Dio();

  /// Optional callback fired when the refresh token also fails. The auth
  /// provider wires this to `authProvider.notifier.logout()` so the router
  /// transitions cleanly to /login instead of letting the UI sit on a
  /// half-broken feed page.
  void Function()? onSessionExpired;

  Future<bool> _tryRefresh() async {
    final r = await _storage.readRefresh();
    if (r == null) return false;
    try {
      final resp = await Dio().post(
        '${AppConfig.apiBase}/api/v1/auth/refresh/',
        data: {'refresh': r},
      );
      final access = resp.data['access'] as String;
      final newRefresh = (resp.data['refresh'] ?? r) as String;
      await _storage.writeTokens(access, newRefresh);
      return true;
    } catch (_) {
      await _storage.clear();
      return false;
    }
  }

  // --- auth ---

  Future<({AuthTokens tokens, AppUser user})> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
    String? country,
  }) async {
    final r = await _dio.post(
      '/auth/register/',
      data: {
        'username': username,
        'email': email,
        'password': password,
        'display_name': displayName ?? username,
        if (country != null && country.isNotEmpty) 'country': country,
      },
    );
    final tokens = AuthTokens.fromJson(r.data as Map<String, dynamic>);
    final user = AppUser.fromJson((r.data['user'] as Map<String, dynamic>));
    return (tokens: tokens, user: user);
  }

  Future<AuthTokens> login(String username, String password) async {
    final r = await _dio.post(
      '/auth/login/',
      data: {'username': username, 'password': password},
    );
    return AuthTokens.fromJson(r.data as Map<String, dynamic>);
  }

  Future<AppUser> getMe() async {
    final r = await _dio.get('/auth/me/');
    return AppUser.fromJson(r.data as Map<String, dynamic>);
  }

  /// Public profile of any user (with is_me + is_following).
  Future<AppUser> getUser(int userId) async {
    final r = await _dio.get('/auth/users/$userId/');
    return AppUser.fromJson(r.data as Map<String, dynamic>);
  }

  /// All public statuses (non-expired) authored by [userId], paginated.
  Future<({List<StatusPost> items, int total, bool hasMore})> getUserStatuses(
    int userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final r = await _dio.get(
      '/users/$userId/statuses/',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final results = (r.data['results'] as List? ?? const []);
    return (
      items: results
          .map((e) => StatusPost.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (r.data['count'] ?? 0) as int,
      hasMore: (r.data['has_more'] ?? false) as bool,
    );
  }

  Future<void> follow(int userId) async {
    await _dio.post('/auth/users/$userId/follow/');
  }

  Future<void> unfollow(int userId) async {
    await _dio.delete('/auth/users/$userId/follow/');
  }

  // --- matches ---

  Future<List<Match>> listMatches({String? status}) async {
    final r = await _dio.get(
      '/matches/',
      queryParameters: {if (status != null) 'status': status},
    );
    final results = (r.data is List)
        ? r.data as List
        : (r.data['results'] as List? ?? const []);
    return results
        .map((e) => Match.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Match> getMatch(int id) async {
    final r = await _dio.get('/matches/$id/');
    return Match.fromJson(r.data as Map<String, dynamic>);
  }

  Future<List<MatchEvent>> getMatchEvents(int id, {int? since}) async {
    final r = await _dio.get(
      '/matches/$id/events/',
      queryParameters: {if (since != null) 'since': since},
    );
    return (r.data as List)
        .map((e) => MatchEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --- feed ---

  Future<List<StatusPost>> listStatuses() async {
    final r = await _dio.get('/statuses/');
    final results = (r.data is List)
        ? r.data as List
        : (r.data['results'] as List? ?? const []);
    return results
        .map((e) => StatusPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// TikTok-style "for you" — ranked by engagement × recency × personalisation.
  Future<List<StatusPost>> forYouFeed({int limit = 20, int offset = 0}) async {
    final r = await _dio.get(
      '/feed/for-you/',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final results = (r.data['results'] as List? ?? const []);
    return results
        .map((e) => StatusPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Strict "following" feed — only authors the user follows + self.
  Future<List<StatusPost>> followingFeed({
    int limit = 20,
    int offset = 0,
  }) async {
    final r = await _dio.get(
      '/feed/following/',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final results = (r.data['results'] as List? ?? const []);
    return results
        .map((e) => StatusPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Bulk impression report — call every 5-10s with up to 50 ids.
  Future<void> reportImpressions(
    List<int> statusIds, {
    List<int>? dwellMs,
  }) async {
    if (statusIds.isEmpty) return;
    await _dio.post(
      '/impressions/',
      data: {'status_ids': statusIds, if (dwellMs != null) 'dwell_ms': dwellMs},
    );
  }

  /// Toggle a reaction emoji on a Status (or any target). Idempotent.
  Future<void> toggleReaction({
    required String targetType,
    required int targetId,
    required String emoji,
    required bool currentlyOn,
  }) async {
    if (currentlyOn) {
      // Backend exposes only POST on /reactions/ — find + delete via filter
      final list = await _dio.get(
        '/reactions/',
        queryParameters: {'target_type': targetType, 'target_id': targetId},
      );
      final results = (list.data is List)
          ? list.data as List
          : (list.data['results'] as List? ?? const []);
      for (final e in results) {
        final m = e as Map<String, dynamic>;
        if (m['emoji'] == emoji) {
          await _dio.delete('/reactions/${m['id']}/');
          break;
        }
      }
    } else {
      await _dio.post(
        '/reactions/',
        data: {
          'target_type': targetType,
          'target_id': targetId,
          'emoji': emoji,
        },
      );
    }
  }

  Future<List<Map<String, dynamic>>> listComments({
    required String targetType,
    required int targetId,
  }) async {
    final r = await _dio.get(
      '/comments/',
      queryParameters: {'target_type': targetType, 'target_id': targetId},
    );
    final results = (r.data is List)
        ? r.data as List
        : (r.data['results'] as List? ?? const []);
    return results.cast<Map<String, dynamic>>();
  }

  Future<void> postComment({
    required String targetType,
    required int targetId,
    required String body,
  }) async {
    await _dio.post(
      '/comments/',
      data: {'target_type': targetType, 'target_id': targetId, 'body': body},
    );
  }

  Future<StatusPost> createStatus({
    required String bodyText,
    int? mediaId,
    int? teamId,
  }) async {
    final r = await _dio.post(
      '/statuses/',
      data: {
        'body_text': bodyText,
        if (mediaId != null) 'media_id': mediaId,
        if (teamId != null) 'team': teamId,
      },
    );
    return StatusPost.fromJson(r.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> presignUpload({
    required String filename,
    required String contentType,
  }) async {
    final r = await _dio.post(
      '/media/upload-url/',
      data: {'filename': filename, 'content_type': contentType},
    );
    return r.data as Map<String, dynamic>;
  }

  /// Push the file bytes to the destination indicated by [presigned].
  /// Handles both `s3` (HTTP PUT, no auth header) and `local` (multipart POST
  /// through the Django app, JWT carried by our interceptor).
  Future<void> uploadFileTo({
    required Map<String, dynamic> presigned,
    required List<int> bytes,
    required String contentType,
    required String filename,
  }) async {
    final backend = (presigned['backend'] ?? 's3') as String;
    final url = presigned['url'] as String;
    if (backend == 's3') {
      await Dio().put<void>(
        url,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': bytes.length,
          },
        ),
      );
    } else {
      final form = FormData.fromMap({
        (presigned['field'] ?? 'file') as String: MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: DioMediaType.parse(contentType),
        ),
      });
      // Use our auth-bearing dio so the JWT travels with the upload.
      final pathOnly = url.startsWith('http')
          ? url.substring(url.indexOf('/api/v1') + '/api/v1'.length)
          : url;
      await _dio.post<void>(pathOnly, data: form);
    }
  }

  /// One-shot: presign → upload bytes → register MediaPost. Returns the post.
  Future<MediaPost> uploadAndRegisterMedia({
    required List<int> bytes,
    required String filename,
    required String contentType,
    String? aiCaption,
  }) async {
    final presigned = await presignUpload(
      filename: filename,
      contentType: contentType,
    );
    await uploadFileTo(
      presigned: presigned,
      bytes: bytes,
      contentType: contentType,
      filename: filename,
    );
    return registerMediaPost(
      s3Key: presigned['key'] as String,
      mediaType: contentType.startsWith('video/') ? 'VIDEO' : 'IMAGE',
      aiCaption: aiCaption,
      cdnUrl: presigned['cdn_url'] as String?,
    );
  }

  Future<MediaPost> registerMediaPost({
    required String s3Key,
    required String mediaType,
    String? aiCaption,
    String? cdnUrl,
  }) async {
    final r = await _dio.post(
      '/media/',
      data: {
        's3_key': s3Key,
        'media_type': mediaType,
        if (aiCaption != null) 'ai_caption': aiCaption,
        if (cdnUrl != null) 'cdn_url': cdnUrl,
      },
    );
    return MediaPost.fromJson(r.data as Map<String, dynamic>);
  }

  // --- predictions / polls / reactions ---

  Future<Prediction> submitPrediction({
    required int matchId,
    required int home,
    required int away,
  }) async {
    final r = await _dio.post(
      '/predictions/',
      data: {'match': matchId, 'home_score': home, 'away_score': away},
    );
    return Prediction.fromJson(r.data as Map<String, dynamic>);
  }

  Future<List<Prediction>> myPredictions() async {
    final r = await _dio.get('/predictions/me/');
    return (r.data as List)
        .map((e) => Prediction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Poll>> polls({int? matchId}) async {
    final r = await _dio.get(
      '/polls/',
      queryParameters: {if (matchId != null) 'match_id': matchId},
    );
    final results = (r.data is List)
        ? r.data as List
        : (r.data['results'] as List? ?? const []);
    return results
        .map((e) => Poll.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Poll> votePoll(int pollId, int optionIndex) async {
    final r = await _dio.post(
      '/polls/$pollId/vote/',
      data: {'option_index': optionIndex},
    );
    return Poll.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> sendReaction({
    required String targetType,
    required int targetId,
    required String emoji,
  }) async {
    await _dio.post(
      '/reactions/',
      data: {'target_type': targetType, 'target_id': targetId, 'emoji': emoji},
    );
  }

  // --- gamification ---

  Future<Map<String, dynamic>> leaderboard({
    String scope = 'global',
    int? matchId,
  }) async {
    final r = await _dio.get(
      '/leaderboard/',
      queryParameters: {
        'scope': scope,
        if (matchId != null) 'match_id': matchId,
      },
    );
    return r.data as Map<String, dynamic>;
  }

  // --- ai ---

  Future<Map<String, dynamic>> aiCaption({
    int? matchId,
    String? summary,
    String? lang,
    String? brief,
  }) async {
    final r = await _dio.post(
      '/ai/caption/',
      data: {
        if (matchId != null) 'match_id': matchId,
        if (summary != null) 'summary': summary,
        if (lang != null) 'lang': lang,
        if (brief != null && brief.isNotEmpty) 'brief': brief,
      },
    );
    return r.data as Map<String, dynamic>;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(authStorageProvider));
});
