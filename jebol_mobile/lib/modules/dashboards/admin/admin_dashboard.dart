import '../../../shared/layout/dashboard_shell.dart';
import '../../../core/routing/route_paths.dart';

class AdminKtpDashboard extends DashboardShell {
  const AdminKtpDashboard({super.key})
    : super(
        title: 'Dashboard Admin KTP',
        menuItems: const [
          DashboardMenuItem(
            label: 'Verifikasi',
            route: '${RoutePaths.adminKtp}/list',
          ),
          DashboardMenuItem(label: 'Jadwal'),
        ],
      );
}

class AdminIkdDashboard extends DashboardShell {
  const AdminIkdDashboard({super.key})
    : super(
        title: 'Dashboard Admin IKD',
        menuItems: const [
          DashboardMenuItem(
            label: 'Aktivasi',
            route: '${RoutePaths.adminIkd}/list',
          ),
          DashboardMenuItem(label: 'Jadwal'),
        ],
      );
}

class AdminPerkawinanDashboard extends DashboardShell {
  const AdminPerkawinanDashboard({super.key})
    : super(
        title: 'Dashboard Admin Perkawinan',
        menuItems: const [
          DashboardMenuItem(
            label: 'Data Masuk',
            route: '${RoutePaths.adminPerkawinan}/list',
          ),
          DashboardMenuItem(
            label: 'Approval & Jadwal',
            route: RoutePaths.adminApproval,
          ),
        ],
      );
}
