import 'package:budaya_indonesia/common/static/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light = _buildTheme(Brightness.light);
  static ThemeData dark = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(brightness: brightness);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );

    final textTheme = GoogleFonts.montserratTextTheme(
      isDark ? base.textTheme : base.textTheme,
    );

    return base.copyWith(
      colorScheme: scheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
      ),
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: isDark ? scheme.surface : AppColors.tertiary,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.transparent : AppColors.tertiary,
        foregroundColor: isDark ? scheme.onSurface : Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
      ),
      iconTheme: IconThemeData(
        color: isDark
            ? scheme.onSurfaceVariant
            : Color.alphaBlend(
                Colors.black.withOpacity(.35),
                AppColors.primary,
              ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          final selected = states.contains(MaterialState.selected);
          return selected
              ? AppColors.accent
              : (isDark ? Colors.grey[400] : Colors.white);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          final selected = states.contains(MaterialState.selected);
          if (selected)
            return (isDark ? AppColors.accent : AppColors.primary).withOpacity(
              .5,
            );
          return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
        }),
        trackOutlineColor: MaterialStateProperty.resolveWith((states) {
          final selected = states.contains(MaterialState.selected);
          if (selected)
            return (isDark ? AppColors.accent : AppColors.primary).withOpacity(
              .8,
            );
          return isDark ? Colors.transparent : Colors.grey.shade400;
        }),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
