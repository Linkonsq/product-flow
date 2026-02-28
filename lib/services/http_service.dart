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

  Future<String> post(String url, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
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

  Future<String> login(String username, String password) async {
    final body = await post(ApiConstants.authLoginUrl, <String, String>{
      'username': username,
      'password': password,
    });
    final map = json.decode(body) as Map<String, dynamic>;
    final token = map['token'] as String?;
    if (token == null || token.isEmpty) {
      throw HttpServiceException(statusCode: 200, body: body);
    }
    return token;
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
