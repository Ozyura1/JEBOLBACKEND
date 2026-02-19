import 'package:flutter/foundation.dart';
import '../model/monitoring_stat.dart';
import '../service/monitoring_service.dart';

class MonitoringProvider extends ChangeNotifier {
  final MonitoringService _service;

  bool _isLoading = false;
  String? _errorMessage;
  List<MonitoringStat> _stats = const [];

  MonitoringProvider([MonitoringService? service])
    : _service = service ?? MonitoringService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MonitoringStat> get stats => _stats;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchStats();
      if (result['success'] == true && result['data'] is List) {
        final list = result['data'] as List;
        _stats = list
            .whereType<Map>()
            .map((e) => MonitoringStat.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _stats = const [];
        _errorMessage =
            result['message']?.toString() ?? 'Gagal memuat statistik.';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
