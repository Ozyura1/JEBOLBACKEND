import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/admin_perkawinan_provider.dart';
import '../model/marriage_registration.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../../shared/widgets/status_badge.dart';

/// Admin Perkawinan Detail Screen - View and manage single marriage registration.
class AdminPerkawinanDetailScreen extends StatefulWidget {
  final String uuid;

  const AdminPerkawinanDetailScreen({super.key, required this.uuid});

  @override
  State<AdminPerkawinanDetailScreen> createState() =>
      _AdminPerkawinanDetailScreenState();
}

class _AdminPerkawinanDetailScreenState
    extends State<AdminPerkawinanDetailScreen> {
  late final AdminPerkawinanProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AdminPerkawinanProvider();
    _provider.loadDetail(widget.uuid);
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
        appBar: AppBar(title: const Text('Detail Pendaftaran')),
        body: Consumer<AdminPerkawinanProvider>(
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

  Widget _buildBody(BuildContext context, AdminPerkawinanProvider provider) {
    if (provider.isLoadingDetail) {
      return const LoadingState(message: 'Memuat detail...');
    }

    if (provider.errorMessage != null &&
        provider.selectedRegistration == null) {
      return ErrorState(
        message: provider.errorMessage!,
        onRetry: () => provider.loadDetail(widget.uuid),
      );
    }

    final registration = provider.selectedRegistration;
    if (registration == null) {
      return const EmptyState(
        icon: Icons.error_outline,
        title: 'Data Tidak Ditemukan',
        description:
            'Pendaftaran perkawinan tidak ditemukan atau telah dihapus.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          _buildStatusCard(context, registration),
          const SizedBox(height: 16),

          // Pria Data Card
          _buildPriaCard(context, registration),
          const SizedBox(height: 16),

          // Wanita Data Card
          _buildWanitaCard(context, registration),
          const SizedBox(height: 16),

          // Documents Card
          if (registration.dokumenUrls.isNotEmpty)
            _buildDocumentsCard(context, registration),
          const SizedBox(height: 16),

          // Audit Trail Card
          if (registration.auditTrail.isNotEmpty)
            _buildAuditTrailCard(context, registration),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(context, provider, registration),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    MarriageRegistration registration,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Status Pendaftaran',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const Spacer(),
                StatusBadge(status: registration.status),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('ID Pendaftaran', registration.uuid),
            _buildDetailRow(
              'Tanggal Pengajuan',
              registration.formattedTanggalPengajuan,
            ),
            _buildDetailRow(
              'Tanggal Nikah',
              registration.formattedTanggalNikah,
            ),
            if (registration.catatan != null &&
                registration.catatan!.isNotEmpty)
              _buildDetailRow('Catatan Pemohon', registration.catatan!),
            if (registration.catatanAdmin != null &&
                registration.catatanAdmin!.isNotEmpty)
              _buildDetailRow('Catatan Admin', registration.catatanAdmin!),
          ],
        ),
      ),
    );
  }

  Widget _buildPriaCard(
    BuildContext context,
    MarriageRegistration registration,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.male, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Data Calon Suami',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Nama', registration.namaPria),
            _buildDetailRow('NIK', registration.nikPria),
            if (registration.noTeleponPria != null &&
                registration.noTeleponPria!.isNotEmpty)
              _buildDetailRow('No. Telepon', registration.noTeleponPria!),
            if (registration.alamatPria != null &&
                registration.alamatPria!.isNotEmpty)
              _buildDetailRow('Alamat', registration.alamatPria!),
          ],
        ),
      ),
    );
  }

  Widget _buildWanitaCard(
    BuildContext context,
    MarriageRegistration registration,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.female, color: Colors.pink[700]),
                const SizedBox(width: 8),
                const Text(
                  'Data Calon Istri',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Nama', registration.namWanita),
            _buildDetailRow('NIK', registration.nikWanita),
            if (registration.noTeleponWanita != null &&
                registration.noTeleponWanita!.isNotEmpty)
              _buildDetailRow('No. Telepon', registration.noTeleponWanita!),
            if (registration.alamatWanita != null &&
                registration.alamatWanita!.isNotEmpty)
              _buildDetailRow('Alamat', registration.alamatWanita!),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsCard(
    BuildContext context,
    MarriageRegistration registration,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dokumen Pendukung',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const Divider(height: 24),
            Text(
              '${registration.dokumenUrls.length} dokumen terlampir',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: registration.dokumenUrls.asMap().entries.map((entry) {
                return Chip(
                  avatar: const Icon(Icons.description, size: 18),
                  label: Text('Dokumen ${entry.key + 1}'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditTrailCard(
    BuildContext context,
    MarriageRegistration registration,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat Aktivitas',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const Divider(height: 24),
            ...registration.auditTrail.map((entry) => _buildAuditEntry(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditEntry(MarriageAuditEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${entry.actorName ?? 'System'} • ${entry.formattedTimestamp}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (entry.notes != null && entry.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      entry.notes!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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
    AdminPerkawinanProvider provider,
    MarriageRegistration registration,
  ) {
    final statusUpper = registration.status.toUpperCase();
    final canVerify = statusUpper == 'PENDING';
    final canSchedule = ['VERIFIED', 'PENDING'].contains(statusUpper);
    final canRequestRevision = statusUpper == 'PENDING';
    final canReject = statusUpper == 'PENDING';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canVerify)
          ElevatedButton.icon(
            onPressed: provider.isProcessing
                ? null
                : () => _showVerifyDialog(context, provider, registration),
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
                : () => _showScheduleDialog(context, provider, registration),
            icon: const Icon(Icons.favorite_outlined),
            label: const Text('Tetapkan Tanggal Nikah'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        if (canSchedule) const SizedBox(height: 12),
        if (canRequestRevision)
          OutlinedButton.icon(
            onPressed: provider.isProcessing
                ? null
                : () => _showRevisionDialog(context, provider, registration),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Minta Revisi/Kelengkapan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        if (canRequestRevision) const SizedBox(height: 12),
        if (canReject)
          OutlinedButton.icon(
            onPressed: provider.isProcessing
                ? null
                : () => _showRejectDialog(context, provider, registration),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Tolak Pendaftaran'),
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
    AdminPerkawinanProvider provider,
    MarriageRegistration registration,
  ) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verifikasi Pendaftaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verifikasi pendaftaran ${registration.pasanganNames}?'),
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
              await provider.verifyRegistration(
                registration.uuid,
                catatan: catatanController.text.trim().isNotEmpty
                    ? catatanController.text.trim()
                    : null,
              );
              provider.loadDetail(registration.uuid);
            },
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(
    BuildContext context,
    AdminPerkawinanProvider provider,
    MarriageRegistration registration,
  ) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 14));
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tetapkan Tanggal Nikah'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tetapkan tanggal nikah untuk ${registration.pasanganNames}',
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Tanggal Nikah'),
                subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().add(const Duration(days: 7)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
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
                await provider.scheduleRegistration(
                  registration.uuid,
                  tanggalNikah: selectedDate,
                  catatan: catatanController.text.trim().isNotEmpty
                      ? catatanController.text.trim()
                      : null,
                );
                provider.loadDetail(registration.uuid);
              },
              child: const Text('Tetapkan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRevisionDialog(
    BuildContext context,
    AdminPerkawinanProvider provider,
    MarriageRegistration registration,
  ) {
    final catatanController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minta Revisi'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Minta pemohon untuk melengkapi atau memperbaiki data.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: catatanController,
                decoration: const InputDecoration(
                  labelText: 'Catatan Revisi *',
                  hintText: 'Jelaskan apa yang perlu diperbaiki...',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Catatan revisi wajib diisi';
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
                await provider.requestRevision(
                  registration.uuid,
                  catatan: catatanController.text.trim(),
                );
                provider.loadDetail(registration.uuid);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    AdminPerkawinanProvider provider,
    MarriageRegistration registration,
  ) {
    final alasanController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pendaftaran'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tolak pendaftaran ${registration.pasanganNames}?'),
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
                await provider.rejectRegistration(
                  registration.uuid,
                  alasan: alasanController.text.trim(),
                );
                provider.loadDetail(registration.uuid);
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
