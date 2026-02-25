import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AmaraTheme {
  AmaraTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AmaraColors.bg,
      primaryColor: AmaraColors.primary,

      colorScheme: const ColorScheme.light(
        primary: AmaraColors.primary,
        secondary: AmaraColors.secondary,
        surface: AmaraColors.bgCard,
        error: AmaraColors.error,
        onPrimary: AmaraColors.white,
        onSecondary: AmaraColors.white,
        onSurface: AmaraColors.textPrimary,
        onError: AmaraColors.white,
        outline: AmaraColors.divider,
      ),

      textTheme: GoogleFonts.urbanistTextTheme(
        const TextTheme(
          displayLarge:   TextStyle(color: AmaraColors.textPrimary),
          displayMedium:  TextStyle(color: AmaraColors.textPrimary),
          displaySmall:   TextStyle(color: AmaraColors.textPrimary),
          headlineLarge:  TextStyle(color: AmaraColors.textPrimary),
          headlineMedium: TextStyle(color: AmaraColors.textPrimary),
          headlineSmall:  TextStyle(color: AmaraColors.textPrimary),
          titleLarge:     TextStyle(color: AmaraColors.textPrimary),
          titleMedium:    TextStyle(color: AmaraColors.textPrimary),
          titleSmall:     TextStyle(color: AmaraColors.textPrimary),
          bodyLarge:      TextStyle(color: AmaraColors.textPrimary),
          bodyMedium:     TextStyle(color: AmaraColors.textSecondary),
          bodySmall:      TextStyle(color: AmaraColors.muted),
          labelLarge:     TextStyle(color: AmaraColors.textPrimary),
          labelMedium:    TextStyle(color: AmaraColors.textSecondary),
          labelSmall:     TextStyle(color: AmaraColors.muted),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AmaraColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AmaraColors.textPrimary),
        titleTextStyle: GoogleFonts.urbanist(
          color: AmaraColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AmaraColors.primary,
          foregroundColor: AmaraColors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AmaraColors.primary,
          side: const BorderSide(color: AmaraColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AmaraColors.primary,
          textStyle: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AmaraColors.bgAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AmaraColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AmaraColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AmaraColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AmaraColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.urbanist(
          color: AmaraColors.muted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.urbanist(
          color: AmaraColors.textSecondary,
          fontSize: 14,
        ),
      ),

      cardTheme: CardThemeData(
        color: AmaraColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AmaraColors.bgCard,
        selectedItemColor: AmaraColors.primary,
        unselectedItemColor: AmaraColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      dividerTheme: const DividerThemeData(
        color: AmaraColors.divider,
        thickness: 1,
      ),

      iconTheme: const IconThemeData(
        color: AmaraColors.textPrimary,
        size: 24,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AmaraColors.dark,
        contentTextStyle: GoogleFonts.urbanist(
          color: AmaraColors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AmaraColors.bgAlt,
        selectedColor: AmaraColors.primary.withValues(alpha: 0.12),
        labelStyle: GoogleFonts.urbanist(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AmaraColors.textPrimary,
        ),
        side: const BorderSide(color: AmaraColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
