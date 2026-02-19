import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/admin_ktp_provider.dart';
import '../model/ktp_submission.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/auth/auth_provider.dart';

/// Admin KTP List Screen - View all RT KTP submissions.
class AdminKtpListScreen extends StatefulWidget {
  const AdminKtpListScreen({super.key});

  @override
  State<AdminKtpListScreen> createState() => _AdminKtpListScreenState();
}

class _AdminKtpListScreenState extends State<AdminKtpListScreen> {
  late final AdminKtpProvider _provider;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider = AdminKtpProvider();
    _provider.loadSubmissions(refresh: true);

    // Infinite scroll
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _provider.loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Data KTP Masuk'),
          // ⬅️ Tombol Kembali
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Kembali',
            onPressed: () => _handleBack(context),
          ),
          actions: [
            // 🔍 Filter Status
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter Status',
              onSelected: (status) {
                _provider.loadSubmissions(
                  status: status == 'all' ? null : status,
                  refresh: true,
                );
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'all', child: Text('Semua')),
                const PopupMenuItem(value: 'pending', child: Text('Menunggu')),
                const PopupMenuItem(
                  value: 'approved',
                  child: Text('Disetujui'),
                ),
                const PopupMenuItem(
                  value: 'scheduled',
                  child: Text('Terjadwal'),
                ),
                const PopupMenuItem(value: 'rejected', child: Text('Ditolak')),
              ],
            ),
            // 🔄 Refresh
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Muat Ulang',
              onPressed: () => _provider.loadSubmissions(
                status: _provider.currentFilter,
                refresh: true,
              ),
            ),
            // ⋮ Menu Logout
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Menu',
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutDialog(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 12),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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

            if (provider.errorMessage != null && !provider.isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage!),
                    backgroundColor: Colors.red,
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
    if (provider.isLoading && provider.submissions.isEmpty) {
      return const LoadingState(message: 'Memuat data KTP...');
    }

    if (provider.errorMessage != null && provider.submissions.isEmpty) {
      return ErrorState(
        message: provider.errorMessage!,
        onRetry: () => provider.loadSubmissions(refresh: true),
      );
    }

    if (provider.submissions.isEmpty) {
      return EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Belum Ada Pengajuan',
        description: provider.currentFilter != null
            ? 'Tidak ada pengajuan dengan status "${provider.currentFilter}".'
            : 'Belum ada pengajuan KTP yang masuk.',
        actionLabel: 'Muat Ulang',
        onAction: () => provider.loadSubmissions(refresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadSubmissions(
        status: provider.currentFilter,
        refresh: true,
      ),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.submissions.length + (provider.hasMore ? 1 : 0),
        separatorBuilder: (_, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= provider.submissions.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final item = provider.submissions[index];
          return _KtpSubmissionCard(
            submission: item,
            onTap: () => context.push('${RoutePaths.adminKtp}/list/${item.id}'),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go(RoutePaths.login);
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      // Jika tidak ada route sebelumnya, tetap di halaman ini
      // Navigator sudah aman karena route guard menghandle navigation
    }
  }
}

class _KtpSubmissionCard extends StatelessWidget {
  final KtpSubmission submission;
  final VoidCallback onTap;

  const _KtpSubmissionCard({required this.submission, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      submission.nama.isNotEmpty
                          ? submission.nama
                          : 'Nama tidak tersedia',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: submission.status),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.person_outline, 'Nama: ${submission.nama}'),
              const SizedBox(height: 4),
              _buildInfoRow(
                Icons.people_outline,
                'Jumlah: ${submission.jumlahPemohon} orang',
              ),
              const SizedBox(height: 4),
              _buildInfoRow(
                Icons.phone_outlined,
                'Telp: ${submission.nomorTelp}',
              ),
              const SizedBox(height: 4),
              _buildInfoRow(
                Icons.calendar_today_outlined,
                'Tanggal: ${submission.formattedDate}',
              ),
              if (submission.scheduledAt != null) ...[
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.schedule_outlined,
                  'Jadwal: ${submission.formattedSchedule}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
