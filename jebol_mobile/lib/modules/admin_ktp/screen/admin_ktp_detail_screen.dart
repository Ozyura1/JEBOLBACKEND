import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/admin_ktp_provider.dart';
import '../model/ktp_submission.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../../shared/widgets/status_badge.dart';

/// Admin KTP Detail Screen - View and manage single KTP submission.
class AdminKtpDetailScreen extends StatefulWidget {
  final String id;

  const AdminKtpDetailScreen({super.key, required this.id});

  @override
  State<AdminKtpDetailScreen> createState() => _AdminKtpDetailScreenState();
}

class _AdminKtpDetailScreenState extends State<AdminKtpDetailScreen> {
  late final AdminKtpProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AdminKtpProvider();
    _provider.loadDetail(widget.id);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail Pengajuan KTP')),
        body: Consumer<AdminKtpProvider>(
          builder: (context, provider, _) {
            // Show messages
            if (provider.successMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.successMessage!),
                    backgroundColor: Colors.green,
                  ),
                );
                provider.clearMessages();
              });
            }

            return _buildBody(context, provider);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdminKtpProvider provider) {
    if (provider.isLoadingDetail) {
      return const LoadingState(message: 'Memuat detail...');
    }

    if (provider.errorMessage != null && provider.selectedSubmission == null) {
      return ErrorState(
        message: provider.errorMessage!,
        onRetry: () => provider.loadDetail(widget.id),
      );
    }

    final submission = provider.selectedSubmission;
    if (submission == null) {
      return const EmptyState(
        icon: Icons.error_outline,
        title: 'Data Tidak Ditemukan',
        description: 'Pengajuan KTP tidak ditemukan atau telah dihapus.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          _buildStatusCard(context, submission),
          const SizedBox(height: 16),

          // Data Card
          _buildDataCard(context, submission),
          const SizedBox(height: 16),

          // Location Card
          if (submission.latitude != null && submission.longitude != null)
            _buildLocationCard(context, submission),
          const SizedBox(height: 16),

          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(context, provider, submission),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, KtpSubmission submission) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Status Pengajuan',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const Spacer(),
                StatusBadge(status: submission.status),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('ID Pengajuan', submission.id),
            _buildDetailRow('Tanggal Masuk', submission.formattedDate),
            _buildDetailRow('Jadwal Layanan', submission.formattedSchedule),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(BuildContext context, KtpSubmission submission) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Pemohon',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const Divider(height: 24),
            _buildDetailRow('Nama', submission.nama),
            _buildDetailRow('Alamat', submission.alamat),
            _buildDetailRow('No. Telepon', submission.nomorTelp),
            _buildDetailRow(
              'Jumlah Pemohon',
              '${submission.jumlahPemohon} orang',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, KtpSubmission submission) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lokasi GPS',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'Latitude',
              submission.latitude?.toStringAsFixed(6) ?? '-',
            ),
            _buildDetailRow(
              'Longitude',
              submission.longitude?.toStringAsFixed(6) ?? '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditTrailCard(BuildContext context, KtpSubmission submission) {
    return const SizedBox.shrink();
  }

  Widget _buildAuditEntry(dynamic entry) {
    return const SizedBox.shrink();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AdminKtpProvider provider,
    KtpSubmission submission,
  ) {
    final canVerify = submission.status.toUpperCase() == 'PENDING';
    final canSchedule = [
      'VERIFIED',
      'PENDING',
    ].contains(submission.status.toUpperCase());
    final canReject = submission.status.toUpperCase() == 'PENDING';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canVerify)
          ElevatedButton.icon(
            onPressed: provider.isProcessing
                ? null
                : () => _showVerifyDialog(context, provider, submission),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Verifikasi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        if (canVerify) const SizedBox(height: 12),
        if (canSchedule)
          ElevatedButton.icon(
            onPressed: provider.isProcessing
                ? null
                : () => _showScheduleDialog(context, provider, submission),
            icon: const Icon(Icons.schedule_outlined),
            label: const Text('Jadwalkan Layanan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        if (canSchedule) const SizedBox(height: 12),
        if (canReject)
          OutlinedButton.icon(
            onPressed: provider.isProcessing
                ? null
                : () => _showRejectDialog(context, provider, submission),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Tolak Pengajuan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        if (provider.isProcessing) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  void _showVerifyDialog(
    BuildContext context,
    AdminKtpProvider provider,
    KtpSubmission submission,
  ) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verifikasi Pengajuan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verifikasi pengajuan dari ${submission.nama}?'),
            const SizedBox(height: 16),
            TextField(
              controller: catatanController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Tambahkan catatan verifikasi...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.verifySubmission(
                submission.id,
                catatan: catatanController.text.trim().isNotEmpty
                    ? catatanController.text.trim()
                    : null,
              );
              // Reload detail
              provider.loadDetail(submission.id);
            },
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(
    BuildContext context,
    AdminKtpProvider provider,
    KtpSubmission submission,
  ) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Jadwalkan Layanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jadwalkan layanan untuk ${submission.nama}'),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Tanggal'),
                subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: const Text('Waktu'),
                subtitle: Text(
                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: catatanController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  hintText: 'Informasi tambahan...',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final scheduledAt = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                await provider.scheduleSubmission(
                  submission.id,
                  scheduledAt: scheduledAt,
                  catatan: catatanController.text.trim().isNotEmpty
                      ? catatanController.text.trim()
                      : null,
                );
                // Reload detail
                provider.loadDetail(submission.id);
              },
              child: const Text('Jadwalkan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    AdminKtpProvider provider,
    KtpSubmission submission,
  ) {
    final alasanController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pengajuan'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tolak pengajuan dari ${submission.nama}?'),
              const SizedBox(height: 16),
              TextFormField(
                controller: alasanController,
                decoration: const InputDecoration(
                  labelText: 'Alasan Penolakan *',
                  hintText: 'Masukkan alasan penolakan...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alasan penolakan wajib diisi';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                await provider.rejectSubmission(
                  submission.id,
                  alasan: alasanController.text.trim(),
                );
                // Reload detail
                provider.loadDetail(submission.id);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }
}
