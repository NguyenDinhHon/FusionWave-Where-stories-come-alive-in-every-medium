import 'package:flutter/foundation.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';  // Will be enabled when added

/// Centralized logging utility
class AppLogger {
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
      if (error != null) {
        debugPrint('[ERROR] $error');
      }
    }
  }
  
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }
  
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[WARNING] $message');
      if (error != null) {
        debugPrint('[ERROR] $error');
      }
    }
  }
  
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) {
        debugPrint('[ERROR DETAILS] $error');
      }
      if (stackTrace != null) {
        debugPrint('[STACK TRACE] $stackTrace');
      }
    }
    
    // Log to Firebase Crashlytics in production
    // ignore: todo
    // TODO: Enable when firebase_crashlytics is added
    // if (!kDebugMode) {
    //   FirebaseCrashlytics.instance.log(message);
    //   if (error != null && stackTrace != null) {
    //     FirebaseCrashlytics.instance.recordError(
    //       error,
    //       stackTrace,
    //       fatal: fatal,
    //       reason: message,
    //     );
    //   }
    // }
  }
  
  static void logEvent(String eventName, Map<String, dynamic>? parameters) {
    if (kDebugMode) {
      debugPrint('[EVENT] $eventName');
      if (parameters != null) {
        debugPrint('[PARAMETERS] $parameters');
      }
    }
  }
}

