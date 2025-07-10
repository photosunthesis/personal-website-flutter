import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  double get defaultBodyFontSize => textTheme.titleLarge!.fontSize!;

  double get screenWidth => MediaQuery.of(this).size.width;
}
