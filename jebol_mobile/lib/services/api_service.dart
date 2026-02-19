import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;
import 'package:jebol_mobile/services/secure_storage.dart';
import '../core/hardening/app_config.dart';

/// API service for communicating with the backend.
///
/// - Base URL is configured below.
/// - All methods return a Map matching the backend standard shape:
///   { success, message, data, meta, errors }
/// - Handles automatic token refresh on 401 errors.
class ApiService {
  // Base URL is determined from AppConfig; for Android emulator map
  // 'localhost' -> '10.0.2.2' at runtime so emulator can reach host machine.
  String _effectiveBaseUrl() {
    final configured = AppConfig.instance.apiBaseUrl;
    // Remove trailing '/api' segment if present so callers can resolve paths
    // consistently using resolve('/api/...') below.
    var base = configured;
    if (base.endsWith('/api')) base = base.substring(0, base.length - 4);

    if (Platform.isAndroid && base.contains('localhost')) {
      return base.replaceAll('localhost', '10.0.2.2');
    }
    return base;
  }

  /// Public accessor for callers that previously used a static base URL.
  /// Returns the runtime-mapped base URL (emulator mapping applied).
  String get baseUrl => _effectiveBaseUrl();

  /// Get current access token (for multipart requests)
  Future<String?> get token async => await _storage.read(key: _tokenKey);

  static const _tokenKey = 'api_token';
  static const _refreshTokenKey = 'refresh_token';
  final SecureStorage _storage;

  /// Flag to prevent infinite refresh loops
  bool _isRefreshing = false;

  ApiService([SecureStorage? storage])
    : _storage = storage ?? const SecureStorage();

  // ============================================================
  // AUTH ENDPOINTS
  // ============================================================

