import 'package:flutter/foundation.dart';
import '../model/ikd_submission.dart';
import '../service/admin_ikd_service.dart';
import '../../../core/network/api_result.dart';

/// Provider for Admin IKD module state management.
class AdminIkdProvider extends ChangeNotifier {
  final AdminIkdService _service;

  AdminIkdProvider([AdminIkdService? service])
    : _service = service ?? AdminIkdService();

  // State
  List<IkdSubmission> _submissions = [];
  IkdSubmission? _selectedSubmission;
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _successMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  String? _currentFilter;

  // Getters
  List<IkdSubmission> get submissions => _submissions;
  IkdSubmission? get selectedSubmission => _selectedSubmission;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String? get currentFilter => _currentFilter;
  bool get hasMore => _currentPage < _totalPages;

  /// Clear messages after display.
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Load submissions list.
  Future<void> loadSubmissions({String? status, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _submissions = [];
    }

    _isLoading = true;
    _errorMessage = null;
    _currentFilter = status;
    notifyListeners();

    try {
      final response = await _service.fetchList(
        status: status,
        page: _currentPage,
      );

      final result = ApiResult.fromResponse(response);

      if (result.isSessionExpired) {
        _errorMessage = result.userMessage;
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (!result.isSuccess) {
        _errorMessage = result.userMessage;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Parse data
      final data = result.data;
      if (data is List) {
        _submissions = data
            .map(
              (e) =>
                  e is Map<String, dynamic> ? IkdSubmission.fromJson(e) : null,
            )
            .whereType<IkdSubmission>()
            .toList();
      } else if (data is Map && data['data'] is List) {
        _submissions = (data['data'] as List)
            .map(
              (e) =>
                  e is Map<String, dynamic> ? IkdSubmission.fromJson(e) : null,
            )
            .whereType<IkdSubmission>()
            .toList();

        // Parse pagination meta
        final meta = data['meta'] as Map<String, dynamic>?;
        if (meta != null) {
          _currentPage = meta['current_page'] as int? ?? 1;
          _totalPages = meta['last_page'] as int? ?? 1;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat data. Silakan coba lagi.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load next page.
  Future<void> loadNextPage() async {
    if (!hasMore || _isLoading) return;
    _currentPage++;
    await loadSubmissions(status: _currentFilter);
  }

  /// Load submission detail.
  Future<void> loadDetail(String id) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    _selectedSubmission = null;
    notifyListeners();

    try {
      final response = await _service.fetchDetail(id);
      final result = ApiResult.fromResponse(response);

      if (result.isSessionExpired) {
        _errorMessage = result.userMessage;
        _isLoadingDetail = false;
        notifyListeners();
        return;
      }

      if (!result.isSuccess) {
        _errorMessage = result.userMessage;
        _isLoadingDetail = false;
        notifyListeners();
        return;
      }

      final data = result.data;
      if (data is Map<String, dynamic>) {
        _selectedSubmission = IkdSubmission.fromJson(data);
      }

      _isLoadingDetail = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat detail. Silakan coba lagi.';
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  /// Verify a submission.
  Future<bool> verifySubmission(String id, {String? catatan}) async {
    _isProcessing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _service.verify(id, catatan: catatan);
      final result = ApiResult.fromResponse(response);

      if (result.isSessionExpired) {
        _errorMessage = result.userMessage;
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      if (!result.isSuccess) {
        _errorMessage = result.userMessage;
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      _successMessage = 'Pengajuan berhasil diverifikasi.';
      _isProcessing = false;
      notifyListeners();

      // Refresh list
      await loadSubmissions(status: _currentFilter, refresh: true);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memverifikasi. Silakan coba lagi.';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Schedule a submission.
  Future<bool> scheduleSubmission(
    String id, {
    required DateTime scheduledAt,
    String? catatan,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _service.schedule(
        id,
        scheduledAt: scheduledAt,
        catatan: catatan,
      );
      final result = ApiResult.fromResponse(response);

      if (result.isSessionExpired) {
        _errorMessage = result.userMessage;
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      if (!result.isSuccess) {
        _errorMessage = result.userMessage;
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      _successMessage = 'Jadwal aktivasi berhasil ditetapkan.';
      _isProcessing = false;
      notifyListeners();

      // Refresh list
      await loadSubmissions(status: _currentFilter, refresh: true);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menjadwalkan. Silakan coba lagi.';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Activate/complete a submission.
  Future<bool> activateSubmission(String id, {String? catatan}) async {
    _isProcessing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _service.activate(id, catatan: catatan);
      final result = ApiResult.fromResponse(response);

      if (result.isSessionExpired) {
        _errorMessage = result.userMessage;
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      if (!result.isSuccess) {
        _errorMessage = result.userMessage;
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      _successMessage = 'IKD berhasil diaktivasi.';
      _isProcessing = false;
      notifyListeners();

      // Refresh list
      await loadSubmissions(status: _currentFilter, refresh: true);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengaktivasi. Silakan coba lagi.';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Reject a submission.
  Future<bool> rejectSubmission(String id, {required String alasan}) async {
    _isProcessing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _service.reject(id, alasan: alasan);
      final result = ApiResult.fromResponse(response);

      if (result.isSessionExpired) {
        _errorMessage = result.userMessage;
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      if (!result.isSuccess) {
        _errorMessage = result.userMessage;
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      _successMessage = 'Pengajuan berhasil ditolak.';
      _isProcessing = false;
      notifyListeners();

      // Refresh list
      await loadSubmissions(status: _currentFilter, refresh: true);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menolak pengajuan. Silakan coba lagi.';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear selection.
  void clearSelection() {
    _selectedSubmission = null;
    notifyListeners();
  }
}
