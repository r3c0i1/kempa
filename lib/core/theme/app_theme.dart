import 'package:flutter/material.dart';
import 'package:kempa/core/theme/theme_block.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light = _buildTheme(AppColors.light);
  static ThemeData dark = _buildTheme(AppColors.dark);
  static ThemeData helloKitty = _buildFunTheme(AppColors.helloKitty, roundness: 20);
  static ThemeData hacker = _buildTheme(AppColors.hacker);
  static ThemeData vaporwave = _buildTheme(AppColors.vaporwave);
  static ThemeData sakura = _buildFunTheme(AppColors.sakura, roundness: 16);
  static ThemeData pepe = _buildTheme(AppColors.pepe);
  static ThemeData ocean = _buildTheme(AppColors.ocean);
  static ThemeData halloween = _buildTheme(AppColors.halloween);
  static ThemeData doge = _buildFunTheme(AppColors.doge, roundness: 24);

  // Получить тему по enum
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light: return light;
      case AppThemeMode.dark: return dark;
      case AppThemeMode.helloKitty: return helloKitty;
      case AppThemeMode.hacker: return hacker;
      case AppThemeMode.vaporwave: return vaporwave;
      case AppThemeMode.sakura: return sakura;
      case AppThemeMode.pepe: return pepe;
      case AppThemeMode.ocean: return ocean;
      case AppThemeMode.halloween: return halloween;
      case AppThemeMode.doge: return doge;
      case AppThemeMode.system: return light;
    }
  }

  static ThemeData _buildTheme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: scheme.surface,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: scheme.surface,
        indicatorColor: Colors.transparent,

        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.onSurface);
          }
          return IconThemeData(color: scheme.onSurfaceVariant);
        }),

        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: scheme.onSurface);
          }
          return TextStyle(color: scheme.onSurfaceVariant);
        }),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outline,
        thickness: 1,
      ),
    );
  }

  // Для "весёлых" тем — более круглые формы
  static ThemeData _buildFunTheme(ColorScheme scheme, {double roundness = 16}) {
    final base = _buildTheme(scheme);

    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(roundness),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(roundness),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(roundness),
          side: BorderSide(color: scheme.outline),
        ),
      ),
    );
  }
}