import '../../../shared/layout/dashboard_shell.dart';
import '../../../core/routing/route_paths.dart';

class SuperAdminDashboard extends DashboardShell {
  const SuperAdminDashboard({super.key})
    : super(
        title: 'Dashboard Super Admin',
        menuItems: const [
          DashboardMenuItem(label: 'Admin KTP', route: RoutePaths.adminKtp),
          DashboardMenuItem(label: 'Admin IKD', route: RoutePaths.adminIkd),
          DashboardMenuItem(
            label: 'Admin Perkawinan',
            route: RoutePaths.adminPerkawinan,
          ),
          DashboardMenuItem(
            label: 'Monitoring & Audit',
            route: RoutePaths.adminMonitoring,
          ),
        ],
      );
}
