import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final ThemeData base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.divider,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.textPrimary,
        secondary: AppColors.up,
        surface: AppColors.background,
        error: AppColors.down,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.up,
        selectionColor: Color(0x3322C576),
        selectionHandleColor: AppColors.up,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.sheet,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Color(0x99000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.chip,
        contentTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }
}
