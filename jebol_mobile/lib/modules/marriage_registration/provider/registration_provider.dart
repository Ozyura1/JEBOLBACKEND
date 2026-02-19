import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../model/marriage_request.dart';
import '../service/registration_service.dart';

class RegistrationProvider extends ChangeNotifier {
  final RegistrationService _service;

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;
  String? _submittedUuid;

  RegistrationProvider([RegistrationService? service])
    : _service = service ?? RegistrationService();

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get submittedUuid => _submittedUuid;

  Future<bool> submit(MarriageRequest request, List<PlatformFile> files) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    _submittedUuid = null;
    notifyListeners();

    try {
      final result = await _service.submit(request, files);
      if (result['success'] == true) {
        _successMessage = result['message']?.toString() ?? 'Berhasil dikirim.';
        final data = result['data'];
        if (data is Map && data['uuid'] != null) {
          _submittedUuid = data['uuid'].toString();
        }
        return true;
      }
      _errorMessage = result['message']?.toString() ?? 'Gagal mengirim data.';
      return false;
    } catch (e) {
      _errorMessage = 'Gagal mengirim data. Periksa koneksi internet.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
