import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/routing/route_paths.dart';
import 'package:go_router/go_router.dart';

class DashboardMenuItem {
  final String label;
  final String? route;

  const DashboardMenuItem({required this.label, this.route});
}

class DashboardShell extends StatelessWidget {
  final String title;
  final List<DashboardMenuItem> menuItems;

  const DashboardShell({
    super.key,
    required this.title,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
        // ⬅️ Tombol Kembali
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali',
          onPressed: () => _handleBack(context),
        ),
        // 🚪 Tombol Logout
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Menu Utama', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: menuItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final isEnabled = item.route != null;
                  return Card(
                    child: ListTile(
                      title: Text(item.label),
                      subtitle: Text(isEnabled ? 'Buka' : 'Belum tersedia'),
                      trailing: Icon(
                        isEnabled
                            ? Icons.arrow_forward_ios
                            : Icons.lock_outline,
                      ),
                      onTap: isEnabled ? () => context.push(item.route!) : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    }
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
}
