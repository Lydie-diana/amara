import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AmaraTextStyles {
  AmaraTextStyles._();

  // Display — fond clair
  static TextStyle display1 = GoogleFonts.urbanist(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AmaraColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle display2 = GoogleFonts.urbanist(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AmaraColors.textPrimary,
    letterSpacing: -0.3,
  );

  // Headings
  static TextStyle h1 = GoogleFonts.urbanist(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AmaraColors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle h2 = GoogleFonts.urbanist(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AmaraColors.textPrimary,
  );

  static TextStyle h3 = GoogleFonts.urbanist(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AmaraColors.textPrimary,
  );

  // Body
  static TextStyle bodyLarge = GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AmaraColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.urbanist(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AmaraColors.textSecondary,
  );

  static TextStyle bodySmall = GoogleFonts.urbanist(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AmaraColors.muted,
  );

  // Labels
  static TextStyle labelLarge = GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AmaraColors.textPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle labelMedium = GoogleFonts.urbanist(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AmaraColors.textPrimary,
  );

  static TextStyle labelSmall = GoogleFonts.urbanist(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AmaraColors.muted,
    letterSpacing: 0.3,
  );

  // Caption
  static TextStyle caption = GoogleFonts.urbanist(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AmaraColors.muted,
    letterSpacing: 0.2,
  );

  // Button
  static TextStyle button = GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AmaraColors.white,
    letterSpacing: 0.3,
  );

  // Variantes sur fond sombre (splash, hero header)
  static TextStyle displayOnDark = GoogleFonts.urbanist(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AmaraColors.white,
    letterSpacing: -0.5,
  );

  static TextStyle h1OnDark = GoogleFonts.urbanist(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AmaraColors.white,
  );

  static TextStyle bodyOnDark = GoogleFonts.urbanist(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AmaraColors.muted,
  );
}
