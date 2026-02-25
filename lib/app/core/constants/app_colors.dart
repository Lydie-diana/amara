import 'package:flutter/material.dart';

class AmaraColors {
  AmaraColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary   = Color(0xFFE62050); // rouge Amara — couleur principale
  static const Color secondary = Color(0xFFE5445E); // rouge secondaire (gradient)

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color bg        = Color(0xFFFAFAFA); // fond principal (blanc chaud)
  static const Color bgAlt     = Color(0xFFF2F2F7); // fond alternatif (sections, cards)
  static const Color bgCard    = Color(0xFFFFFFFF); // surface card

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A2E); // texte principal (quasi-noir)
  static const Color textSecondary = Color(0xFF6B6B80); // texte secondaire
  static const Color muted         = Color(0xFFB6AEB9); // texte désactivé / placeholder

  // ── Accent sombre (utilisé avec parcimonie : logo, footer, badges) ────────
  static const Color dark      = Color(0xFF1F172B); // accent sombre Amara

  // ── Utility ───────────────────────────────────────────────────────────────
  static const Color white     = Color(0xFFFFFFFF);
  static const Color black     = Color(0xFF0D0D0D);
  static const Color success   = Color(0xFF27AE60);
  static const Color warning   = Color(0xFFF39C12);
  static const Color error     = Color(0xFFE74C3C);
  static const Color divider   = Color(0xFFE8E8EE);
  static const Color shadow    = Color(0x0D000000);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient hero (splash, onboarding header) — foncé → primaire
  static const LinearGradient heroGradient = LinearGradient(
    colors: [dark, Color(0xFF3D1F3A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