  /// Login with username and password.
  /// Stores access_token and refresh_token on success.
  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse(_effectiveBaseUrl()).resolve('/api/auth/login');
    try {
      final resp = await http.post(
        uri,
        headers: _defaultHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
          'device_name': 'mobile_app', // Required by backend
        }),
      );

      final result = _parseResponse(resp);
      if (result['success'] == true && result['data'] is Map) {
        final data = result['data'] as Map;
        // backend returns `access_token` and `refresh_token`
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
      return _networkError(e);
    }
  }

  /// Get current authenticated user data.
  /// This is the source of truth for user session validation.
  Future<Map<String, dynamic>> getMe() async {
    final uri = Uri.parse(_effectiveBaseUrl()).resolve('/api/auth/me');
    try {
      final resp = await http.get(uri, headers: await _authHeaders());
      final result = _parseResponse(resp);

      // Handle 401 - try to refresh token once
      if (resp.statusCode == 401 && !_isRefreshing) {
        final refreshed = await refreshToken();
        if (refreshed) {
          // Retry getMe with new token
          final retryResp = await http.get(uri, headers: await _authHeaders());
          return _parseResponse(retryResp);
        }
      }

      return result;
    } catch (e) {
      return _networkError(e);
    }
  }

  /// Refresh the access token using refresh token.
  /// Returns true if refresh was successful.
  Future<bool> refreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) {
        _isRefreshing = false;
        return false;
      }

      final uri = Uri.parse(_effectiveBaseUrl()).resolve('/api/auth/refresh');
      final resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
        body: jsonEncode({}),
      );

      final result = _parseResponse(resp);
      if (result['success'] == true && result['data'] is Map) {
        final data = result['data'] as Map;
        final newAccessToken = data['access_token'] as String?;
        if (newAccessToken != null) {
          await _storage.write(key: _tokenKey, value: newAccessToken);
          _isRefreshing = false;
          return true;
        }
      }

      _isRefreshing = false;
      return false;
    } catch (e) {
      _isRefreshing = false;
      return false;
    }
  }

  /// Logout - invalidates current token on backend.
  Future<Map<String, dynamic>> logout() async {
    final uri = Uri.parse(_effectiveBaseUrl()).resolve('/api/auth/logout');
    try {
      final resp = await http.post(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode({}),
      );

      // Always clear local tokens regardless of response
      await clearTokens();
      return _parseResponse(resp);
    } catch (e) {
      // Still clear tokens even on network error
      await clearTokens();
      return _networkError(e);
    }
  }

  /// Clear all stored tokens.
  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Check if we have a stored token.
  Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get stored access token.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // ============================================================
  // AUTHENTICATED API CALLS WITH AUTO-REFRESH
  // ============================================================

  /// Make an authenticated GET request with auto-refresh on 401.
  Future<Map<String, dynamic>> authGet(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    return _authRequest('GET', path, queryParams: queryParams);
  }

  /// Make an authenticated POST request with auto-refresh on 401.
  Future<Map<String, dynamic>> authPost(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _authRequest('POST', path, body: body);
  }

  /// Make an authenticated PUT request with auto-refresh on 401.
  Future<Map<String, dynamic>> authPut(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _authRequest('PUT', path, body: body);
  }

  /// Make an authenticated DELETE request with auto-refresh on 401.
  Future<Map<String, dynamic>> authDelete(String path) async {
    return _authRequest('DELETE', path);
  }

  /// Internal method for authenticated requests with auto-refresh.
  Future<Map<String, dynamic>> _authRequest(
    String method,
    String path, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
  }) async {
    var uri = Uri.parse(_effectiveBaseUrl()).resolve(path);
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    try {
      var resp = await _makeRequest(method, uri, await _authHeaders(), body);

      // Handle 401 - try to refresh token once
      if (resp.statusCode == 401 && !_isRefreshing) {
        final refreshed = await refreshToken();
        if (refreshed) {
          // Retry request with new token
          resp = await _makeRequest(method, uri, await _authHeaders(), body);
        }
      }

      return _parseResponse(resp);
    } catch (e) {
      return _networkError(e);
    }
  }

  Future<http.Response> _makeRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) async {
    switch (method) {
      case 'GET':
        return http.get(uri, headers: headers);
      case 'POST':
        return http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return http.delete(uri, headers: headers);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  // ============================================================
  // LEGACY METHODS (to be migrated to authGet/authPost)
  // ============================================================

  Future<Map<String, dynamic>> getAdminPerkawinanList({
    String status = 'PENDING',
    int page = 1,
  }) async {
    return authGet(
      '/api/admin/perkawinan',
      queryParams: {'status': status, 'page': page.toString()},
    );
  }

  Future<Map<String, dynamic>> verifyPerkawinan(
    String id,
    String? catatanAdmin,
  ) async {
    final body = <String, dynamic>{};
    if (catatanAdmin != null) body['catatan_admin'] = catatanAdmin;
    return authPost('/api/admin/perkawinan/$id/verify', body: body);
  }

  // ============================================================
  // HELPERS
  // ============================================================

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

  /// Public method to parse response (for multipart uploads)
  Map<String, dynamic> parseResponse(String responseBody) {
    try {
      final body = responseBody.isNotEmpty ? jsonDecode(responseBody) : null;

      // If backend already returns standardized shape, return it (ensure keys exist)
      if (body is Map && body.containsKey('success')) {
        // normalize fields to expected keys
        return {
          'success': body['success'] ?? false,
          'message': body['message'] ?? '',
          'data': body['data'],
          'meta': body['meta'],
          'errors': body['errors'] ?? [],
          'statusCode': 200,
        };
      }

      // For non-standard JSON
      return {
        'success': true,
        'message': '',
        'data': body,
        'meta': null,
        'errors': [],
        'statusCode': 200,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Respons tidak dikenal dari server.',
        'data': null,
        'meta': null,
        'errors': [e.toString()],
        'statusCode': 0,
      };
    }
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
          'statusCode': code,
        };
      }

      // For non-standard JSON, map by HTTP status
      if (code == 401) {
        return {
          'success': false,
          'message': 'Sesi Anda telah berakhir. Silakan login kembali.',
          'data': null,
          'meta': null,
          'errors': [],
          'statusCode': code,
        };
      }

      if (code == 422 && body is Map) {
        return {
          'success': false,
          'message': 'Data tidak valid. Periksa kembali input Anda.',
          'data': null,
          'meta': null,
          'errors': body['errors'] ?? body,
          'statusCode': code,
        };
      }

      if (code >= 500) {
        return {
          'success': false,
          'message': 'Terjadi kesalahan pada server. Coba lagi nanti.',
          'data': null,
          'meta': null,
          'errors': [],
          'statusCode': code,
        };
      }

      // Success response without standard shape
      if (code >= 200 && code < 300) {
        return {
          'success': true,
          'message': '',
          'data': body,
          'meta': null,
          'errors': [],
          'statusCode': code,
        };
      }

      // default fallback
      return {
        'success': false,
        'message': 'Respons tidak dikenal dari server.',
        'data': body,
        'meta': null,
        'errors': [],
        'statusCode': code,
      };
    } catch (e) {
      // JSON parse error or other
      if (code == 401) {
        return {
          'success': false,
          'message': 'Sesi Anda telah berakhir. Silakan login kembali.',
          'data': null,
          'meta': null,
          'errors': [],
          'statusCode': code,
        };
      }
      if (code == 422) {
        return {
          'success': false,
          'message': 'Data tidak valid. Periksa kembali input Anda.',
          'data': null,
          'meta': null,
          'errors': [],
          'statusCode': code,
        };
      }
      if (code >= 500) {
        return {
          'success': false,
          'message': 'Terjadi kesalahan pada server. Coba lagi nanti.',
          'data': null,
          'meta': null,
          'errors': [],
          'statusCode': code,
        };
      }
      return {
        'success': false,
        'message': 'Respons tidak dikenal dari server.',
        'data': null,
        'meta': null,
        'errors': [],
        'statusCode': code,
      };
    }
  }

  Map<String, dynamic> _networkError(dynamic error) {
    return {
      'success': false,
      'message':
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      'data': null,
      'meta': null,
      'errors': [error.toString()],
      'statusCode': 0,
    };
  }
}
