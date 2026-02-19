import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../provider/admin_ikd_provider.dart';
import '../model/ikd_submission.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/routing/route_paths.dart';

/// Admin IKD List Screen - View all RT IKD activation requests.
class AdminIkdListScreen extends StatefulWidget {
  const AdminIkdListScreen({super.key});

  @override
  State<AdminIkdListScreen> createState() => _AdminIkdListScreenState();
}

class _AdminIkdListScreenState extends State<AdminIkdListScreen> {
  late final AdminIkdProvider _provider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider = AdminIkdProvider();
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
          title: const Text('Data IKD Masuk'),

          // ⬅️ Tombol Back
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
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'all', child: Text('Semua')),
                PopupMenuItem(value: 'pending', child: Text('Menunggu')),
                PopupMenuItem(value: 'approved', child: Text('Disetujui')),
                PopupMenuItem(value: 'scheduled', child: Text('Terjadwal')),
                PopupMenuItem(value: 'rejected', child: Text('Ditolak')),
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

        body: Consumer<AdminIkdProvider>(
          builder: (context, provider, _) {
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

  Widget _buildBody(BuildContext context, AdminIkdProvider provider) {
    if (provider.isLoading && provider.submissions.isEmpty) {
      return const LoadingState(message: 'Memuat data IKD...');
    }

    if (provider.errorMessage != null && provider.submissions.isEmpty) {
      return ErrorState(
        message: provider.errorMessage!,
        onRetry: () => provider.loadSubmissions(refresh: true),
      );
    }

    if (provider.submissions.isEmpty) {
      return EmptyState(
        icon: Icons.smartphone_outlined,
        title: 'Belum Ada Pengajuan',
        description: provider.currentFilter != null
            ? 'Tidak ada pengajuan dengan status "${provider.currentFilter}".'
            : 'Belum ada pengajuan aktivasi IKD yang masuk.',
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
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= provider.submissions.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = provider.submissions[index];
          return _IkdSubmissionCard(
            submission: item,
            onTap: () => context.push('${RoutePaths.adminIkd}/list/${item.id}'),
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
            onPressed: () {
              Navigator.pop(context); // tutup dialog
              context.go(RoutePaths.login); // 🔥 KE HALAMAN LOGIN
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

class _IkdSubmissionCard extends StatelessWidget {
  final IkdSubmission submission;
  final VoidCallback onTap;

  const _IkdSubmissionCard({required this.submission, required this.onTap});

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
                Icons.phone_outlined,
                'Telp: ${submission.nomorTelp}',
              ),
              const SizedBox(height: 4),
              _buildInfoRow(
                Icons.people_outline,
                'Jumlah: ${submission.jumlahPemohon} orang',
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
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
