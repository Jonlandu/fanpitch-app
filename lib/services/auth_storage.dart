import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _kAccess = 'fanpitch_access';
  static const _kRefresh = 'fanpitch_refresh';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> writeTokens(String access, String refresh) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
  }

  Future<String?> readAccess() => _storage.read(key: _kAccess);
  Future<String?> readRefresh() => _storage.read(key: _kRefresh);

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}

final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());
