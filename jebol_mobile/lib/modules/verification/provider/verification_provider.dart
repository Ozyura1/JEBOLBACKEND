import 'package:flutter/foundation.dart';
import '../model/verification_item.dart';
import '../service/verification_service.dart';

class VerificationProvider extends ChangeNotifier {
  final VerificationService _service;

  bool _isLoading = false;
  String? _errorMessage;
  List<VerificationItem> _items = const [];
  Map<String, dynamic>? _detail;

  VerificationProvider([VerificationService? service])
    : _service = service ?? VerificationService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<VerificationItem> get items => _items;
  Map<String, dynamic>? get detail => _detail;

  Future<void> loadList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchList();
      if (result['success'] == true && result['data'] is List) {
        final list = result['data'] as List;
        _items = list
            .whereType<Map>()
            .map((e) => VerificationItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _items = const [];
        _errorMessage = result['message']?.toString() ?? 'Gagal memuat daftar.';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat daftar. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetail(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchDetail(id);
      if (result['success'] == true && result['data'] is Map) {
        _detail = Map<String, dynamic>.from(result['data']);
      } else {
        _detail = null;
        _errorMessage = result['message']?.toString() ?? 'Gagal memuat detail.';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat detail. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markValid(String id) async {
    try {
      final result = await _service.markValid(id);
      if (result['success'] == true) return true;
      _errorMessage = result['message']?.toString() ?? 'Gagal verifikasi.';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Gagal verifikasi. Periksa koneksi internet.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markRevisi(String id, String reason) async {
    try {
      final result = await _service.markRevisi(id, reason);
      if (result['success'] == true) return true;
      _errorMessage = result['message']?.toString() ?? 'Gagal revisi.';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Gagal revisi. Periksa koneksi internet.';
      notifyListeners();
      return false;
    }
  }
}
