// Role Permission Verification Matrix
// This test file verifies that all roles have correct access permissions

import 'package:flutter_test/flutter_test.dart';

/// Defines all roles in the JEBOL system
enum UserRole {
  superAdmin,
  adminKtp,
  adminIkd,
  adminNikah,
  rt,
  publicUser, // No authentication
}

/// Defines all features/routes in the system
enum AppFeature {
  // Public Features (NO AUTH)
  publicHome,
  publicMarriageForm,
  publicTracking,

  // Dashboard
  dashboard,

  // KTP Module
  ktpList,
  ktpCreate,
  ktpEdit,
  ktpDelete,
  ktpApprove,
  ktpExport,

  // IKD Module (Kartu Identitas Digital)
  ikdList,
  ikdCreate,
  ikdApprove,
  ikdExport,

  // Marriage Module
  marriageList,
  marriageCreate,
  marriageEdit,
  marriageApprove,
  marriageSchedule,
  marriageExport,

  // RT Module
  rtRecommendationCreate,
  rtRecommendationList,
  rtResidentList,

  // Admin Features
  userManagement,
  roleManagement,
  auditLog,
  systemSettings,
}

/// Permission matrix defining role access
class PermissionMatrix {
  static const Map<UserRole, Set<AppFeature>> permissions = {
    // Super Admin - Full Access
    UserRole.superAdmin: {
      AppFeature.publicHome,
      AppFeature.publicMarriageForm,
      AppFeature.publicTracking,
      AppFeature.dashboard,
      AppFeature.ktpList,
      AppFeature.ktpCreate,
      AppFeature.ktpEdit,
      AppFeature.ktpDelete,
      AppFeature.ktpApprove,
      AppFeature.ktpExport,
      AppFeature.ikdList,
      AppFeature.ikdCreate,
      AppFeature.ikdApprove,
      AppFeature.ikdExport,
      AppFeature.marriageList,
      AppFeature.marriageCreate,
      AppFeature.marriageEdit,
      AppFeature.marriageApprove,
      AppFeature.marriageSchedule,
      AppFeature.marriageExport,
      AppFeature.rtRecommendationCreate,
      AppFeature.rtRecommendationList,
      AppFeature.rtResidentList,
      AppFeature.userManagement,
      AppFeature.roleManagement,
      AppFeature.auditLog,
      AppFeature.systemSettings,
    },

    // Admin KTP - KTP Management Only
    UserRole.adminKtp: {
      AppFeature.publicHome,
      AppFeature.publicMarriageForm,
      AppFeature.publicTracking,
      AppFeature.dashboard,
      AppFeature.ktpList,
      AppFeature.ktpCreate,
      AppFeature.ktpEdit,
      AppFeature.ktpApprove,
      AppFeature.ktpExport,
    },

    // Admin IKD - Digital ID Management
    UserRole.adminIkd: {
      AppFeature.publicHome,
      AppFeature.publicMarriageForm,
      AppFeature.publicTracking,
      AppFeature.dashboard,
      AppFeature.ikdList,
      AppFeature.ikdCreate,
      AppFeature.ikdApprove,
      AppFeature.ikdExport,
    },

    // Admin Nikah - Marriage Management
    UserRole.adminNikah: {
      AppFeature.publicHome,
      AppFeature.publicMarriageForm,
      AppFeature.publicTracking,
      AppFeature.dashboard,
      AppFeature.marriageList,
      AppFeature.marriageCreate,
      AppFeature.marriageEdit,
      AppFeature.marriageApprove,
      AppFeature.marriageSchedule,
      AppFeature.marriageExport,
    },

    // RT - Local Recommendation
    UserRole.rt: {
      AppFeature.publicHome,
      AppFeature.publicMarriageForm,
      AppFeature.publicTracking,
      AppFeature.dashboard,
      AppFeature.rtRecommendationCreate,
      AppFeature.rtRecommendationList,
      AppFeature.rtResidentList,
    },

    // Public User - NO AUTH, Public Features Only
    UserRole.publicUser: {
      AppFeature.publicHome,
      AppFeature.publicMarriageForm,
      AppFeature.publicTracking,
    },
  };

