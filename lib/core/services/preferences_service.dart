import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

/// Preferences service for app settings
class PreferencesService {
  static const String _keyTheme = 'theme';
  static const String _keyReadingMode = 'reading_mode';
  static const String _keyFontSize = 'font_size';
  static const String _keyLineHeight = 'line_height';
  static const String _keyOfflineMode = 'offline_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyDailyReminder = 'daily_reminder';
  static const String _keyChildMode = 'child_mode';
  static const String _keyReadingGoal = 'reading_goal';
  static const String _keySearchHistory = 'search_history';
  
  SharedPreferences? _prefs;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('PreferencesService not initialized. Call init() first.');
    }
    return _prefs!;
  }
  
  // Theme
  String getTheme() {
    return prefs.getString(_keyTheme) ?? AppConstants.themeAuto;
  }
  
  Future<void> setTheme(String theme) async {
    await prefs.setString(_keyTheme, theme);
    AppLogger.info('Theme set to: $theme');
  }
  
  // Reading mode
  String getReadingMode() {
    return prefs.getString(_keyReadingMode) ?? AppConstants.readingModeScroll;
  }
  
  Future<void> setReadingMode(String mode) async {
    await prefs.setString(_keyReadingMode, mode);
    AppLogger.info('Reading mode set to: $mode');
  }
  
  // Font size
  double getFontSize() {
    return prefs.getDouble(_keyFontSize) ?? 16.0;
  }
  
  Future<void> setFontSize(double size) async {
    await prefs.setDouble(_keyFontSize, size);
    AppLogger.info('Font size set to: $size');
  }
  
  // Line height
  double getLineHeight() {
    return prefs.getDouble(_keyLineHeight) ?? 1.6;
  }
  
  Future<void> setLineHeight(double height) async {
    await prefs.setDouble(_keyLineHeight, height);
    AppLogger.info('Line height set to: $height');
  }
  
  // Offline mode
  bool getOfflineMode() {
    return prefs.getBool(_keyOfflineMode) ?? false;
  }
  
  Future<void> setOfflineMode(bool enabled) async {
    await prefs.setBool(_keyOfflineMode, enabled);
    AppLogger.info('Offline mode set to: $enabled');
  }
  
  // Notifications enabled
  bool getNotificationsEnabled() {
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }
  
  Future<void> setNotificationsEnabled(bool enabled) async {
    await prefs.setBool(_keyNotificationsEnabled, enabled);
    AppLogger.info('Notifications enabled set to: $enabled');
  }
  
  // Daily reminder
  bool getDailyReminder() {
    return prefs.getBool(_keyDailyReminder) ?? false;
  }
  
  Future<void> setDailyReminder(bool enabled) async {
    await prefs.setBool(_keyDailyReminder, enabled);
    AppLogger.info('Daily reminder set to: $enabled');
  }
  
  // Child mode
  bool getChildMode() {
    return prefs.getBool(_keyChildMode) ?? false;
  }
  
  Future<void> setChildMode(bool enabled) async {
    await prefs.setBool(_keyChildMode, enabled);
    AppLogger.info('Child mode set to: $enabled');
  }
  
  // Reading goal (minutes per day)
  int getReadingGoal() {
    return prefs.getInt(_keyReadingGoal) ?? AppConstants.defaultDailyReadingGoal;
  }
  
  Future<void> setReadingGoal(int minutes) async {
    await prefs.setInt(_keyReadingGoal, minutes);
    AppLogger.info('Reading goal set to: $minutes minutes');
  }
  
  // Search history
  Future<List<String>> getSearchHistory() async {
    final historyString = prefs.getString(_keySearchHistory);
    if (historyString == null || historyString.isEmpty) {
      return [];
    }
    return historyString.split(',').where((item) => item.isNotEmpty).toList();
  }
  
  Future<void> saveSearchHistory(List<String> history) async {
    // Limit to 10 items
    final limitedHistory = history.take(10).toList();
    await prefs.setString(_keySearchHistory, limitedHistory.join(','));
    AppLogger.info('Search history saved: ${limitedHistory.length} items');
  }
  
  Future<void> addToSearchHistory(String query) async {
    if (query.isEmpty) return;
    
    final history = await getSearchHistory();
    // Remove if already exists
    history.remove(query);
    // Add to beginning
    history.insert(0, query);
    // Limit to 10
    final limitedHistory = history.take(10).toList();
    await saveSearchHistory(limitedHistory);
  }
  
  Future<void> clearSearchHistory() async {
    await prefs.remove(_keySearchHistory);
    AppLogger.info('Search history cleared');
  }
  
  // Clear all preferences
  Future<void> clearAll() async {
    await prefs.clear();
    AppLogger.info('All preferences cleared');
  }
}

