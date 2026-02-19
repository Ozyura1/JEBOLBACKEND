import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Accessibility utilities for ensuring proper font scaling and contrast.
class AccessibilityUtils {
  /// Minimum contrast ratio for WCAG AA compliance (normal text).
  static const double wcagAANormalText = 4.5;

  /// Minimum contrast ratio for WCAG AA compliance (large text).
  static const double wcagAALargeText = 3.0;

  /// Minimum contrast ratio for WCAG AAA compliance (normal text).
  static const double wcagAAANormalText = 7.0;

  /// Calculate relative luminance of a color.
  static double relativeLuminance(Color color) {
    double r = (color.r * 255.0).round().clamp(0, 255) / 255;
    double g = (color.g * 255.0).round().clamp(0, 255) / 255;
    double b = (color.b * 255.0).round().clamp(0, 255) / 255;

    r = r <= 0.03928 ? r / 12.92 : ((r + 0.055) / 1.055);
    g = g <= 0.03928 ? g / 12.92 : ((g + 0.055) / 1.055);
    b = b <= 0.03928 ? b / 12.92 : ((b + 0.055) / 1.055);

    r = r <= 0.03928 ? r : _pow(r, 2.4);
    g = g <= 0.03928 ? g : _pow(g, 2.4);
    b = b <= 0.03928 ? b : _pow(b, 2.4);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _pow(double x, double n) {
    double result = 1;
    for (int i = 0; i < n.toInt(); i++) {
      result *= x;
    }
    // Handle fractional part
    if (n != n.toInt()) {
      result *= _nthRoot(x, (1 / (n - n.toInt())).toInt());
    }
    return result;
  }

  static double _nthRoot(double x, int n) {
    if (n == 0) return 1;
    double low = 0;
    double high = x;
    for (int i = 0; i < 100; i++) {
      double mid = (low + high) / 2;
      double val = 1;
      for (int j = 0; j < n; j++) {
        val *= mid;
      }
      if (val < x) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return (low + high) / 2;
  }

  /// Calculate contrast ratio between two colors.
  static double contrastRatio(Color foreground, Color background) {
    final l1 = relativeLuminance(foreground);
    final l2 = relativeLuminance(background);

    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if color combination meets WCAG AA for normal text.
  static bool meetsWcagAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= wcagAANormalText;
  }

  /// Check if color combination meets WCAG AA for large text.
  static bool meetsWcagAALargeText(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= wcagAALargeText;
  }

  /// Get the better contrasting color (black or white) for given background.
  static Color getContrastingTextColor(Color background) {
    final luminance = relativeLuminance(background);
    return luminance > 0.179 ? Colors.black : Colors.white;
  }

  /// Ensure text color has sufficient contrast against background.
  static Color ensureContrast(
    Color textColor,
    Color background, {
    double minRatio = wcagAANormalText,
  }) {
    final ratio = contrastRatio(textColor, background);
    if (ratio >= minRatio) return textColor;

    // Return black or white depending on background
    return getContrastingTextColor(background);
  }
}

/// Widget that respects system font scaling with optional limits.
class ScalableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double minScale;
  final double maxScale;
  final bool semanticsLabel;

  const ScalableText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.minScale = 0.8,
    this.maxScale = 1.5,
    this.semanticsLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler;

    // Clamp the scale factor
    final scaleFactor = textScaler.scale(1.0).clamp(minScale, maxScale);

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.linear(scaleFactor)),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        semanticsLabel: semanticsLabel ? text : null,
      ),
    );
  }
}

/// Extension on TextStyle for accessibility.
extension AccessibleTextStyle on TextStyle {
  /// Ensure minimum font size for readability.
  TextStyle ensureMinFontSize([double minSize = 12]) {
    if (fontSize == null || fontSize! < minSize) {
      return copyWith(fontSize: minSize);
    }
    return this;
  }

  /// Ensure text has sufficient contrast against background.
  TextStyle ensureContrast(Color background) {
    final effectiveColor = color ?? Colors.black;
    final contrastingColor = AccessibilityUtils.ensureContrast(
      effectiveColor,
      background,
    );
    if (contrastingColor != effectiveColor) {
      return copyWith(color: contrastingColor);
    }
    return this;
  }
}

/// Accessible button that ensures touch target size.
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final double minTouchTargetSize;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.minTouchTargetSize = 48, // WCAG minimum
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: InkWell(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minTouchTargetSize,
            minHeight: minTouchTargetSize,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Mixin for pages to handle keyboard avoiding.
mixin KeyboardAvoiding<T extends StatefulWidget> on State<T> {
  /// Scroll controller for keyboard avoiding.
  ScrollController get keyboardScrollController;

  /// Focus node that's currently focused.
  FocusNode? _currentFocus;

  /// Register a focus node for keyboard avoiding.
  void registerFocusNode(FocusNode node) {
    node.addListener(() {
      if (node.hasFocus) {
        _currentFocus = node;
        _scrollToFocus();
      }
    });
  }

  void _scrollToFocus() {
    // Delay to allow keyboard to appear
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentFocus?.context != null && mounted) {
        Scrollable.ensureVisible(
          _currentFocus!.context!,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
    });
  }
}

/// Widget to ensure content is above keyboard.
class KeyboardSafeArea extends StatelessWidget {
  final Widget child;
  final double extraPadding;

  const KeyboardSafeArea({
    super.key,
    required this.child,
    this.extraPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset + extraPadding : 0,
      ),
      child: child,
    );
  }
}

/// System UI overlay helper for consistent styling.
class SystemUIHelper {
  /// Set system UI for light theme.
  static void setLightTheme() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Set system UI for dark theme.
  static void setDarkTheme() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// Set system UI based on theme brightness.
  static void setFromBrightness(Brightness brightness) {
    if (brightness == Brightness.light) {
      setLightTheme();
    } else {
      setDarkTheme();
    }
  }
}
