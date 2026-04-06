import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constatnts/app_constatns.dart';

class ApiClient {
  final http.Client client;

  ApiClient({required this.client});

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await client.get(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: headers ?? _defaultHeaders,
      ).timeout(const Duration(seconds: AppConstants.timeout));
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: headers ?? _defaultHeaders,
        body: json.encode(body),
      ).timeout(const Duration(seconds: AppConstants.timeout));
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    try {
      final response = await client.put(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: headers ?? _defaultHeaders,
        body: json.encode(body),
      ).timeout(const Duration(seconds: AppConstants.timeout));
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await client.delete(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: headers ?? _defaultHeaders,
      ).timeout(const Duration(seconds: AppConstants.timeout));
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return json.decode(response.body);
      case 400:
        throw Exception('Bad Request');
      case 401:
        throw Exception('Unauthorized');
      case 403:
        throw Exception('Forbidden');
      case 404:
        throw Exception('Not Found');
      case 500:
        throw Exception('Internal Server Error');
      default:
        throw Exception('Error: ${response.statusCode}');
    }
  }

  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AppConstants.apiKey}',
  };
}