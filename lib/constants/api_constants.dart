/// API base URL and endpoint paths.
abstract final class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://fakestoreapi.com';

  /// Auth login (POST).
  static const String auth = '/auth/login';

  /// GET all products.
  static const String products = '/products';

  /// Full URL for auth login.
  static String get authLoginUrl => '$baseUrl$auth';

  /// Full URL for products list.
  static String get productsUrl => '$baseUrl$products';
}
