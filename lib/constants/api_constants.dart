/// API base URL and endpoint paths.
abstract final class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://fakestoreapi.com';

  /// GET all products.
  static const String products = '/products';

  /// Full URL for products list.
  static String get productsUrl => '$baseUrl$products';
}
