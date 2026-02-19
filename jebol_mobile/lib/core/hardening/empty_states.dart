import 'package:flutter/material.dart';

/// Standardized empty state widget for consistent UI.
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize = 80,
  });

  /// Factory for "no data" state.
  factory EmptyStateWidget.noData({
    String title = 'Tidak ada data',
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      title: title,
      subtitle: subtitle ?? 'Data belum tersedia saat ini',
      icon: Icons.inbox_outlined,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Factory for "no results" state (after search).
  factory EmptyStateWidget.noResults({
    String title = 'Tidak ditemukan',
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      title: title,
      subtitle: subtitle ?? 'Coba ubah kata kunci pencarian Anda',
      icon: Icons.search_off,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Factory for "no connection" state.
  factory EmptyStateWidget.noConnection({
    String title = 'Tidak ada koneksi',
    String? subtitle,
    String? actionLabel = 'Coba Lagi',
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      title: title,
      subtitle: subtitle ?? 'Periksa koneksi internet Anda',
      icon: Icons.wifi_off,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Factory for "error" state.
  factory EmptyStateWidget.error({
    String title = 'Terjadi Kesalahan',
    String? subtitle,
    String? actionLabel = 'Coba Lagi',
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      title: title,
      subtitle: subtitle ?? 'Silakan coba beberapa saat lagi',
      icon: Icons.error_outline,
      actionLabel: actionLabel,
      onAction: onAction,
      iconColor: Colors.red,
    );
  }

  /// Factory for "no permission" state.
  factory EmptyStateWidget.noPermission({
    String title = 'Akses Ditolak',
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      title: title,
      subtitle: subtitle ?? 'Anda tidak memiliki izin untuk mengakses ini',
      icon: Icons.lock_outline,
      actionLabel: actionLabel,
      onAction: onAction,
      iconColor: Colors.orange,
    );
  }

  /// Factory for "coming soon" state.
  factory EmptyStateWidget.comingSoon({
    String title = 'Segera Hadir',
    String? subtitle,
  }) {
    return EmptyStateWidget(
      title: title,
      subtitle: subtitle ?? 'Fitur ini sedang dalam pengembangan',
      icon: Icons.hourglass_empty,
      iconColor: Colors.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? colorScheme.outline.withAlpha(128),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standardized loading widget.
class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool compact;

  const LoadingWidget({super.key, this.message, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            if (message != null) ...[const SizedBox(width: 12), Text(message!)],
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Error widget with retry option.
class ErrorWidget2 extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;

  const ErrorWidget2({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
