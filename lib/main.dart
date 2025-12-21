import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_service.dart';
import 'core/services/preferences_service.dart';
import 'core/utils/logger.dart';
import 'core/constants/app_constants.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase services
    await FirebaseService().initialize();
    
    // Initialize Preferences
    final prefsService = PreferencesService();
    await prefsService.init();
    
    // Initialize Notifications
    // final notificationService = NotificationService();
    // await notificationService.initialize();
    
    AppLogger.info('Application initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error(
      'Failed to initialize application',
      error: e,
      stackTrace: stackTrace,
      fatal: true,
    );
  }
  
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    
    ThemeMode themeMode;
    switch (theme) {
      case AppConstants.themeLight:
        themeMode = ThemeMode.light;
        break;
      case AppConstants.themeDark:
        themeMode = ThemeMode.dark;
        break;
      case AppConstants.themeSepia:
        // Use light theme as base for sepia
        themeMode = ThemeMode.light;
        break;
      default:
        themeMode = ThemeMode.system;
    }
    
    return MaterialApp.router(
      title: 'FusionWave Reader',
      debugShowCheckedModeBanner: false,
      theme: theme == AppConstants.themeSepia 
          ? AppTheme.sepiaTheme 
          : AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
