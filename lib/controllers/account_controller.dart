import 'package:flutter/foundation.dart';

/// Controller for the Account screen (login form state).
/// API connection will be added later.
class AccountController extends ChangeNotifier {
  String _email = '';
  String get email => _email;
  set email(String value) {
    if (_email == value) return;
    _email = value;
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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> submitLogin() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    // TODO: connect to API
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !_obscurePassword;
  }
}
