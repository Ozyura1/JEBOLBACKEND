import 'package:flutter/foundation.dart';
import '../model/marriage_registration.dart';
import '../service/admin_perkawinan_service.dart';
import '../../../core/network/api_result.dart';

/// Provider for Admin Perkawinan module state management.
class AdminPerkawinanProvider extends ChangeNotifier {
  final AdminPerkawinanService _service;

  AdminPerkawinanProvider([AdminPerkawinanService? service])
    : _service = service ?? AdminPerkawinanService();

  // State
  List<MarriageRegistration> _registrations = [];
  MarriageRegistration? _selectedRegistration;
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _successMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  String? _currentFilter;

  // Getters
  List<MarriageRegistration> get registrations => _registrations;
  MarriageRegistration? get selectedRegistration => _selectedRegistration;
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

  /// Load registrations list.
  Future<void> loadRegistrations({String? status, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _registrations = [];
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
        _registrations = data
            .map(
              (e) => e is Map<String, dynamic>
                  ? MarriageRegistration.fromJson(e)
                  : null,
            )
            .whereType<MarriageRegistration>()
            .toList();
      } else if (data is Map && data['data'] is List) {
        _registrations = (data['data'] as List)
            .map(
              (e) => e is Map<String, dynamic>
                  ? MarriageRegistration.fromJson(e)
                  : null,
            )
            .whereType<MarriageRegistration>()
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
    await loadRegistrations(status: _currentFilter);
  }

  /// Load registration detail.
  Future<void> loadDetail(String uuid) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    _selectedRegistration = null;
    notifyListeners();

    try {
      final response = await _service.fetchDetail(uuid);
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
        _selectedRegistration = MarriageRegistration.fromJson(data);
      }

      _isLoadingDetail = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat detail. Silakan coba lagi.';
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  /// Verify a registration.
  Future<bool> verifyRegistration(String uuid, {String? catatan}) async {
    _isProcessing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _service.verify(uuid, catatan: catatan);
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

      _successMessage = 'Pendaftaran berhasil diverifikasi.';
      _isProcessing = false;
      notifyListeners();

      // Refresh list
      await loadRegistrations(status: _currentFilter, refresh: true);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memverifikasi. Silakan coba lagi.';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Schedule marriage ceremony.
  Future<bool> scheduleRegistration(
    String uuid, {
    required DateTime tanggalNikah,
    String? catatan,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _service.schedule(
        uuid,
        tanggalNikah: tanggalNikah,
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

      _successMessage = 'Tanggal pernikahan berhasil ditetapkan.';
      _isProcessing = false;
      notifyListeners();

      // Refresh list
      await loadRegistrations(status: _currentFilter, refresh: true);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menjadwalkan. Silakan coba lagi.';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Reject a registration.
  Future<bool> rejectRegistration(String uuid, {required String alasan}) async {
    _isProcessing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _service.reject(uuid, alasan: alasan);
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

      _successMessage = 'Pendaftaran berhasil ditolak.';
      _isProcessing = false;
      notifyListeners();

      // Refresh list
      await loadRegistrations(status: _currentFilter, refresh: true);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menolak pendaftaran. Silakan coba lagi.';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Request revision/additional documents.
  Future<bool> requestRevision(String uuid, {required String catatan}) async {
    _isProcessing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _service.requestRevision(uuid, catatan: catatan);
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

      _successMessage = 'Permintaan revisi berhasil dikirim.';
      _isProcessing = false;
      notifyListeners();

      // Refresh list
      await loadRegistrations(status: _currentFilter, refresh: true);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim permintaan revisi. Silakan coba lagi.';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear selection.
  void clearSelection() {
    _selectedRegistration = null;
    notifyListeners();
  }
}
