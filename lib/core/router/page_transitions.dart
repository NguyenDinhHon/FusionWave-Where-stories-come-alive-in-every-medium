import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transitions for routes
class PageTransitions {
  /// Fade transition
  static CustomTransitionPage fadeTransition({
    required Widget child,
    LocalKey? key,
    String? name,
  }) {
    return CustomTransitionPage(
      key: key,
      name: name,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
  
  /// Slide transition from right
  static CustomTransitionPage slideTransition({
    required Widget child,
    LocalKey? key,
    String? name,
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return CustomTransitionPage(
      key: key,
      name: name,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));
        
        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
  
  /// Scale transition
  static CustomTransitionPage scaleTransition({
    required Widget child,
    LocalKey? key,
    String? name,
  }) {
    return CustomTransitionPage(
      key: key,
      name: name,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));
        
        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
  
  /// Slide and fade transition
  static CustomTransitionPage slideFadeTransition({
    required Widget child,
    LocalKey? key,
    String? name,
    Offset begin = const Offset(0.0, 0.1),
  }) {
    return CustomTransitionPage(
      key: key,
      name: name,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
        
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
  
  /// Hero transition for book details
  static CustomTransitionPage heroTransition({
    required Widget child,
    LocalKey? key,
    String? name,
  }) {
    return CustomTransitionPage(
      key: key,
      name: name,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}

