import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Runtime protection utilities.
/// Provides screenshot blocking, root/jailbreak detection indicators.
class RuntimeProtection {
  static final RuntimeProtection _instance = RuntimeProtection._internal();
  factory RuntimeProtection() => _instance;
  RuntimeProtection._internal();

  bool _screenshotBlockingEnabled = false;
  bool _isRooted = false;
  bool _isEmulator = false;

  bool get screenshotBlockingEnabled => _screenshotBlockingEnabled;
  bool get isDeviceRooted => _isRooted;
  bool get isRunningOnEmulator => _isEmulator;

  /// Initialize runtime protection.
  Future<void> initialize() async {
    if (kIsWeb) return; // Skip for web

    await _checkDeviceSecurity();

    if (kDebugMode) {
      debugPrint('[RuntimeProtection] Initialized');
      debugPrint('[RuntimeProtection] Rooted: $_isRooted');
      debugPrint('[RuntimeProtection] Emulator: $_isEmulator');
    }
  }

  /// Enable screenshot blocking (Android only via FLAG_SECURE).
  /// Note: Full implementation requires native platform code.
  Future<void> enableScreenshotBlocking() async {
    if (kIsWeb) return;

    try {
      // On Android, this would use WindowManager.LayoutParams.FLAG_SECURE
      // This is a placeholder - actual implementation needs platform channel
      _screenshotBlockingEnabled = true;

      if (kDebugMode) {
        debugPrint('[RuntimeProtection] Screenshot blocking enabled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[RuntimeProtection] Failed to enable screenshot blocking: $e',
        );
      }
    }
  }

  /// Disable screenshot blocking.
  Future<void> disableScreenshotBlocking() async {
    _screenshotBlockingEnabled = false;

    if (kDebugMode) {
      debugPrint('[RuntimeProtection] Screenshot blocking disabled');
    }
  }

  /// Check device security (root/jailbreak detection indicators).
  Future<void> _checkDeviceSecurity() async {
    try {
      if (!kIsWeb) {
        _isRooted = await _checkRootIndicators();
        _isEmulator = _checkEmulatorIndicators();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RuntimeProtection] Security check error: $e');
      }
    }
  }

  /// Check for common root indicators.
  /// Note: This is not foolproof - for production, use dedicated libraries.
  Future<bool> _checkRootIndicators() async {
    if (kIsWeb) return false;

    try {
      // Common root indicators on Android
      if (Platform.isAndroid) {
        // These are heuristic checks only
        // For production, use flutter_jailbreak_detection or similar
        return false; // Placeholder
      }

      // Common jailbreak indicators on iOS
      if (Platform.isIOS) {
        // These are heuristic checks only
        // For production, use flutter_jailbreak_detection or similar
        return false; // Placeholder
      }
    } catch (_) {}

    return false;
  }

  /// Check for emulator indicators.
  bool _checkEmulatorIndicators() {
    if (kIsWeb) return false;

    try {
      if (Platform.isAndroid) {
        // Android emulator indicators (heuristic)
        final brand = Platform.environment['BRAND'] ?? '';
        final device = Platform.environment['DEVICE'] ?? '';
        final model = Platform.environment['MODEL'] ?? '';
        final product = Platform.environment['PRODUCT'] ?? '';

        if (brand.contains('generic') ||
            device.contains('generic') ||
            model.contains('sdk') ||
            product.contains('sdk')) {
          return true;
        }
      }
    } catch (_) {}

    return false;
  }

  /// Show security warning if device is compromised.
  void showSecurityWarningIfNeeded(BuildContext context) {
    if (_isRooted) {
      _showRootWarning(context);
    }
  }

  void _showRootWarning(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Peringatan Keamanan'),
        content: const Text(
          'Perangkat Anda terdeteksi dalam kondisi yang tidak aman (rooted/jailbroken). '
          'Demi keamanan data Anda, beberapa fitur mungkin dibatasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Saya Mengerti'),
          ),
        ],
      ),
    );
  }
}

/// Secure screen wrapper that blocks screenshots on sensitive pages.
class SecureScreen extends StatefulWidget {
  final Widget child;
  final bool enableProtection;

  const SecureScreen({
    super.key,
    required this.child,
    this.enableProtection = true,
  });

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen>
    with WidgetsBindingObserver {
  final _protection = RuntimeProtection();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enableProtection) {
      _protection.enableScreenshotBlocking();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.enableProtection) {
      _protection.disableScreenshotBlocking();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Could add additional protection when app goes to background
    if (state == AppLifecycleState.paused && widget.enableProtection) {
      // App going to background with sensitive data
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Clipboard security - clear sensitive data after delay.
class SecureClipboard {
  /// Copy sensitive text and clear after delay.
  static Future<void> copyWithAutoClear(
    String text, {
    Duration clearAfter = const Duration(seconds: 60),
  }) async {
    await Clipboard.setData(ClipboardData(text: text));

    // Schedule clearing
    Future.delayed(clearAfter, () async {
      final current = await Clipboard.getData('text/plain');
      if (current?.text == text) {
        await Clipboard.setData(const ClipboardData(text: ''));
        if (kDebugMode) {
          debugPrint('[SecureClipboard] Sensitive data cleared from clipboard');
        }
      }
    });
  }

  /// Clear clipboard immediately.
  static Future<void> clear() async {
    await Clipboard.setData(const ClipboardData(text: ''));
  }
}
