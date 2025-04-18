
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Service for making API requests
class ApiService {
  final http.Client _client;
  final AppConfig _config;
  
  /// Constructor
  ApiService({
    http.Client? client,
    required AppConfig config,
  }) : _client = client ?? http.Client(),
       _config = config;
  
  /// The base URL for API requests
  String get baseUrl => _config.apiUrl;
  
  /// Makes a GET request
  ///
  /// [endpoint] - The API endpoint
  /// [headers] - Optional headers to include in the request
  /// [queryParameters] - Optional query parameters
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: queryParameters,
      );
      
      final response = await _client.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('GET request error: $e');
      rethrow;
    }
  }
  
  /// Makes a POST request
  ///
  /// [endpoint] - The API endpoint
  /// [body] - The request body
  /// [headers] - Optional headers to include in the request
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final jsonBody = body != null ? jsonEncode(body) : null;
      final requestHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };
      
      final response = await _client.post(
        url,
        body: jsonBody,
        headers: requestHeaders,
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('POST request error: $e');
      rethrow;
    }
  }
  
  /// Makes a PUT request
  ///
  /// [endpoint] - The API endpoint
  /// [body] - The request body
  /// [headers] - Optional headers to include in the request
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final jsonBody = body != null ? jsonEncode(body) : null;
      final requestHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };
      
      final response = await _client.put(
        url,
        body: jsonBody,
        headers: requestHeaders,
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('PUT request error: $e');
      rethrow;
    }
  }
  
  /// Makes a PATCH request
  ///
  /// [endpoint] - The API endpoint
  /// [body] - The request body
  /// [headers] - Optional headers to include in the request
  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final jsonBody = body != null ? jsonEncode(body) : null;
      final requestHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };
      
      final response = await _client.patch(
        url,
        body: jsonBody,
        headers: requestHeaders,
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('PATCH request error: $e');
      rethrow;
    }
  }
  
  /// Makes a DELETE request
  ///
  /// [endpoint] - The API endpoint
  /// [headers] - Optional headers to include in the request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      
      final response = await _client.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('DELETE request error: $e');
      rethrow;
    }
  }
  
  /// Handles the HTTP response
  ///
  /// [response] - The HTTP response
  /// Throws an exception if the response status code is not successful
  dynamic _handleResponse(http.Response response) {
    debugPrint('Response status code: ${response.statusCode}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body;
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _getErrorMessage(response),
      );
    }
  }
  
  /// Gets the error message from the response
  ///
  /// [response] - The HTTP response
  String _getErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? body['error'] ?? 'An error occurred';
    } catch (e) {
      return response.reasonPhrase ?? 'An error occurred';
    }
  }
  
  /// Disposes of the HTTP client
  void dispose() {
    _client.close();
  }
}

/// Exception thrown when an API request fails
class ApiException implements Exception {
  /// The HTTP status code
  final int statusCode;
  
  /// The error message
  final String message;
  
  /// Constructor
  ApiException({
    required this.statusCode,
    required this.message,
  });
  
  @override
  String toString() => 'ApiException: $statusCode - $message';
}
