import 'package:flutter/material.dart';

class AppColors {
  // Kept the constant name 'primaryBlue' so your code doesn't break,
  // but it is now a striking glowing Emerald Green!
  static const Color primaryBlue = Color(0xFF10B981);

  // Very deep, rich jungle/forest green for the background
  static const Color backgroundBase = Color(0xFF022C22);

  // Slightly lighter emerald-tinted surface for cards
  static const Color surfaceCard = Color(0xFF064E3B);

  // Mid-tone emerald for borders
  static const Color borderLight = Color(0xFF047857);

  // --- TEXT COLORS ---
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA7F3D0); // Soft mint green for subtitles
  static const Color textMuted = Color(0xFF6EE7B7);

  // --- TACTICAL / EMERGENCY COLORS (Untouched as requested) ---
  static const Color tacticalRed = Color(0xFFFF2A2A);
  static const Color tacticalOrange = Color(0xFFFF8C00);
  static const Color successGreen = Color(0xFF34D399);
}