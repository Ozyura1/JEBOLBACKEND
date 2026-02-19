import 'package:flutter/material.dart';
import '../provider/public_locale_provider.dart';
import 'language_toggle.dart';

/// Public app bar - completely isolated from admin app bar.
/// Has language toggle built-in.
class PublicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final PublicLocaleProvider localeProvider;
  final bool showLanguageToggle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const PublicAppBar({
    super.key,
    required this.title,
    required this.localeProvider,
    this.showLanguageToggle = true,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: const Color(0xFF1565C0),
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        if (showLanguageToggle)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: LanguageToggle(localeProvider: localeProvider),
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Government-branded header for public screens.
class PublicHeader extends StatelessWidget {
  final PublicLocaleProvider localeProvider;

  const PublicHeader({super.key, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Government logo placeholder
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Color(0xFF1565C0),
                    size: 30,
                  ),
                ),
                LanguageToggle(localeProvider: localeProvider),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              localeProvider.tr('app_title'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              localeProvider.tr('app_subtitle'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
