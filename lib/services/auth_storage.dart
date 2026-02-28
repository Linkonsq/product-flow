import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Key used to store the auth token in secure storage.
const String _tokenKey = 'auth_token';

/// Persists and retrieves auth token using [FlutterSecureStorage].
/// Falls back to in-memory storage when the plugin is unavailable
/// (e.g. on Windows/Web or before native code is registered).
class AuthStorage {
  AuthStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  /// In-memory fallback when secure storage throws [MissingPluginException].
  String? _memoryToken;

  bool _useFallback = false;

  /// Reads the stored token. Returns null if none.
  Future<String?> getToken() async {
    if (_useFallback) return _memoryToken;
    try {
      return await _storage.read(key: _tokenKey);
    } on MissingPluginException catch (_) {
      _useFallback = true;
      if (kDebugMode) {
        debugPrint(
          'AuthStorage: flutter_secure_storage not available, using in-memory fallback. '
          'Token will not persist on this platform. Run on Android/iOS for full support.',
        );
      }
      return _memoryToken;
    } on PlatformException catch (e) {
      if (e.code == 'No implementation found' || e.message?.contains('write') == true) {
        _useFallback = true;
        return _memoryToken;
      }
      rethrow;
    }
  }

  /// Saves the token.
  Future<void> saveToken(String token) async {
    if (_useFallback) {
      _memoryToken = token;
      return;
    }
    try {
      await _storage.write(key: _tokenKey, value: token);
    } on MissingPluginException catch (_) {
      _useFallback = true;
      _memoryToken = token;
    } on PlatformException catch (e) {
      if (e.code == 'No implementation found' || e.message?.contains('write') == true) {
        _useFallback = true;
        _memoryToken = token;
        return;
      }
      rethrow;
    }
  }

  /// Removes the token.
  Future<void> deleteToken() async {
    if (_useFallback) {
      _memoryToken = null;
      return;
    }
    try {
      await _storage.delete(key: _tokenKey);
    } on MissingPluginException catch (_) {
      _useFallback = true;
      _memoryToken = null;
    } on PlatformException catch (e) {
      if (e.code == 'No implementation found' || e.message?.contains('write') == true) {
        _useFallback = true;
        _memoryToken = null;
        return;
      }
      rethrow;
    }
  }
}
