import 'package:flutter/material.dart';
import '../l10n/public_strings.dart';
import '../provider/public_locale_provider.dart';

/// Language toggle widget for public module.
/// Switches between Indonesian and English.
class LanguageToggle extends StatelessWidget {
  final PublicLocaleProvider localeProvider;

  const LanguageToggle({super.key, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            context,
            label: 'ID',
            isSelected: localeProvider.locale == PublicLocale.id,
            onTap: () => localeProvider.setLocale(PublicLocale.id),
            isLeft: true,
          ),
          _buildOption(
            context,
            label: 'EN',
            isSelected: localeProvider.locale == PublicLocale.en,
            onTap: () => localeProvider.setLocale(PublicLocale.en),
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(18) : Radius.zero,
            right: !isLeft ? const Radius.circular(18) : Radius.zero,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

/// Expanded language toggle with flag icons.
class LanguageToggleExpanded extends StatelessWidget {
  final PublicLocaleProvider localeProvider;

  const LanguageToggleExpanded({super.key, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageButton(
            label: '🇮🇩 Indonesia',
            isSelected: localeProvider.locale == PublicLocale.id,
            onTap: () => localeProvider.setLocale(PublicLocale.id),
          ),
          const SizedBox(width: 4),
          _buildLanguageButton(
            label: '🇬🇧 English',
            isSelected: localeProvider.locale == PublicLocale.en,
            onTap: () => localeProvider.setLocale(PublicLocale.en),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
