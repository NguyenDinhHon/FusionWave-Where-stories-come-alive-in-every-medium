import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Preferences service provider
final preferencesServiceProvider = FutureProvider<PreferencesService>((ref) async {
  final service = PreferencesService();
  await service.init();
  return service;
});

/// Theme provider
final themeProvider = NotifierProvider<ThemeNotifier, String>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<String> {
  @override
  String build() {
    final prefsAsync = ref.read(preferencesServiceProvider);
    return prefsAsync.maybeWhen(
      data: (prefs) => prefs.getTheme(),
      orElse: () => AppConstants.themeAuto,
    );
  }
  
  Future<void> setTheme(String theme) async {
    state = theme;
    final prefsAsync = ref.read(preferencesServiceProvider);
    prefsAsync.whenData((service) async {
      await service.setTheme(theme);
    });
  }
}

/// Reading mode provider
final readingModeProvider = NotifierProvider<ReadingModeNotifier, String>(() {
  return ReadingModeNotifier();
});

class ReadingModeNotifier extends Notifier<String> {
  @override
  String build() {
    final prefsAsync = ref.read(preferencesServiceProvider);
    return prefsAsync.maybeWhen(
      data: (prefs) => prefs.getReadingMode(),
      orElse: () => AppConstants.readingModeScroll,
    );
  }
  
  Future<void> setReadingMode(String mode) async {
    state = mode;
    final prefsAsync = ref.read(preferencesServiceProvider);
    prefsAsync.whenData((service) async {
      await service.setReadingMode(mode);
    });
  }
}

/// Settings controller provider
final settingsControllerProvider = Provider<SettingsController>((ref) {
  return SettingsController(ref.read(preferencesServiceProvider));
});

class SettingsController {
  final AsyncValue<PreferencesService> _prefsService;
  
  SettingsController(this._prefsService);
  
  Future<void> setTheme(String theme) async {
    _prefsService.whenData((service) async {
      await service.setTheme(theme);
    });
  }
  
  Future<void> setReadingMode(String mode) async {
    _prefsService.whenData((service) async {
      await service.setReadingMode(mode);
    });
  }
  
  Future<void> setFontSize(double size) async {
    _prefsService.whenData((service) async {
      await service.setFontSize(size);
    });
  }
  
  Future<void> setLineHeight(double height) async {
    _prefsService.whenData((service) async {
      await service.setLineHeight(height);
    });
  }
  
  Future<void> setOfflineMode(bool enabled) async {
    _prefsService.whenData((service) async {
      await service.setOfflineMode(enabled);
    });
  }
  
  Future<void> setNotificationsEnabled(bool enabled) async {
    _prefsService.whenData((service) async {
      await service.setNotificationsEnabled(enabled);
    });
  }
  
  Future<void> setDailyReminder(bool enabled) async {
    _prefsService.whenData((service) async {
      await service.setDailyReminder(enabled);
    });
  }
  
  Future<void> setChildMode(bool enabled) async {
    _prefsService.whenData((service) async {
      await service.setChildMode(enabled);
    });
  }
  
  Future<void> setReadingGoal(int minutes) async {
    _prefsService.whenData((service) async {
      await service.setReadingGoal(minutes);
    });
  }
}

