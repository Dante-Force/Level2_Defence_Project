import 'package:flutter/material.dart';

class AppColors {
  // 1. PRIMARY ACCENTS (Most Impacting)
  static const Color primaryBlue = Color(0xFF38BDF8); // Electric Alert Blue (Active UI)
  static const Color tacticalRed = Color(0xFFEF4444); // SOS & Danger Pins
  static const Color successGreen = Color(0xFF10B981); // Medical/Confirmation

  // 2. BACKGROUNDS & SURFACES (The Foundation)
  static const Color backgroundBase = Color(0xFF0F172A); // Deep Tactical Slate
  static const Color surfaceCard = Color(0xFF1E293B); // Slightly lighter for elevated cards

  // 3. OPACITY / GLASSMORPHISM (Special UI effects)
  static final Color glassBase = const Color(0xFF1E293B).withValues(alpha: 0.2);
  static final Color darkShield = const Color(0xFF0F172A).withValues(alpha: 0.65);
  static final Color borderLight = Colors.white.withValues(alpha: 0.1);

  // 4. TYPOGRAPHY (From highest contrast to lightest)
  static const Color textPrimary = Colors.white; // Main titles
  static const Color textSecondary = Colors.white70; // Subtitles / Standard text
  static const Color textMuted = Colors.white38; // Disabled text or subtle hints

}