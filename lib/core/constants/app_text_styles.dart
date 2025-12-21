import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system for consistent text styling
class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  // Heading styles
  static TextStyle heading1({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: 32,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color ?? AppColors.textPrimaryLight,
      height: 1.2,
      letterSpacing: 0.5,
    );
  }

  static TextStyle heading2({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: 24,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color ?? AppColors.textPrimaryLight,
      height: 1.2,
      letterSpacing: 0.5,
    );
  }

  static TextStyle heading3({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: 20,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? AppColors.textPrimaryLight,
      height: 1.2,
      letterSpacing: 0.3,
    );
  }

  // Title styles
  static TextStyle title({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: 18,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? AppColors.textPrimaryLight,
      height: 1.3,
      letterSpacing: 0.2,
    );
  }

  static TextStyle subtitle({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: 16,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? AppColors.textPrimaryLight,
      height: 1.4,
      letterSpacing: 0.2,
    );
  }

  // Body styles
  static TextStyle body({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? AppColors.textPrimaryLight,
      height: 1.5,
      letterSpacing: 0.2,
    );
  }

  static TextStyle bodySmall({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: 12,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? AppColors.textSecondaryLight,
      height: 1.4,
      letterSpacing: 0.2,
    );
  }

  // Caption style
  static TextStyle caption({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: 11,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? AppColors.textSecondaryLight,
      height: 1.4,
      letterSpacing: 0.2,
    );
  }

  // Button text styles
  static TextStyle button({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: 14,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? Colors.white,
      height: 1.2,
      letterSpacing: 1.0,
    );
  }

  // Link style
  static TextStyle link({
    Color? color,
  }) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.primary,
      height: 1.4,
      decoration: TextDecoration.underline,
      decorationColor: color ?? AppColors.primary,
    );
  }

  // Override for dark theme
  static TextStyle heading1Dark({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return heading1(
      color: color ?? AppColors.textPrimaryDark,
      fontWeight: fontWeight,
    );
  }

  static TextStyle heading2Dark({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return heading2(
      color: color ?? AppColors.textPrimaryDark,
      fontWeight: fontWeight,
    );
  }

  static TextStyle bodyDark({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return body(
      color: color ?? AppColors.textPrimaryDark,
      fontWeight: fontWeight,
    );
  }
}

