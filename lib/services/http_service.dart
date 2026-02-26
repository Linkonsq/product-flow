import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/product.dart';

class HttpService {
  HttpService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> get(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }
    throw HttpServiceException(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  /// Fetches all products from Fake Store API.
  Future<List<Product>> getProducts() async {
    final body = await get(ApiConstants.productsUrl);
    final list = json.decode(body) as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Thrown when an HTTP request fails
class HttpServiceException implements Exception {
  HttpServiceException({required this.statusCode, this.body});

  final int statusCode;
  final String? body;

  @override
  String toString() => 'HttpServiceException: $statusCode ${body ?? ""}';
}
