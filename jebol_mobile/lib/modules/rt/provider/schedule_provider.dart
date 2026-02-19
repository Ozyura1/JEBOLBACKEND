import 'package:flutter/foundation.dart';
import '../model/schedule_item.dart';
import '../service/rt_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final RtService _service;

  bool _isLoading = false;
  String? _errorMessage;
  List<ScheduleItem> _items = const [];

  ScheduleProvider([RtService? service]) : _service = service ?? RtService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ScheduleItem> get items => _items;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchSchedules();
      if (result['success'] == true && result['data'] is List) {
        final list = result['data'] as List;
        _items = list
            .whereType<Map>()
            .map((e) => ScheduleItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _items = const [];
        _errorMessage = result['message']?.toString() ?? 'Gagal memuat jadwal.';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat jadwal. Periksa koneksi internet.';
      _items = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
