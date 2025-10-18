import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_schemes.dart';

class AppTheme {
  // Light theme color palette (for backward compatibility)
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color accentBlue = Color(0xFF64B5F6);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color background = Color(0xFFF9FAFB);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color white = Color(0xFFFFFFFF);

  /// Get light theme
  static ThemeData get lightTheme {
    return _buildTheme(
      primaryColor: LightColorScheme.primaryBlue,
      backgroundColor: LightColorScheme.background,
      surfaceColor: LightColorScheme.surfaceColor,
      cardColor: LightColorScheme.cardBackground,
      textPrimaryColor: LightColorScheme.textPrimary,
      textSecondaryColor: LightColorScheme.textSecondary,
      borderColor: LightColorScheme.borderColor,
      errorColor: LightColorScheme.errorColor,
      accentBlue: LightColorScheme.accentBlue,
      isDark: false,
    );
  }

  /// Get dark theme
  static ThemeData get darkTheme {
    return _buildTheme(
      primaryColor: DarkColorScheme.primaryBlue,
      backgroundColor: DarkColorScheme.background,
      surfaceColor: DarkColorScheme.surfaceColor,
      cardColor: DarkColorScheme.cardBackground,
      textPrimaryColor: DarkColorScheme.textPrimary,
      textSecondaryColor: DarkColorScheme.textSecondary,
      borderColor: DarkColorScheme.borderColor,
      errorColor: DarkColorScheme.errorColor,
      accentBlue: DarkColorScheme.accentBlue,
      isDark: true,
    );
  }

  /// Build theme based on parameters
  static ThemeData _buildTheme({
    required Color primaryColor,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color cardColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required Color borderColor,
    required Color errorColor,
    required Color accentBlue,
    required bool isDark,
  }) {
    return ThemeData(
      useMaterial3: false,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryColor,
              secondary: accentBlue,
              surface: surfaceColor,
              error: errorColor,
              surfaceTint: backgroundColor,
            )
          : ColorScheme.light(
              primary: primaryColor,
              secondary: accentBlue,
              surface: surfaceColor,
              error: errorColor,
              surfaceTint: backgroundColor,
            ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondaryColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondaryColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: textSecondaryColor),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      iconTheme: IconThemeData(
        color: textPrimaryColor,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return textSecondaryColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withValues(alpha: 0.5);
          }
          return borderColor;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        space: 1,
      ),
    );
  }

  /// Get theme based on isDarkMode flag
  static ThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? darkTheme : lightTheme;
  }

  /// Legacy theme getter for backward compatibility
  static ThemeData get theme => lightTheme;
}