  /// Check if a role has access to a feature
  static bool hasAccess(UserRole role, AppFeature feature) {
    return permissions[role]?.contains(feature) ?? false;
  }

  /// Get all features a role can access
  static Set<AppFeature> getFeaturesForRole(UserRole role) {
    return permissions[role] ?? {};
  }

  /// Get all roles that can access a feature
  static Set<UserRole> getRolesForFeature(AppFeature feature) {
    return permissions.entries
        .where((entry) => entry.value.contains(feature))
        .map((entry) => entry.key)
        .toSet();
  }
}

void main() {
  group('Role Permission Matrix Verification', () {
    group('Super Admin Permissions', () {
      test('Super Admin has access to all features', () {
        for (final feature in AppFeature.values) {
          expect(
            PermissionMatrix.hasAccess(UserRole.superAdmin, feature),
            isTrue,
            reason: 'Super Admin should have access to ${feature.name}',
          );
        }
      });

      test('Super Admin can manage users', () {
        expect(
          PermissionMatrix.hasAccess(
            UserRole.superAdmin,
            AppFeature.userManagement,
          ),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.superAdmin,
            AppFeature.roleManagement,
          ),
          isTrue,
        );
      });

      test('Super Admin can access audit logs', () {
        expect(
          PermissionMatrix.hasAccess(UserRole.superAdmin, AppFeature.auditLog),
          isTrue,
        );
      });
    });

    group('Admin KTP Permissions', () {
      test('Admin KTP can manage KTP operations', () {
        expect(
          PermissionMatrix.hasAccess(UserRole.adminKtp, AppFeature.ktpList),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.adminKtp, AppFeature.ktpCreate),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.adminKtp, AppFeature.ktpEdit),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.adminKtp, AppFeature.ktpApprove),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.adminKtp, AppFeature.ktpExport),
          isTrue,
        );
      });

      test('Admin KTP cannot manage IKD', () {
        expect(
          PermissionMatrix.hasAccess(UserRole.adminKtp, AppFeature.ikdList),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.adminKtp, AppFeature.ikdCreate),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.adminKtp, AppFeature.ikdApprove),
          isFalse,
        );
      });

      test('Admin KTP cannot manage Marriage', () {
        expect(
          PermissionMatrix.hasAccess(
            UserRole.adminKtp,
            AppFeature.marriageList,
          ),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.adminKtp,
            AppFeature.marriageApprove,
          ),
          isFalse,
        );
      });

      test('Admin KTP cannot delete KTP', () {
        expect(
          PermissionMatrix.hasAccess(UserRole.adminKtp, AppFeature.ktpDelete),
          isFalse,
        );
      });

      test('Admin KTP cannot manage users', () {
        expect(
          PermissionMatrix.hasAccess(
            UserRole.adminKtp,
            AppFeature.userManagement,
          ),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.adminKtp,
            AppFeature.roleManagement,
          ),
          isFalse,
        );
      });
    });

    group('Admin IKD Permissions', () {
      test('Admin IKD can manage IKD operations', () {
        expect(
          PermissionMatrix.hasAccess(UserRole.adminIkd, AppFeature.ikdList),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.adminIkd, AppFeature.ikdCreate),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.adminIkd, AppFeature.ikdApprove),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.adminIkd, AppFeature.ikdExport),
          isTrue,
        );
      });

      test('Admin IKD cannot manage KTP', () {
        expect(
          PermissionMatrix.hasAccess(UserRole.adminIkd, AppFeature.ktpList),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.adminIkd, AppFeature.ktpCreate),
          isFalse,
        );
      });

      test('Admin IKD cannot manage Marriage', () {
        expect(
          PermissionMatrix.hasAccess(
            UserRole.adminIkd,
            AppFeature.marriageList,
          ),
          isFalse,
        );
      });
    });

    group('Admin Nikah Permissions', () {
      test('Admin Nikah can manage Marriage operations', () {
        expect(
          PermissionMatrix.hasAccess(
            UserRole.adminNikah,
            AppFeature.marriageList,
          ),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.adminNikah,
            AppFeature.marriageCreate,
          ),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.adminNikah,
            AppFeature.marriageEdit,
          ),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.adminNikah,
            AppFeature.marriageApprove,
          ),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.adminNikah,
            AppFeature.marriageSchedule,
          ),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.adminNikah,
            AppFeature.marriageExport,
          ),
          isTrue,
        );
      });

      test('Admin Nikah cannot manage KTP or IKD', () {
        expect(
          PermissionMatrix.hasAccess(UserRole.adminNikah, AppFeature.ktpList),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.adminNikah, AppFeature.ikdList),
          isFalse,
        );
      });
    });

    group('RT Permissions', () {
      test('RT can manage recommendations', () {
        expect(
          PermissionMatrix.hasAccess(
            UserRole.rt,
            AppFeature.rtRecommendationCreate,
          ),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.rt,
            AppFeature.rtRecommendationList,
          ),
          isTrue,
        );
      });

      test('RT can view resident list', () {
        expect(
          PermissionMatrix.hasAccess(UserRole.rt, AppFeature.rtResidentList),
          isTrue,
        );
      });

      test('RT cannot manage KTP/IKD/Marriage directly', () {
        expect(
          PermissionMatrix.hasAccess(UserRole.rt, AppFeature.ktpApprove),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.rt, AppFeature.ikdApprove),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.rt, AppFeature.marriageApprove),
          isFalse,
        );
      });

      test('RT cannot access admin features', () {
        expect(
          PermissionMatrix.hasAccess(UserRole.rt, AppFeature.userManagement),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.rt, AppFeature.systemSettings),
          isFalse,
        );
      });
    });

    group('Public User Permissions (CRITICAL)', () {
      test('Public user can access public features without auth', () {
        expect(
          PermissionMatrix.hasAccess(
            UserRole.publicUser,
            AppFeature.publicHome,
          ),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.publicUser,
            AppFeature.publicMarriageForm,
          ),
          isTrue,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.publicUser,
            AppFeature.publicTracking,
          ),
          isTrue,
        );
      });

      test('Public user CANNOT access any authenticated features', () {
        // Dashboard
        expect(
          PermissionMatrix.hasAccess(UserRole.publicUser, AppFeature.dashboard),
          isFalse,
        );

        // KTP
        expect(
          PermissionMatrix.hasAccess(UserRole.publicUser, AppFeature.ktpList),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.publicUser, AppFeature.ktpCreate),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.publicUser,
            AppFeature.ktpApprove,
          ),
          isFalse,
        );

        // IKD
        expect(
          PermissionMatrix.hasAccess(UserRole.publicUser, AppFeature.ikdList),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.publicUser,
            AppFeature.ikdApprove,
          ),
          isFalse,
        );

        // Marriage Admin
        expect(
          PermissionMatrix.hasAccess(
            UserRole.publicUser,
            AppFeature.marriageList,
          ),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.publicUser,
            AppFeature.marriageApprove,
          ),
          isFalse,
        );

        // RT
        expect(
          PermissionMatrix.hasAccess(
            UserRole.publicUser,
            AppFeature.rtRecommendationList,
          ),
          isFalse,
        );

        // Admin
        expect(
          PermissionMatrix.hasAccess(
            UserRole.publicUser,
            AppFeature.userManagement,
          ),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(UserRole.publicUser, AppFeature.auditLog),
          isFalse,
        );
        expect(
          PermissionMatrix.hasAccess(
            UserRole.publicUser,
            AppFeature.systemSettings,
          ),
          isFalse,
        );
      });

      test('Public user has EXACTLY 3 features', () {
        final publicFeatures = PermissionMatrix.getFeaturesForRole(
          UserRole.publicUser,
        );
        expect(publicFeatures.length, 3);
        expect(
          publicFeatures,
          containsAll([
            AppFeature.publicHome,
            AppFeature.publicMarriageForm,
            AppFeature.publicTracking,
          ]),
        );
      });
    });

    group('Feature Access by Role', () {
      test('User management is Super Admin only', () {
        final rolesWithUserManagement = PermissionMatrix.getRolesForFeature(
          AppFeature.userManagement,
        );
        expect(rolesWithUserManagement.length, 1);
        expect(rolesWithUserManagement.first, UserRole.superAdmin);
      });

      test('Public features are accessible by all roles', () {
        for (final feature in [
          AppFeature.publicHome,
          AppFeature.publicMarriageForm,
          AppFeature.publicTracking,
        ]) {
          final roles = PermissionMatrix.getRolesForFeature(feature);
          expect(
            roles.length,
            UserRole.values.length,
            reason: '${feature.name} should be accessible by all roles',
          );
        }
      });

      test('Dashboard requires authentication', () {
        final rolesWithDashboard = PermissionMatrix.getRolesForFeature(
          AppFeature.dashboard,
        );
        expect(rolesWithDashboard.contains(UserRole.publicUser), isFalse);
      });
    });

    group('Permission Isolation Tests', () {
      test('Each admin role has distinct feature set', () {
        final ktpFeatures = PermissionMatrix.getFeaturesForRole(
          UserRole.adminKtp,
        );
        final ikdFeatures = PermissionMatrix.getFeaturesForRole(
          UserRole.adminIkd,
        );
        final nikahFeatures = PermissionMatrix.getFeaturesForRole(
          UserRole.adminNikah,
        );

        // Remove common features (public + dashboard)
        final commonFeatures = {
          AppFeature.publicHome,
          AppFeature.publicMarriageForm,
          AppFeature.publicTracking,
          AppFeature.dashboard,
        };

        final ktpOnly = ktpFeatures.difference(commonFeatures);
        final ikdOnly = ikdFeatures.difference(commonFeatures);
        final nikahOnly = nikahFeatures.difference(commonFeatures);

        // No overlap in specific features
        expect(ktpOnly.intersection(ikdOnly), isEmpty);
        expect(ktpOnly.intersection(nikahOnly), isEmpty);
        expect(ikdOnly.intersection(nikahOnly), isEmpty);
      });

      test('RT cannot escalate to admin features', () {
        final rtFeatures = PermissionMatrix.getFeaturesForRole(UserRole.rt);

        // RT should not have any admin-level features
        expect(rtFeatures.contains(AppFeature.userManagement), isFalse);
        expect(rtFeatures.contains(AppFeature.roleManagement), isFalse);
        expect(rtFeatures.contains(AppFeature.systemSettings), isFalse);
        expect(rtFeatures.contains(AppFeature.auditLog), isFalse);
      });
    });

    group('Critical Security Tests', () {
      test('KTP delete is Super Admin only', () {
        for (final role in UserRole.values) {
          if (role == UserRole.superAdmin) {
            expect(
              PermissionMatrix.hasAccess(role, AppFeature.ktpDelete),
              isTrue,
            );
          } else {
            expect(
              PermissionMatrix.hasAccess(role, AppFeature.ktpDelete),
              isFalse,
              reason: '${role.name} should NOT be able to delete KTP',
            );
          }
        }
      });

      test('System settings is Super Admin only', () {
        final rolesWithSettings = PermissionMatrix.getRolesForFeature(
          AppFeature.systemSettings,
        );
        expect(rolesWithSettings.length, 1);
        expect(rolesWithSettings.first, UserRole.superAdmin);
      });

      test('Audit log is Super Admin only', () {
        final rolesWithAudit = PermissionMatrix.getRolesForFeature(
          AppFeature.auditLog,
        );
        expect(rolesWithAudit.length, 1);
        expect(rolesWithAudit.first, UserRole.superAdmin);
      });
    });
  });
}
