import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette - Executive Dark Slate & Electric Blue
  static const Color primary = Color(0xFF1E40AF); // Royal Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);
  
  static const Color secondary = Color(0xFF0EA5E9); // Sky Blue
  static const Color accent = Color(0xFF6366F1); // Indigo

  // Status & Geofencing Colors
  static const Color success = Color(0xFF10B981); // Emerald Green (Within 100m)
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444); // Red (Outside 100m)
  static const Color dangerLight = Color(0xFFFEE2E2);

  // Neutral & Surfaces
  static const Color background = Color(0xFF0F172A); // Dark Slate 900
  static const Color surface = Color(0xFF1E293B); // Slate 800
  static const Color surfaceElevated = Color(0xFF334155); // Slate 700
  static const Color cardBorder = Color(0xFF475569); // Slate 600

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Punch Action Types
  static const Color punchEntry = Color(0xFF10B981); // Green
  static const Color punchLunchOut = Color(0xFFF59E0B); // Amber
  static const Color punchLunchIn = Color(0xFF3B82F6); // Blue
  static const Color punchExit = Color(0xFFEC4899); // Pink/Red
}
