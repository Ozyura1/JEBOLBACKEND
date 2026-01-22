import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JEBOL - Jemput Bola'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        actions: [
          if (user != null && user.role != UserRole.public)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang, ${user?.username ?? 'Pengguna Publik'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Role: ${user?.role.displayName ?? 'Public'}',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            const Text(
              'Menu Utama:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(children: _buildMenuItems(context, user?.role)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, UserRole? role) {
    final items = <Widget>[];

    // Common items
    items.add(
      _MenuItem(
        title: 'Informasi Umum',
        subtitle: 'Informasi layanan Dinas Kependudukan',
        onTap: () => context.go('/info'),
      ),
    );

    // Role-based items
    if (role == UserRole.superAdmin) {
      items.addAll([
        _MenuItem(
          title: 'Manajemen Admin',
          subtitle: 'Kelola semua admin',
          onTap: () => context.go('/super-admin'),
        ),
      ]);
    } else if (role == UserRole.admin1) {
      items.addAll([
        _MenuItem(
          title: 'Pembuatan KTP',
          subtitle: 'Proses permohonan KTP baru',
          onTap: () => context.go('/admin1/ktp'),
        ),
      ]);
    } else if (role == UserRole.admin2) {
      items.addAll([
        _MenuItem(
          title: 'Aktivasi IKD',
          subtitle: 'Aktivasi Identitas Kependudukan Digital',
          onTap: () => context.go('/admin2/ikd'),
        ),
      ]);
    } else if (role == UserRole.admin3) {
      items.addAll([
        _MenuItem(
          title: 'Pencatatan Perkawinan',
          subtitle: 'Proses pencatatan pernikahan',
          onTap: () => context.go('/admin3/perkawinan'),
        ),
      ]);
    } else if (role == UserRole.rt) {
      items.addAll([
        _MenuItem(
          title: 'Verifikasi RT',
          subtitle: 'Verifikasi data warga',
          onTap: () => context.go('/rt/verification'),
        ),
      ]);
    } else if (role == UserRole.public) {
      items.addAll([
        _MenuItem(
          title: 'Permohonan Layanan',
          subtitle: 'Ajukan permohonan KTP, KK, dll.',
          onTap: () => context.go('/public/request'),
        ),
        _MenuItem(
          title: 'Cek Status',
          subtitle: 'Cek status permohonan',
          onTap: () => context.go('/public/status'),
        ),
      ]);
    }

    return items;
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
