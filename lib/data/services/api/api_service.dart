import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

/// Centralized HTTP API Service
class ApiService {
  ApiService._();

  static final _storage = GetStorage();
  static const String _tokenKey = 'AUTH_TOKEN';

  /// Get stored auth token
  static String? get authToken => _storage.read(_tokenKey);

  /// Save auth token
  static Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);
  }

  /// Clear auth token
  static Future<void> clearToken() async {
    await _storage.remove(_tokenKey);
  }

  /// Common headers
  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = authToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// POST request
  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      debugPrint('📡 POST: $url');
      debugPrint('📦 Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      );

      debugPrint('📬 Status: ${response.statusCode}');
      debugPrint('📬 Response: ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw data['message'] ??
            data['error'] ??
            'Request failed with status ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('❌ API Error: $e');
      rethrow;
    }
  }

  /// GET request
  static Future<Map<String, dynamic>> get(String url) async {
    try {
      debugPrint('📡 GET: $url');

      final response = await http.get(Uri.parse(url), headers: _headers);

      debugPrint('📬 Status: ${response.statusCode}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ??
            data['error'] ??
            'Request failed with status ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('❌ API Error: $e');
      rethrow;
    }
  }

  /// PUT request
  static Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      debugPrint('📡 PUT: $url');
      debugPrint('📦 Body: ${jsonEncode(body)}');

      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      );

      debugPrint('📬 Status: ${response.statusCode}');
      debugPrint('📬 Response: ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw data['message'] ??
            data['error'] ??
            'Request failed with status ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('❌ API Error: $e');
      rethrow;
    }
  }

  /// DELETE request
  static Future<Map<String, dynamic>> delete(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      debugPrint('📡 DELETE: $url');
      debugPrint('📦 Body: ${jsonEncode(body)}');

      final request = http.Request('DELETE', Uri.parse(url));
      request.headers.addAll(_headers);
      request.body = jsonEncode(body);

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📬 Status: ${response.statusCode}');
      _logResponse(response);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ??
            data['error'] ??
            'Request failed with status ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('❌ API Error: $e');
      rethrow;
    }
  }

  /// Multipart POST request
  static Future<Map<String, dynamic>> multipartPost({
    required String url,
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
  }) async {
    try {
      debugPrint('📡 MULTIPART: $url');
      debugPrint('📦 Fields: $fields');

      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add Headers
      final token = authToken;
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Add Fields
      request.fields.addAll(fields);

      // Add Files
      request.files.addAll(files);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📬 Status: ${response.statusCode}');
      _logResponse(response);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw data['message'] ??
            data['error'] ??
            'Request failed with status ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('❌ API Error: $e');
      rethrow;
    }
  }

  static void _logResponse(http.Response res) {
    if (res.body.length > 500) {
      debugPrint('📬 Response: ${res.body.substring(0, 500)}...');
    } else {
      debugPrint('📬 Response: ${res.body}');
    }
  }
}
