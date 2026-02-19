import '../../../shared/layout/dashboard_shell.dart';
import '../../../core/routing/route_paths.dart';

class PetugasDashboard extends DashboardShell {
  const PetugasDashboard({super.key})
    : super(
        title: 'Dashboard Petugas Lapangan',
        menuItems: const [
          DashboardMenuItem(label: 'Form KTP', route: RoutePaths.rtKtpForm),
          DashboardMenuItem(label: 'Form IKD', route: RoutePaths.rtIkdForm),
          DashboardMenuItem(label: 'Agenda', route: RoutePaths.rtSchedule),
        ],
      );
}
