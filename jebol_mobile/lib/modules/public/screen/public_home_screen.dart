import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/public_locale_provider.dart';
import '../widgets/public_app_bar.dart';

/// Public home screen - Landing page for citizens.
/// NO authentication required. Completely isolated.
class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PublicLocaleProvider(),
      child: const _PublicHomeContent(),
    );
  }
}

class _PublicHomeContent extends StatelessWidget {
  const _PublicHomeContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicLocaleProvider>(
      builder: (context, locale, _) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with government branding
                  PublicHeader(localeProvider: locale),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Welcome section
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: 48,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  locale.tr('home_welcome'),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  locale.tr('home_description'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Main actions
                        _buildActionButton(
                          context,
                          icon: Icons.edit_document,
                          title: locale.tr('home_start_registration'),
                          subtitle: locale.isIndonesian
                              ? 'Daftar perkawinan baru'
                              : 'Register new marriage',
                          color: const Color(0xFF1565C0),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/public/marriage/form',
                              arguments: locale,
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildActionButton(
                          context,
                          icon: Icons.search,
                          title: locale.tr('home_check_status'),
                          subtitle: locale.isIndonesian
                              ? 'Lacak dengan nomor pendaftaran'
                              : 'Track with registration number',
                          color: Colors.teal,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/public/marriage/track',
                              arguments: locale,
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Info section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.amber.shade800,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    locale.tr('home_info_title'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoItem(locale.tr('home_info_1')),
                              _buildInfoItem(locale.tr('home_info_2')),
                              _buildInfoItem(locale.tr('home_info_3')),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Footer
                        Text(
                          '© 2025 Dinas Kependudukan dan Pencatatan Sipil',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.amber.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
