import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../services/auth_storage.dart';
import '../services/http_service.dart';

/// Controller for the Account screen (login form and auth state).
class AccountController extends ChangeNotifier {
  AccountController({
    HttpService? httpService,
    AuthStorage? authStorage,
  })  : _httpService = httpService ?? HttpService(),
        _authStorage = authStorage ?? AuthStorage();

  final HttpService _httpService;
  final AuthStorage _authStorage;

  String _username = '';
  String get username => _username;
  set username(String value) {
    if (_username == value) return;
    _username = value;
    notifyListeners();
  }

  String _password = '';
  String get password => _password;
  set password(String value) {
    if (_password == value) return;
    _password = value;
    notifyListeners();
  }

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;
  set obscurePassword(bool value) {
    if (_obscurePassword == value) return;
    _obscurePassword = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCheckingAuth = true;
  bool get isCheckingAuth => _isCheckingAuth;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Call on Account screen init to restore session from secure storage.
  Future<void> loadToken() async {
    _isCheckingAuth = true;
    notifyListeners();
    try {
      final token = await _authStorage.getToken();
      _isLoggedIn = token != null && token.isNotEmpty;
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
    }
  }

  Future<void> submitLogin() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _httpService.login(_username.trim(), _password);
      await _authStorage.saveToken(token);
      _isLoggedIn = true;
      notifyListeners();
    } on HttpServiceException catch (e) {
      _errorMessage = _messageFromException(e);
      notifyListeners();
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authStorage.deleteToken();
    _isLoggedIn = false;
    _username = '';
    _password = '';
    _errorMessage = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !_obscurePassword;
  }

  static String _messageFromException(HttpServiceException e) {
    if (e.statusCode == 401) return 'Invalid username or password';
    if (e.body != null && e.body!.isNotEmpty) {
      try {
        final map = _parseJson(e.body!);
        final msg = map['message'] ?? map['error'] ?? map['msg'];
        if (msg != null) return msg.toString();
      } catch (_) {}
    }
    return 'Login failed (${e.statusCode})';
  }

  static Map<String, dynamic> _parseJson(String source) {
    try {
      final decoded = json.decode(source);
      return decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}