import 'package:flutter/foundation.dart';
import '../model/ktp_request.dart';
import '../service/rt_service.dart';

class KtpProvider extends ChangeNotifier {
  final RtService _service;

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  KtpProvider([RtService? service]) : _service = service ?? RtService();

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> submit(KtpRequest request) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _service.submitKtp(request);
      print('KTP Submit Response: $result'); // Debug log

      if (result['success'] == true) {
        _successMessage = result['message']?.toString() ?? 'Berhasil dikirim.';
        return true;
      }

      // Handle validation errors
      if (result['errors'] != null && result['errors'] is Map) {
        final errors = result['errors'] as Map<String, dynamic>;
        final errorMessages = errors.entries.map((e) {
          final messages = e.value is List
              ? (e.value as List).join(', ')
              : e.value.toString();
          return '$messages';
        }).toList();
        _errorMessage = errorMessages.join('\n');
      } else {
        _errorMessage =
            result['message']?.toString() ?? 'Gagal mengirim data KTP.';
      }
      return false;
    } catch (e) {
      print('KTP Submit Exception: $e'); // Debug log
      _errorMessage = 'Gagal mengirim data. Periksa koneksi internet: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
