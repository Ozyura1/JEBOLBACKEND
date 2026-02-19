import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../../../services/api_service.dart';
import '../model/marriage_request.dart';

class RegistrationService {
  static const String _submitPath = '/api/public/perkawinan/submit';
  static const String _statusPath = '/api/public/perkawinan';

  Future<Map<String, dynamic>> submit(
    MarriageRequest request,
    List<PlatformFile> files,
  ) async {
    final uri = Uri.parse(ApiService().baseUrl).resolve(_submitPath);

    final multipartRequest = http.MultipartRequest('POST', uri);
    multipartRequest.fields.addAll(request.toFields());

    for (final file in files) {
      if (file.path == null) continue;
      final fileBytes = await File(file.path!).readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'dokumen[]',
        fileBytes,
        filename: file.name,
      );
      multipartRequest.files.add(multipartFile);
    }

    final streamed = await multipartRequest.send();
    final response = await http.Response.fromStream(streamed);

    try {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      if (body is Map && body.containsKey('success')) {
        return {
          'success': body['success'] ?? false,
          'message': body['message'] ?? '',
          'data': body['data'],
          'errors': body['errors'] ?? [],
          'statusCode': response.statusCode,
        };
      }
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': 'Respons tidak dikenal dari server.',
        'data': body,
        'errors': [],
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memproses respons server.',
        'data': null,
        'errors': [e.toString()],
        'statusCode': response.statusCode,
      };
    }
  }

  Future<Map<String, dynamic>> fetchStatus(String uuid, String nik) async {
    final uri = Uri.parse(ApiService().baseUrl)
        .resolve('$_statusPath/$uuid/status')
        .replace(queryParameters: {'nik': nik});

    final resp = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    try {
      final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
      if (body is Map && body.containsKey('success')) {
        return {
          'success': body['success'] ?? false,
          'message': body['message'] ?? '',
          'data': body['data'],
          'errors': body['errors'] ?? [],
          'statusCode': resp.statusCode,
        };
      }
      return {
        'success': resp.statusCode >= 200 && resp.statusCode < 300,
        'message': 'Respons tidak dikenal dari server.',
        'data': body,
        'errors': [],
        'statusCode': resp.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memproses respons server.',
        'data': null,
        'errors': [e.toString()],
        'statusCode': resp.statusCode,
      };
    }
  }
}
