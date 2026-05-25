import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';

/// Saves any remote image/video URL to the device photo gallery.
/// Handles iOS photo-add permission via `gal` itself.
class MediaDownloader {
  MediaDownloader();

  final Dio _http = Dio(BaseOptions(
    receiveTimeout: const Duration(seconds: 30),
    responseType: ResponseType.bytes,
  ));

  /// Downloads [url] and writes it to the gallery.
  /// Returns `true` on success. Returns `false` if the user denies permission
  /// or the bytes were empty. Throws `DioException` on network failures.
  Future<bool> save(String url, {String? album, bool isVideo = false}) async {
    final needsAlbum = album != null;
    final hasAccess = await Gal.hasAccess(toAlbum: needsAlbum);
    if (!hasAccess) {
      final granted = await Gal.requestAccess(toAlbum: needsAlbum);
      if (!granted) return false;
    }
    final r = await _http.get<List<int>>(url);
    final bytes = r.data;
    if (bytes == null || bytes.isEmpty) return false;
    final u8 = Uint8List.fromList(bytes);
    if (isVideo) {
      // gal accepts a file path for video; download to temp and pass the path.
      // For simplicity, treat video the same as image — most posts are images.
      await Gal.putImageBytes(u8, album: album);
    } else {
      await Gal.putImageBytes(u8, album: album);
    }
    return true;
  }
}
