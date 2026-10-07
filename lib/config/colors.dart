import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primaryColor = Color(0xFF16A34A);

  // Font color
  static Color lightFontColor = Colors.black;
  static Color darkFontColor = Colors.white;

  // Custom section
  static const Color customBoxBorder = Color(0xFFF5F5F5);
  static const Color chevronIconColor = Color(0xFF9D9D9D);
  static const Color sectionTitleColor = Color(0xFF5B5454);

  /// Light Theme Colors
  static const Color mainLightBackgroundColor = Colors.white;
  static Color mainLightBackgroundColor2 = Colors.grey.shade200;

  static const Color mainLightContainerBgColor = Color(0xFFF7FAFC);
  static const Color lightSecondary = Color(0xFFE0E0E0);

  static const Color lightTertiary = Color(0xFF0F172A);
  static Color lightProductCardColor = Colors.grey.shade100;

  // Updated from old cyan to brand green
  static const Color lightSubCategoryCardColor = Color(0xFFEAF7EE);

  static Color lightOutline = Colors.grey.shade200;
  static Color lightOutlineVariant = Colors.grey.shade300;

  /// Dark Theme Colors
  static const Color mainDarkBackgroundColor = Color(0xFF0F172A);
  static const Color mainDarkContainerBgColor = Color(0xFF151515);
  static const Color darkSubCategoryCardColor = Color(0xFF161B22);
  static const Color darkExtraCardColor = Color(0xFF30363D);
  static const Color darkTertiary = Color(0xFFCCCBCB);

  static Color darkProductCardColor = const Color(0xFF161B22);
  static Color darkOutline = Colors.grey.shade700;
  static Color darkOutlineVariant =
  Colors.grey.withValues(alpha: 0.5);

  // Functional colors
  static const Color successColor = Color(0xFF1C6D2B);
  static const Color pendingColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFFF2222);
  static const Color darkErrorColor = Color(0xFFB30826);

  // Step Status Colors
  static const Color stepCompletedColor = Color(0xFF16A34A);
  static const Color stepCurrentColor = primaryColor;

  // Updated from old blue to brand green tint
  static const Color stepCurrentBgColor = Color(0xFFEAF7EE);

  static const Color stepPendingColor = Color(0xFF94A3B8);
  static const Color stepPendingBgColor = Color(0xFFF8FAFC);
  static const Color stepPendingCircleColor = Color(0xFFF1F5F9);

  // Auth header
  static const Color authHeaderColor = Color(0xFFDDF7E5);

  // Zone location marker
  static const Color zoneLocationMarkerColor = Color(0xFF16A34A);

  // More Menu Box
  static const Color moreOptionsBackground = Color(0xFFEAF7EE);
}