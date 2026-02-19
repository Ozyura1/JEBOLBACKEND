class RoutePaths {
  // System routes
  static const login = '/login';
  static const unauthorized = '/unauthorized';
  static const notFound = '/not-found';
  static const forbidden = '/forbidden';

  // Public routes (no authentication)
  static const publicBase = '/public';
  static const publicMarriageRegistration = '/public/perkawinan';
  static const publicMarriageStatus = '/public/perkawinan/status';
  static const publicDashboard = '/public/dashboard';

  // RT routes
  static const rtBase = '/rt';
  static const rtDashboard = '/rt/dashboard';
  static const rtKtpForm = '/rt/ktp';
  static const rtIkdForm = '/rt/ikd';
  static const rtSchedule = '/rt/schedule';
  static const rtVerificationList = '/rt/verification';
  static const rtVerificationDetail = '/rt/verification/:id';

  // Admin routes
  static const adminBase = '/admin';
  static const superAdmin = '/admin/super';
  static const adminMonitoring = '/admin/monitoring';

  // Admin KTP routes
  static const adminKtp = '/admin/ktp';
  static const adminKtpList = '/admin/ktp/list';
  static const adminKtpDetail = '/admin/ktp/:id';

  // Admin IKD routes
  static const adminIkd = '/admin/ikd';
  static const adminIkdList = '/admin/ikd/list';
  static const adminIkdDetail = '/admin/ikd/:id';

  // Admin Perkawinan routes
  static const adminPerkawinan = '/admin/perkawinan';
  static const adminPerkawinanList = '/admin/perkawinan/list';
  static const adminPerkawinanDetail = '/admin/perkawinan/:uuid';
  static const adminApproval = '/admin/perkawinan/approval';
}
