import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/admin_perkawinan_provider.dart';
import '../model/marriage_registration.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/auth/auth_provider.dart';

/// Admin Perkawinan List Screen - View all public marriage registrations.
class AdminPerkawinanListScreen extends StatefulWidget {
  const AdminPerkawinanListScreen({super.key});

  @override
  State<AdminPerkawinanListScreen> createState() =>
      _AdminPerkawinanListScreenState();
}

class _AdminPerkawinanListScreenState extends State<AdminPerkawinanListScreen> {
  late final AdminPerkawinanProvider _provider;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider = AdminPerkawinanProvider();
    _provider.loadRegistrations(refresh: true);

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
          title: const Text('Data Perkawinan Masuk'),
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
                _provider.loadRegistrations(
                  status: status == 'ALL' ? null : status,
                  refresh: true,
                );
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'ALL', child: Text('Semua')),
                const PopupMenuItem(value: 'PENDING', child: Text('Menunggu')),
                const PopupMenuItem(
                  value: 'VERIFIED',
                  child: Text('Terverifikasi'),
                ),
                const PopupMenuItem(
                  value: 'SCHEDULED',
                  child: Text('Terjadwal'),
                ),
                const PopupMenuItem(value: 'COMPLETED', child: Text('Selesai')),
                const PopupMenuItem(value: 'REJECTED', child: Text('Ditolak')),
              ],
            ),
            // 🔄 Refresh
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Muat Ulang',
              onPressed: () => _provider.loadRegistrations(refresh: true),
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

  Widget _buildBody(BuildContext context, AdminPerkawinanProvider provider) {
    if (provider.isLoading && provider.registrations.isEmpty) {
      return const LoadingState(message: 'Memuat data perkawinan...');
    }

    if (provider.errorMessage != null && provider.registrations.isEmpty) {
      return ErrorState(
        message: provider.errorMessage!,
        onRetry: () => provider.loadRegistrations(refresh: true),
      );
    }

    if (provider.registrations.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_outline,
        title: 'Belum Ada Pendaftaran',
        description: provider.currentFilter != null
            ? 'Tidak ada pendaftaran dengan status "${provider.currentFilter}".'
            : 'Belum ada pendaftaran perkawinan yang masuk.',
        actionLabel: 'Muat Ulang',
        onAction: () => provider.loadRegistrations(refresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadRegistrations(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.registrations.length + (provider.hasMore ? 1 : 0),
        separatorBuilder: (_, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= provider.registrations.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final item = provider.registrations[index];
          return _MarriageCard(
            registration: item,
            onTap: () =>
                context.push('${RoutePaths.adminPerkawinan}/list/${item.uuid}'),
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

class _MarriageCard extends StatelessWidget {
  final MarriageRegistration registration;
  final VoidCallback onTap;

  const _MarriageCard({required this.registration, required this.onTap});

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
                      registration.pasanganNames,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: registration.status),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.badge_outlined,
                'NIK: ${registration.nikPria} / ${registration.nikWanita}',
              ),
              const SizedBox(height: 4),
              _buildInfoRow(
                Icons.calendar_today_outlined,
                'Pengajuan: ${registration.formattedTanggalPengajuan}',
              ),
              if (registration.tanggalNikah != null) ...[
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.favorite_outlined,
                  'Nikah: ${registration.formattedTanggalNikah}',
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
