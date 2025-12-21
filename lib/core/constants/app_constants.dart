/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'FusionWave Reader';
  static const String appVersion = '0.1.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String booksCollection = 'books';
  static const String chaptersCollection = 'chapters';
  static const String libraryCollection = 'library';
  static const String bookmarksCollection = 'bookmarks';
  static const String notesCollection = 'notes';
  static const String commentsCollection = 'comments';
  static const String ratingsCollection = 'ratings';
  static const String readingStatsCollection = 'reading_stats';
  static const String voiceNotesCollection = 'voice_notes';
  static const String notificationsCollection = 'notifications';
  static const String followsCollection = 'follows';
  static const String collectionsCollection = 'collections';
  static const String challengesCollection = 'challenges';
  static const String chapterLikesCollection = 'chapter_likes';
  
  // Storage Paths
  static const String audioStoragePath = 'audio';
  static const String videoStoragePath = 'video';
  static const String imageStoragePath = 'images';
  static const String voiceNotesStoragePath = 'voice_notes';
  static const String offlineContentPath = 'offline_content';
  
  // Reading Settings
  static const double minReadingSpeed = 0.5;
  static const double maxReadingSpeed = 2.0;
  static const double defaultReadingSpeed = 1.0;
  
  // Audio Settings
  static const double minAudioSpeed = 0.5;
  static const double maxAudioSpeed = 2.0;
  static const double defaultAudioSpeed = 1.0;
  
  // Pagination
  static const int booksPerPage = 20;
  static const int chaptersPerPage = 50;
  
  // Reading Goals
  static const int defaultDailyReadingGoal = 30; // minutes
  static const int defaultDailyPagesGoal = 20;
  
  // Cache Settings
  static const int maxCacheSizeMB = 500;
  static const Duration cacheExpiration = Duration(days: 30);
  
  // Notification IDs
  static const String dailyReadingReminderId = 'daily_reading_reminder';
  static const String chapterCompleteId = 'chapter_complete';
  static const String goalAchievedId = 'goal_achieved';
  static const String newBookRecommendationId = 'new_book_recommendation';
  
  // User Roles
  static const String roleUser = 'user';
  static const String roleEditor = 'editor';
  static const String roleAdmin = 'admin';
  
  // Reading Modes
  static const String readingModeScroll = 'scroll';
  static const String readingModePage = 'page';
  
  // Theme Modes
  static const String themeLight = 'light';
  static const String themeDark = 'dark';
  static const String themeSepia = 'sepia';
  static const String themeAuto = 'auto';
  
  // Book Status
  static const String bookStatusReading = 'reading';
  static const String bookStatusCompleted = 'completed';
  static const String bookStatusWantToRead = 'want_to_read';
  static const String bookStatusDropped = 'dropped';
  
  // Privacy
  static const bool defaultProfilePublic = true;
  static const bool defaultReadingStatsPublic = false;
}

