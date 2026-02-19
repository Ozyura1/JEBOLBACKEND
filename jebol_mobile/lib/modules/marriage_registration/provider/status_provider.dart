import 'package:flutter/foundation.dart';
import '../service/registration_service.dart';

class MarriageStatusProvider extends ChangeNotifier {
  final RegistrationService _service;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _statusData;

  MarriageStatusProvider([RegistrationService? service])
    : _service = service ?? RegistrationService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get statusData => _statusData;

  Future<void> fetchStatus(String uuid, String nik) async {
    _isLoading = true;
    _errorMessage = null;
    _statusData = null;
    notifyListeners();

    try {
      final result = await _service.fetchStatus(uuid, nik);
      if (result['success'] == true && result['data'] is Map) {
        _statusData = Map<String, dynamic>.from(result['data']);
      } else {
        _errorMessage = result['message']?.toString() ?? 'Gagal memuat status.';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat status. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
