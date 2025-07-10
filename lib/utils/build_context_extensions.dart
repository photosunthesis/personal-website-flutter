import 'package:flutter/material.dart';
import 'package:sun_envidiado_website/constants/screen_widths.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns a scaled body font size based on the screen width.
  ///
  /// The scaling factor is determined by the screen width:
  /// - For mobile screens, the font size is reduced by 30%.
  /// - For tablet screens, the font size remains unchanged.
  /// - For larger screens, the font size remains unchanged.
  double get scaledBodyFontSize {
    final scaleFactor = switch (screenWidth) {
      < ScreenWidths.mobile => 0.8,
      < ScreenWidths.tablet => 1.0,
      // TODO Handle other sizes
      _ => 1.0,
    };

    return (textTheme.titleLarge?.fontSize ?? 16.0) * scaleFactor;
  }
}
