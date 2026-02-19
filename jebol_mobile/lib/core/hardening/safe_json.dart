import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Safe JSON parsing utilities to prevent UI crashes from malformed responses.
class SafeJson {
  /// Safely parse JSON string, returns null on failure.
  static Map<String, dynamic>? tryParse(String? source) {
    if (source == null || source.isEmpty) return null;

    try {
      final decoded = json.decode(source);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SafeJson] Parse error: $e');
      }
      return null;
    }
  }

  /// Safely parse JSON list, returns empty list on failure.
  static List<dynamic> tryParseList(String? source) {
    if (source == null || source.isEmpty) return [];

    try {
      final decoded = json.decode(source);
      if (decoded is List) {
        return decoded;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SafeJson] Parse list error: $e');
      }
      return [];
    }
  }

  /// Safely get string value from map.
  static String getString(
    Map<String, dynamic>? map,
    String key, {
    String defaultValue = '',
  }) {
    if (map == null) return defaultValue;
    final value = map[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Safely get int value from map.
  static int getInt(
    Map<String, dynamic>? map,
    String key, {
    int defaultValue = 0,
  }) {
    if (map == null) return defaultValue;
    final value = map[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safely get double value from map.
  static double getDouble(
    Map<String, dynamic>? map,
    String key, {
    double defaultValue = 0.0,
  }) {
    if (map == null) return defaultValue;
    final value = map[key];
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safely get bool value from map.
  static bool getBool(
    Map<String, dynamic>? map,
    String key, {
    bool defaultValue = false,
  }) {
    if (map == null) return defaultValue;
    final value = map[key];
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }

  /// Safely get list value from map.
  static List<T> getList<T>(
    Map<String, dynamic>? map,
    String key, {
    List<T>? defaultValue,
  }) {
    if (map == null) return defaultValue ?? [];
    final value = map[key];
    if (value == null) return defaultValue ?? [];
    if (value is List) {
      try {
        return value.cast<T>();
      } catch (_) {
        return defaultValue ?? [];
      }
    }
    return defaultValue ?? [];
  }

  /// Safely get nested map value.
  static Map<String, dynamic>? getMap(Map<String, dynamic>? map, String key) {
    if (map == null) return null;
    final value = map[key];
    if (value is Map<String, dynamic>) return value;
    return null;
  }

  /// Safely get DateTime from map (ISO8601 string or unix timestamp).
  static DateTime? getDateTime(Map<String, dynamic>? map, String key) {
    if (map == null) return null;
    final value = map[key];
    if (value == null) return null;

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }

    if (value is int) {
      // Assume unix timestamp in seconds
      try {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      } catch (_) {
        return null;
      }
    }

    return null;
  }
}

/// API response validator.
class ApiResponseValidator {
  /// Validate that response has expected structure.
  static ValidationResult validate(
    Map<String, dynamic>? response, {
    List<String>? requiredFields,
    Map<String, Type>? fieldTypes,
  }) {
    if (response == null) {
      return ValidationResult(isValid: false, error: 'Response is null');
    }

    // Check required fields
    if (requiredFields != null) {
      for (final field in requiredFields) {
        if (!response.containsKey(field)) {
          return ValidationResult(
            isValid: false,
            error: 'Missing required field: $field',
            missingFields: [field],
          );
        }
      }
    }

    // Check field types
    if (fieldTypes != null) {
      final typeMismatches = <String, String>{};
      for (final entry in fieldTypes.entries) {
        final value = response[entry.key];
        if (value != null && value.runtimeType != entry.value) {
          // Allow some type coercion
          if (entry.value == int && value is double) continue;
          if (entry.value == double && value is int) continue;
          typeMismatches[entry.key] =
              'Expected ${entry.value}, got ${value.runtimeType}';
        }
      }
      if (typeMismatches.isNotEmpty) {
        return ValidationResult(
          isValid: false,
          error: 'Type mismatches found',
          typeMismatches: typeMismatches,
        );
      }
    }

    return ValidationResult(isValid: true);
  }

  /// Check if response indicates success (based on common API patterns).
  static bool isSuccess(Map<String, dynamic>? response) {
    if (response == null) return false;

    // Check common success indicators
    final success = response['success'];
    if (success is bool) return success;

    final status = response['status'];
    if (status == 'success' || status == true) return true;

    final code = response['code'];
    if (code == 200 || code == 201) return true;

    // Check for error indicators
    if (response.containsKey('error') || response.containsKey('errors')) {
      return false;
    }

    // Default to true if no error indicators
    return true;
  }

  /// Extract error message from response.
  static String getErrorMessage(
    Map<String, dynamic>? response, {
    String defaultMessage = 'Terjadi kesalahan',
  }) {
    if (response == null) return defaultMessage;

    // Check common error message fields
    final message =
        response['message'] ??
        response['error'] ??
        response['error_message'] ??
        response['msg'];

    if (message is String && message.isNotEmpty) {
      return message;
    }

    // Check nested errors
    final errors = response['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
      if (firstError is String) {
        return firstError;
      }
    }

    return defaultMessage;
  }
}

/// Result of validation.
class ValidationResult {
  final bool isValid;
  final String? error;
  final List<String>? missingFields;
  final Map<String, String>? typeMismatches;

  ValidationResult({
    required this.isValid,
    this.error,
    this.missingFields,
    this.typeMismatches,
  });
}
