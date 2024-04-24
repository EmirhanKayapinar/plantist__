import 'package:flutter/material.dart';

class ThemeTextStyles {
  const ThemeTextStyles();
  TextStyle get titleMedium => const TextStyle(
    fontSize: 28,
        decoration: TextDecoration.none,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w600,
        height: 32 / 32,
        letterSpacing: 0,
      );

  TextStyle get bodyLarge => const TextStyle(
    fontSize: 20,
        decoration: TextDecoration.none,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        height: 32 / 32,
        letterSpacing: 0,
      );
  TextStyle get bodyMedium => const TextStyle(
    fontSize: 16,
        decoration: TextDecoration.none,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        height: 32 / 32,
        letterSpacing: 0,
      );
  TextStyle get bodySmall => const TextStyle(
    fontSize: 12,
        decoration: TextDecoration.none,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        height: 32 / 32,
        letterSpacing: 0,
      );
  
}

class ThemeColors {
  const ThemeColors();
  static const Color m3white = Color(0xffffffff);
  
}
const Widget themeSpaceHeight4 = SizedBox(height: 4);
const Widget themeSpaceHeight8 = SizedBox(height: 8);
const Widget themeSpaceHeight16 = SizedBox(height: 16);
const Widget themeSpaceHeight24 = SizedBox(height: 24);
const Widget themeSpaceWidth4 = SizedBox(width: 4);
const Widget themeSpaceWidth8 = SizedBox(width: 8);
const Widget themeSpaceWidth16 = SizedBox(width: 16);
const Widget themeSpaceWidth24 = SizedBox(width: 24);
