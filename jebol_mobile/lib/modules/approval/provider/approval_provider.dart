import 'package:flutter/foundation.dart';
import '../model/approval_item.dart';
import '../service/approval_service.dart';

class ApprovalProvider extends ChangeNotifier {
  final ApprovalService _service;

  bool _isLoading = false;
  String? _errorMessage;
  List<ApprovalItem> _items = const [];

  ApprovalProvider([ApprovalService? service])
    : _service = service ?? ApprovalService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ApprovalItem> get items => _items;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchList();
      if (result['success'] == true && result['data'] is List) {
        final list = result['data'] as List;
        _items = list
            .whereType<Map>()
            .map((e) => ApprovalItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _items = const [];
        _errorMessage =
            result['message']?.toString() ?? 'Gagal memuat daftar approval.';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
