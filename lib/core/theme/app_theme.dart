import 'package:candle_ledger/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: const TextStyle(
              color: AppColors.textDarkPrimary,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: const TextStyle(color: AppColors.textDarkPrimary),
            bodyMedium: const TextStyle(color: AppColors.textDarkSecondary),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        headerBackgroundColor: AppColors.secondary,
        headerForegroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        dividerColor: Colors.white.withValues(alpha: 0.1),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.black;
          return Colors.white;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.secondary;
          }
          return null;
        }),
        todayForegroundColor: WidgetStateProperty.all(AppColors.secondary),
        todayBorder: const BorderSide(color: AppColors.secondary),
        yearForegroundColor: WidgetStateProperty.all(Colors.white),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(const Color(0xFF1A1A1A)),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
          .copyWith(
            displayLarge: const TextStyle(
              color: AppColors.textLightPrimary,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: const TextStyle(color: AppColors.textLightPrimary),
            bodyMedium: const TextStyle(color: AppColors.textLightSecondary),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
