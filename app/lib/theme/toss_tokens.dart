import 'package:flutter/widgets.dart';

class TossColors {
  const TossColors._();

  static const primary = Color(0xFF3182F6);
  static const primaryHover = Color(0xFF2272EB);
  static const canvas = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF191F28);
  static const body = Color(0xFF4E5968);
  static const muted = Color(0xFF8B95A1);
  static const surface = Color(0xFFF2F4F6);
  static const border = Color(0xFFE5E8EB);
  static const onPrimary = Color(0xFFFFFFFF);
  static const weakBackground = Color(0xFFE8F3FF);
  static const weakForeground = Color(0xFF1B64DA);
  static const danger = Color(0xFFE42939);

  static const focusAccent = Color(0xFF3182F6);
  static const breakAccent = Color(0xFF19C37D);
  static const longBreakAccent = Color(0xFFB259F2);
  static const pausedAccent = Color(0xFF8B95A1);
}

class TossSpacing {
  const TossSpacing._();

  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class TossRadius {
  const TossRadius._();

  static const sm = 4.0;
  static const md = 6.0;
  static const buttonSmall = 8.0;
  static const buttonMedium = 10.0;
  static const buttonLarge = 14.0;
  static const buttonXLarge = 16.0;
}

class TossFontFamily {
  const TossFontFamily._();

  static const fallback = <String>[
    'Toss Product Sans',
    'Apple SD Gothic Neo',
    'Malgun Gothic',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];
}

class TossTextStyles {
  const TossTextStyles._();

  static const h1 = TextStyle(
    fontFamily: 'TossProductSans',
    fontFamilyFallback: TossFontFamily.fallback,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 54 / 36,
    color: TossColors.foreground,
  );

  static const h2 = TextStyle(
    fontFamily: 'TossProductSans',
    fontFamilyFallback: TossFontFamily.fallback,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    height: 45 / 30,
    color: TossColors.foreground,
  );

  static const h3 = TextStyle(
    fontFamily: 'TossProductSans',
    fontFamilyFallback: TossFontFamily.fallback,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 36 / 24,
    color: TossColors.foreground,
  );

  static const h4 = TextStyle(
    fontFamily: 'TossProductSans',
    fontFamilyFallback: TossFontFamily.fallback,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 33 / 22,
    color: TossColors.foreground,
  );

  static const body = TextStyle(
    fontFamily: 'TossProductSans',
    fontFamilyFallback: TossFontFamily.fallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: TossColors.body,
  );

  static const bodySmall = TextStyle(
    fontFamily: 'TossProductSans',
    fontFamilyFallback: TossFontFamily.fallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 21 / 14,
    color: TossColors.muted,
  );

  static const buttonXLarge = TextStyle(
    fontFamily: 'TossProductSans',
    fontFamilyFallback: TossFontFamily.fallback,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: TossColors.onPrimary,
  );

  static const buttonXLargeBase = TextStyle(
    fontFamily: 'TossProductSans',
    fontFamilyFallback: TossFontFamily.fallback,
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );
}
