import 'package:flutter/material.dart';
import 'package:sun_envidiado_website/app/app_colors.dart';

final appTheme = ThemeData.dark().copyWith(
  colorScheme: _colorScheme,
  textTheme: _textTheme,
  scaffoldBackgroundColor: _colorScheme.surface,
);

final _textTheme = Typography.material2021().white.apply(
  fontFamily: 'IBM VGA 8',
);

final _colorScheme = const ColorScheme.dark(
  brightness: Brightness.dark,
  primary: AppColors.white,
  onPrimary: AppColors.black,
  secondary: AppColors.green,
  tertiary: AppColors.cyan,
  onSecondary: AppColors.black,
  error: AppColors.red,
  onError: AppColors.white,
  surface: AppColors.black,
  onSurface: AppColors.white,
  surfaceContainerHighest: AppColors.gray,
  onSurfaceVariant: AppColors.lightGray,
);
