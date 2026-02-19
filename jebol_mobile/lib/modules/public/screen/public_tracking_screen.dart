import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/public_locale_provider.dart';
import '../service/public_api_service.dart';
import '../widgets/public_app_bar.dart';

/// Track registration status by UUID. NO AUTH.
class PublicTrackingScreen extends StatefulWidget {
  final String? initialUuid;
  final PublicLocaleProvider? initialLocale;

  const PublicTrackingScreen({super.key, this.initialUuid, this.initialLocale});

  @override
  State<PublicTrackingScreen> createState() => _PublicTrackingScreenState();
}

class _PublicTrackingScreenState extends State<PublicTrackingScreen> {
  late PublicLocaleProvider _localeProvider;
  final _uuidController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  RegistrationStatus? _status;
  String? _errorMessage;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _localeProvider = widget.initialLocale ?? PublicLocaleProvider();
    if (widget.initialUuid != null) {
      _uuidController.text = widget.initialUuid!;
      // Auto-search if uuid provided
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  @override
  void dispose() {
    _uuidController.dispose();
    super.dispose();
  }

  String _tr(String key) => _localeProvider.tr(key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _localeProvider,
      child: Consumer<PublicLocaleProvider>(
        builder: (context, locale, _) {
          return Scaffold(
            appBar: PublicAppBar(
              title: _tr('tracking_title'),
              localeProvider: locale,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search form
                  _buildSearchForm(),

                  const SizedBox(height: 24),

                  // Results
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_notFound)
                    _buildNotFound()
                  else if (_errorMessage != null)
                    _buildError()
                  else if (_status != null)
                    _buildStatusResult(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr('tracking_input_label'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _uuidController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return _tr('validation_required');
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: _tr('tracking_input_hint'),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF1565C0),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(_tr('tracking_search')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.orange.shade700),
          const SizedBox(height: 16),
          Text(
            _tr('tracking_not_found'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _tr('tracking_not_found_desc'),
            style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade700),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? _tr('error_unknown'),
            style: TextStyle(fontSize: 14, color: Colors.red.shade900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.refresh),
            label: Text(_tr('error_retry')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusResult() {
    final status = _status!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge
              Row(
                children: [
                  Text(
                    _tr('tracking_status'),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  _buildStatusBadge(status.status),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Names
              _buildInfoRow(
                _localeProvider.isIndonesian ? 'Calon Suami' : 'Groom',
                status.namaLengkapPria,
              ),
              _buildInfoRow(
                _localeProvider.isIndonesian ? 'Calon Istri' : 'Bride',
                status.namaLengkapWanita,
              ),

              const SizedBox(height: 8),

              _buildInfoRow(
                _tr('tracking_submitted_at'),
                _formatDate(status.submittedAt),
              ),
              if (status.lastUpdatedAt != null)
                _buildInfoRow(
                  _tr('tracking_last_update'),
                  _formatDate(status.lastUpdatedAt!),
                ),
              if (status.scheduledDate != null)
                _buildInfoRow(
                  _localeProvider.isIndonesian
                      ? 'Jadwal Nikah'
                      : 'Marriage Date',
                  _formatDate(status.scheduledDate!),
                  highlight: true,
                ),

              // Rejection reason
              if (status.status == 'REJECTED' &&
                  status.rejectionReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _localeProvider.isIndonesian
                            ? 'Alasan Penolakan:'
                            : 'Rejection Reason:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status.rejectionReason!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Revision notes
              if (status.status == 'REVISI' &&
                  status.revisionNotes != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _localeProvider.isIndonesian
                            ? 'Catatan Revisi:'
                            : 'Revision Notes:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status.revisionNotes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Timeline
        if (status.history.isNotEmpty) ...[
          Text(
            _tr('tracking_timeline'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 12),
          _buildTimeline(status.history),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final config = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.$1.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config.$1.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.$2, size: 14, color: config.$1),
          const SizedBox(width: 4),
          Text(
            _tr('status_${status.toLowerCase()}'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: config.$1,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getStatusConfig(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return (Colors.orange, Icons.hourglass_empty);
      case 'VERIFIED':
        return (Colors.blue, Icons.verified);
      case 'SCHEDULED':
        return (Colors.purple, Icons.event);
      case 'COMPLETED':
        return (Colors.green, Icons.check_circle);
      case 'REJECTED':
        return (Colors.red, Icons.cancel);
      case 'REVISI':
        return (Colors.amber.shade700, Icons.edit_note);
      default:
        return (Colors.grey, Icons.help_outline);
    }
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
                color: highlight
                    ? const Color(0xFF1565C0)
                    : const Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<StatusHistoryItem> history) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: history.length,
        separatorBuilder: (_, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = history[index];
          final config = _getStatusConfig(item.status);
          final isLast = index == history.length - 1;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isLast
                        ? config.$1
                        : config.$1.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    config.$2,
                    size: 16,
                    color: isLast ? Colors.white : config.$1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tr('status_${item.status.toLowerCase()}'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isLast ? config.$1 : const Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDateTime(item.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (item.notes != null && item.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.notes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _search() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _status = null;
      _errorMessage = null;
      _notFound = false;
    });

    try {
      final api = PublicApiService();
      final result = await api.trackRegistration(_uuidController.text.trim());

      if (!mounted) return;

      if (result.success && result.data != null) {
        setState(() => _status = result.data);
      } else if (result.isNotFound) {
        setState(() => _notFound = true);
      } else if (result.isNetworkError) {
        setState(() => _errorMessage = _tr('error_network'));
      } else {
        setState(
          () => _errorMessage = result.errorMessage ?? _tr('error_unknown'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
