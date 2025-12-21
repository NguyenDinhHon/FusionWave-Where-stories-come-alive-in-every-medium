import 'package:flutter/material.dart';

/// Shadow system for consistent elevation
class AppShadows {
  AppShadows._(); // Private constructor to prevent instantiation

  // Small shadow - for subtle elevation
  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // Medium shadow - for cards and buttons
  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // Large shadow - for elevated cards
  static List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // XLarge shadow - for modals and dialogs
  static List<BoxShadow> shadowXLarge = [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 24,
      offset: const Offset(0, 12),
      spreadRadius: 0,
    ),
  ];

  // Hover shadow - for interactive elements on hover
  static List<BoxShadow> shadowHover = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 6),
      spreadRadius: 2,
    ),
  ];

  // Inner shadow - for inset effects
  static List<BoxShadow> shadowInner = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
      spreadRadius: -2,
    ),
  ];

  // Colored shadows
  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: const Color(0xFF2196F3).withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> shadowAccent = [
    BoxShadow(
      color: const Color(0xFFFF6B6B).withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> shadowSuccess = [
    BoxShadow(
      color: const Color(0xFF4CAF50).withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
}

