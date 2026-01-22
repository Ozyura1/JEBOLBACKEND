import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jebol_mobile/services/secure_storage.dart';

/// API service for communicating with the backend.
///
/// - Base URL is configured below.
/// - All methods return a Map matching the backend standard shape:
///   { success, message, data, meta, errors }
class ApiService {
  // Adjust base URL as appropriate for dev/production (no trailing slash preferred)
  static const String baseUrl = 'http://192.168.31.154:8000';

  static const _tokenKey = 'api_token';
  static const _refreshTokenKey = 'refresh_token';
  final SecureStorage _storage;

  ApiService([SecureStorage? storage])
    : _storage = storage ?? const SecureStorage();

  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse(baseUrl).resolve('/api/auth/login');
    try {
      final resp = await http.post(
        uri,
        headers: _defaultHeaders(),
        body: jsonEncode({'username': username, 'password': password}),
      );

      final result = _parseResponse(resp);
      if (result['success'] == true && result['data'] is Map) {
        final data = result['data'] as Map;
        // backend now returns `access_token` and `refresh_token`
        final access =
          data['access_token'] as String? ?? data['token'] as String?;
        final refresh = data['refresh_token'] as String?;
        if (access != null) {
          await _storage.write(key: _tokenKey, value: access);
        }
        if (refresh != null) {
          await _storage.write(key: _refreshTokenKey, value: refresh);
        }
      }
      return result;
    } catch (e) {
      return _serverError();
    }
  }

  Future<Map<String, dynamic>> getAdminPerkawinanList({
    String status = 'PENDING',
    int page = 1,
  }) async {
    final uri = Uri.parse(baseUrl)
        .resolve('/api/admin/perkawinan')
        .replace(queryParameters: {'status': status, 'page': page.toString()});

    try {
      final resp = await http.get(uri, headers: await _authHeaders());
      return _parseResponse(resp);
    } catch (e) {
      return _serverError();
    }
  }

  Future<Map<String, dynamic>> verifyPerkawinan(
    String id,
    String? catatanAdmin,
  ) async {
    final uri = Uri.parse(baseUrl).resolve('/api/admin/perkawinan/$id/verify');
    final body = <String, dynamic>{};
    if (catatanAdmin != null) body['catatan_admin'] = catatanAdmin;

    try {
      final resp = await http.post(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );
      return _parseResponse(resp);
    } catch (e) {
      return _serverError();
    }
  }

  // Helpers
  Map<String, String> _defaultHeaders() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: _tokenKey);
    final headers = _defaultHeaders();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _parseResponse(http.Response resp) {
    final code = resp.statusCode;
    try {
      final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;

      // If backend already returns standardized shape, return it (ensure keys exist)
      if (body is Map && body.containsKey('success')) {
        // normalize fields to expected keys
        return {
          'success': body['success'] ?? false,
          'message': body['message'] ?? '',
          'data': body['data'],
          'meta': body['meta'],
          'errors': body['errors'] ?? [],
        };
      }

      // For non-standard JSON, map by HTTP status
      if (code == 401) {
        return {
          'success': false,
          'message': 'Unauthenticated',
          'data': null,
          'meta': null,
          'errors': [],
        };
      }

      if (code == 422 && body is Map) {
        return {
          'success': false,
          'message': 'Validation failed',
          'data': null,
          'meta': null,
          'errors': body['errors'] ?? body,
        };
      }

      if (code >= 500) {
        return {
          'success': false,
          'message': 'Server error',
          'data': null,
          'meta': null,
          'errors': [],
        };
      }

      // default fallback
      return {
        'success': false,
        'message': 'Unexpected response',
        'data': body,
        'meta': null,
        'errors': [],
      };
    } catch (e) {
      // JSON parse error or other
      if (code == 401) {
        return {
          'success': false,
          'message': 'Unauthenticated',
          'data': null,
          'meta': null,
          'errors': [],
        };
      }
      if (code == 422) {
        return {
          'success': false,
          'message': 'Validation failed',
          'data': null,
          'meta': null,
          'errors': [],
        };
      }
      if (code >= 500) {
        return {
          'success': false,
          'message': 'Server error',
          'data': null,
          'meta': null,
          'errors': [],
        };
      }
      return {
        'success': false,
        'message': 'Unexpected response',
        'data': null,
        'meta': null,
        'errors': [],
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    final uri = Uri.parse(baseUrl).resolve('/api/auth/logout');
    try {
      final resp = await http.post(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode({}),
      );

      final result = _parseResponse(resp);
      return result;
    } catch (e) {
      return _serverError();
    }
  }

  Map<String, dynamic> _serverError() {
    return {
      'success': false,
      'message': 'Server error',
      'data': null,
      'meta': null,
      'errors': [],
    };
  }
}
