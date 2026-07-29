import 'package:flutter/material.dart';
import 'toss_tokens.dart';

class TossTheme {
  const TossTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: TossColors.canvas,
      fontFamily: 'TossProductSans',
      fontFamilyFallback: TossFontFamily.fallback,
      colorScheme: const ColorScheme.light(
        primary: TossColors.primary,
        onPrimary: TossColors.onPrimary,
        surface: TossColors.canvas,
        onSurface: TossColors.foreground,
        error: TossColors.danger,
      ),
      textTheme: const TextTheme(
        displaySmall: TossTextStyles.h1,
        headlineMedium: TossTextStyles.h2,
        headlineSmall: TossTextStyles.h3,
        titleLarge: TossTextStyles.h4,
        bodyLarge: TossTextStyles.body,
        bodyMedium: TossTextStyles.bodySmall,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TossColors.primary,
          foregroundColor: TossColors.onPrimary,
          disabledBackgroundColor: TossColors.surface,
          disabledForegroundColor: TossColors.muted,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TossRadius.buttonXLarge),
          ),
          textStyle: TossTextStyles.buttonXLarge,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TossColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TossSpacing.lg,
          vertical: TossSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TossRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TossRadius.md),
          borderSide: const BorderSide(color: TossColors.primary, width: 1.5),
        ),
      ),
      dividerColor: TossColors.border,
    );
  }
}
