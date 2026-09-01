import 'package:flutter/material.dart';

class AppColors {
  // 1. PRIMARY ACCENTS
  static const Color primaryBlue = Color(0xFF38BDF8);    // Electric Alert Blue (Active UI & Admin)
  static const Color policeBlue = Color(0xFF3B82F6);     // Police Dispatch Blue
  static const Color tacticalOrange = Color(0xFFF97316); // Fire Department & False Alert Warning
  static const Color tacticalRed = Color(0xFFEF4444);    // SOS & Critical Danger Pins
  static const Color successGreen = Color(0xFF10B981);   // Medical & Validated Confirmation

  // 2. BACKGROUNDS & SURFACES
  static const Color backgroundBase = Color(0xFF0F172A); // Deep Tactical Slate
  static const Color surfaceCard = Color(0xFF1E293B);    // Elevated cards

  // 3. OPACITY / GLASSMORPHISM
  static final Color glassBase = const Color(0xFF1E293B).withValues(alpha: 0.2);
  static final Color darkShield = const Color(0xFF0F172A).withValues(alpha: 0.65);
  static final Color borderLight = Colors.white.withValues(alpha: 0.1);

  // 4. TYPOGRAPHY
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white38;
}