# FusionWave Reader

**FusionWave Reader** - Where stories come alive in every medium

A professional cross-platform reading application built with Flutter, supporting Android, iOS, and Web. FusionWave Reader offers a comprehensive reading experience with support for text, audio, video, and interactive features.

## 🚀 Features

### Core Features
- 📚 **Professional Reading Experience**
  - Multiple reading modes (Scroll & Page view)
  - Customizable themes (Light, Dark, Sepia)
  - Adjustable font size and line height
  - Bookmark and text notes

- 🎵 **Audio Book Support**
  - High-quality audio playback with `just_audio` and `audioplayers`
  - Playback speed control (0.5x - 2.0x)
  - Chapter playlist with auto-next
  - Background audio playback

- 🎬 **Video Content**
  - Embedded video player for educational content
  - Fullscreen video support
  - Picture-in-picture mode

- 🎤 **Voice Recording**
  - Record voice notes while reading
  - Speech-to-text conversion
  - Cloud storage and sync

- 🔔 **Smart Notifications**
  - Daily reading reminders
  - Chapter completion alerts
  - Goal achievement notifications
  - Custom ringtones with `flutter_ringtone_player`

- 📊 **Reading Analytics**
  - Reading statistics and progress tracking
  - Reading streak counter
  - Heatmap calendar
  - Time and pages read tracking

- 👥 **Social Features**
  - Follow other readers
  - Book comments and ratings
  - Leaderboard and top readers
  - Book recommendations

- 📱 **Offline Support**
  - Download books for offline reading
  - Cache audio and video content
  - Sync when online

## 🏗️ Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants, colors, strings
│   ├── router/             # Navigation configuration
│   ├── services/           # Firebase and external services
│   ├── theme/              # App theming
│   └── utils/              # Utilities and extensions
│
├── data/                    # Data layer
│   ├── models/             # Data models
│   ├── repositories/       # Repository implementations
│   └── datasources/        # Remote and local data sources
│
├── domain/                  # Business logic layer
│   ├── entities/           # Domain entities
│   └── usecases/           # Business use cases
│
├── features/                # Feature modules
│   ├── auth/               # Authentication
│   ├── home/               # Home screen
│   ├── library/            # Personal library
│   ├── reading/            # Reading interface
│   ├── audio/              # Audio player
│   ├── video/              # Video player
│   ├── recording/          # Voice recording
│   ├── stats/              # Reading statistics
│   ├── social/             # Social features
│   ├── search/             # Book search
│   ├── profile/            # User profile
│   └── settings/           # App settings
│
└── shared/                  # Shared components
    ├── widgets/            # Reusable widgets
    └── dialogs/            # Common dialogs
```

## 🛠️ Technology Stack

### Frontend
- **Flutter** 3.10.0+ (Dart SDK)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **UI**: Material Design 3

### Backend & Services
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - Real-time database with offline persistence
- **Firebase Storage** - Media file storage
- **Firebase Cloud Messaging** - Push notifications
- **Firebase Analytics** - User analytics
- **Firebase Crashlytics** - Error tracking
- **Firebase Functions** - Serverless backend

### Media Libraries
- **audioplayers** - Background music and preview audio
- **just_audio** - Professional audiobook playback
- **flutter_ringtone_player** - Notification sounds
- **record** - Voice recording
- **video_player** - Video content playback

### Additional Libraries
- **cached_network_image** - Image caching
- **shared_preferences** - Local preferences
- **sqflite** - Local database
- **path_provider** - File system access
- **permission_handler** - Runtime permissions
- **intl** - Internationalization
- **fl_chart** - Charts and graphs

## 📦 Installation

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart SDK
- Firebase project configured
- Android Studio / Xcode (for mobile development)

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd FusionWave-Where-stories-come-alive-in-every-medium
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Ensure `firebase_options.dart` is properly configured
   - Add `google-services.json` for Android
   - Add `GoogleService-Info.plist` for iOS
   - Configure Firebase Storage rules
   - Set up Firestore security rules

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔥 Firebase Setup

### Firestore Collections Structure

```
users/
  {userId}/
    - email, displayName, photoUrl
    - role, preferences
    - readingStreak, lastReadingDate

books/
  {bookId}/
    - title, description, authors
    - categories, tags
    - coverImageUrl, audioUrl, videoUrl
    - totalPages, totalChapters
    - averageRating, totalRatings

chapters/
  {chapterId}/
    - bookId, title, content
    - chapterNumber, pageNumber
    - audioUrl, videoUrl

library/
  {userId}/
    {bookId}/
      - status, progress
      - lastReadAt, readingTime

bookmarks/
  {bookmarkId}/
    - userId, bookId, chapterId
    - position, note

reading_stats/
  {userId}/
    - totalPages, totalChapters
    - totalReadingTime
    - dailyStats, weeklyStats
```

### Storage Structure

```
audio/
  {bookId}/
    {chapterId}.mp3

video/
  {bookId}/
    {chapterId}.mp4

images/
  books/
    {bookId}.jpg
  users/
    {userId}.jpg

voice_notes/
  {userId}/
    {noteId}.m4a
```

## 🎨 Features in Detail

### Reading Modes
- **Scroll Mode**: Continuous scrolling for fast reading
- **Page Mode**: Page-by-page reading like a physical book

### Audio Features
- Background playback
- Speed control (0.5x - 2.0x)
- Chapter playlist
- Auto-advance to next chapter
- Sleep timer

### Offline Mode
- Download books and chapters
- Cache audio/video files
- Automatic sync when online
- Storage management

### Social Features
- Follow/unfollow users
- Comment on books
- Rate books (1-5 stars)
- View leaderboard
- Get personalized recommendations

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ✅ Web (Chrome, Firefox, Safari, Edge)

## 🔐 Security

- Firebase Authentication with email/password and Google Sign-In
- Firestore Security Rules for data access control
- Role-based access control (User, Editor, Admin)
- Secure file uploads to Firebase Storage

## 📈 Performance

- Offline-first architecture
- Image caching
- Lazy loading
- Optimized Firestore queries
- Background sync

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📄 License

This project is part of a graduation thesis/dissertation.

## 👥 Contributors

- Development Team

## 📞 Support

For issues and questions, please open an issue on the repository.

---

**Built with ❤️ using Flutter & Firebase**
