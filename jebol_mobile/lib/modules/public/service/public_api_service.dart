import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Public API service - NO AUTHENTICATION REQUIRED.
///
/// IMPORTANT: This service does NOT use any auth tokens.
/// All endpoints are public-facing for citizen self-service.
class PublicApiService {
  static const String _baseUrl = 'http://192.168.31.68:8000/api/v1';
  static const Duration _timeout = Duration(seconds: 30);

  /// Submit marriage registration (no auth).
  /// Returns registration UUID on success.
  Future<PublicApiResult<String>> submitMarriageRegistration({
    required Map<String, dynamic> formData,
    required Map<String, File> documents,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/public/perkawinan/register');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add form fields
      formData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add document files
      for (final entry in documents.entries) {
        final file = entry.value;
        final mimeType = _getMimeType(file.path);

        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            file.path,
            contentType: mimeType,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final uuid =
            json['data']?['uuid'] ?? json['data']?['registration_number'];
        return PublicApiResult.success(uuid.toString());
      } else if (response.statusCode == 422) {
        final json = jsonDecode(response.body);
        final errors = json['errors'] as Map<String, dynamic>?;
        return PublicApiResult.validationError(_flattenErrors(errors));
      } else {
        return PublicApiResult.error('Server error: ${response.statusCode}');
      }
    } on SocketException {
      return PublicApiResult.networkError();
    } on http.ClientException {
      return PublicApiResult.networkError();
    } catch (e) {
      return PublicApiResult.error(e.toString());
    }
  }

  /// Track registration status by UUID (no auth).
  Future<PublicApiResult<RegistrationStatus>> trackRegistration(
    String uuid,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/public/perkawinan/track/$uuid');

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'];
        return PublicApiResult.success(RegistrationStatus.fromJson(data));
      } else if (response.statusCode == 404) {
        return PublicApiResult.notFound();
      } else {
        return PublicApiResult.error('Server error: ${response.statusCode}');
      }
    } on SocketException {
      return PublicApiResult.networkError();
    } on http.ClientException {
      return PublicApiResult.networkError();
    } catch (e) {
      return PublicApiResult.error(e.toString());
    }
  }

  MediaType _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'pdf':
        return MediaType('application', 'pdf');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  Map<String, String> _flattenErrors(Map<String, dynamic>? errors) {
    final result = <String, String>{};
    if (errors == null) return result;

    errors.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        result[key] = value.first.toString();
      } else if (value is String) {
        result[key] = value;
      }
    });
    return result;
  }
}

/// API result wrapper for public endpoints.
class PublicApiResult<T> {
  final bool success;
  final T? data;
  final String? errorMessage;
  final Map<String, String>? validationErrors;
  final PublicApiErrorType errorType;

  PublicApiResult._({
    required this.success,
    this.data,
    this.errorMessage,
    this.validationErrors,
    this.errorType = PublicApiErrorType.none,
  });

  factory PublicApiResult.success(T data) =>
      PublicApiResult._(success: true, data: data);

  factory PublicApiResult.error(String message) => PublicApiResult._(
    success: false,
    errorMessage: message,
    errorType: PublicApiErrorType.server,
  );

  factory PublicApiResult.validationError(Map<String, String> errors) =>
      PublicApiResult._(
        success: false,
        validationErrors: errors,
        errorType: PublicApiErrorType.validation,
      );

  factory PublicApiResult.networkError() =>
      PublicApiResult._(success: false, errorType: PublicApiErrorType.network);

  factory PublicApiResult.notFound() =>
      PublicApiResult._(success: false, errorType: PublicApiErrorType.notFound);

  bool get isNetworkError => errorType == PublicApiErrorType.network;
  bool get isValidationError => errorType == PublicApiErrorType.validation;
  bool get isNotFound => errorType == PublicApiErrorType.notFound;
}

enum PublicApiErrorType { none, network, server, validation, notFound }

/// Registration status model.
class RegistrationStatus {
  final String uuid;
  final String status;
  final String namaLengkapPria;
  final String namaLengkapWanita;
  final DateTime submittedAt;
  final DateTime? lastUpdatedAt;
  final DateTime? scheduledDate;
  final String? rejectionReason;
  final String? revisionNotes;
  final List<StatusHistoryItem> history;

  RegistrationStatus({
    required this.uuid,
    required this.status,
    required this.namaLengkapPria,
    required this.namaLengkapWanita,
    required this.submittedAt,
    this.lastUpdatedAt,
    this.scheduledDate,
    this.rejectionReason,
    this.revisionNotes,
    required this.history,
  });

  factory RegistrationStatus.fromJson(Map<String, dynamic> json) {
    return RegistrationStatus(
      uuid: json['uuid'] ?? json['registration_number'] ?? '',
      status: json['status'] ?? 'PENDING',
      namaLengkapPria:
          json['nama_lengkap_pria'] ?? json['pria']?['nama_lengkap'] ?? '-',
      namaLengkapWanita:
          json['nama_lengkap_wanita'] ?? json['wanita']?['nama_lengkap'] ?? '-',
      submittedAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      lastUpdatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      scheduledDate: json['tanggal_nikah'] != null
          ? DateTime.tryParse(json['tanggal_nikah'])
          : null,
      rejectionReason: json['rejection_reason'],
      revisionNotes: json['revision_notes'],
      history:
          (json['history'] as List<dynamic>?)
              ?.map((e) => StatusHistoryItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class StatusHistoryItem {
  final String status;
  final DateTime timestamp;
  final String? notes;

  StatusHistoryItem({
    required this.status,
    required this.timestamp,
    this.notes,
  });

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItem(
      status: json['status'] ?? '',
      timestamp: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      notes: json['notes'],
    );
  }
}
