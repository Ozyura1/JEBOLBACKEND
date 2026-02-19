import '../../../shared/layout/dashboard_shell.dart';
import '../../../core/routing/route_paths.dart';

class PublicDashboard extends DashboardShell {
  const PublicDashboard({super.key})
    : super(
        title: 'Dashboard Publik',
        menuItems: const [
          DashboardMenuItem(
            label: 'Pendaftaran Perkawinan',
            route: RoutePaths.publicMarriageRegistration,
          ),
        ],
      );
}
