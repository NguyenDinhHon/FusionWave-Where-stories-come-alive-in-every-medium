import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

/// Reading goals provider
final readingGoalsProvider = NotifierProvider<ReadingGoalsNotifier, ReadingGoalsState>(() {
  return ReadingGoalsNotifier();
});

class ReadingGoalsState {
  final int dailyGoalMinutes;
  final int todayMinutes;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReadingDate;
  
  ReadingGoalsState({
    required this.dailyGoalMinutes,
    required this.todayMinutes,
    required this.currentStreak,
    required this.longestStreak,
    this.lastReadingDate,
  });
  
  double get progress => dailyGoalMinutes > 0 
      ? (todayMinutes / dailyGoalMinutes).clamp(0.0, 1.0)
      : 0.0;
  
  bool get isGoalAchieved => todayMinutes >= dailyGoalMinutes;
  
  ReadingGoalsState copyWith({
    int? dailyGoalMinutes,
    int? todayMinutes,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReadingDate,
  }) {
    return ReadingGoalsState(
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      todayMinutes: todayMinutes ?? this.todayMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
    );
  }
}

class ReadingGoalsNotifier extends Notifier<ReadingGoalsState> {
  @override
  ReadingGoalsState build() {
    final prefsAsync = ref.read(preferencesServiceProvider);
    return prefsAsync.maybeWhen(
      data: (prefs) {
        final dailyGoal = prefs.getReadingGoal();
        // ignore: todo
        // TODO: Load today's minutes and streak from Firestore or local storage
        return ReadingGoalsState(
          dailyGoalMinutes: dailyGoal,
          todayMinutes: 0,
          currentStreak: 0,
          longestStreak: 0,
        );
      },
      orElse: () => ReadingGoalsState(
        dailyGoalMinutes: AppConstants.defaultDailyReadingGoal,
        todayMinutes: 0,
        currentStreak: 0,
        longestStreak: 0,
      ),
    );
  }
  
  Future<void> setDailyGoal(int minutes) async {
    final prefsAsync = ref.read(preferencesServiceProvider);
    prefsAsync.whenData((prefs) async {
      await prefs.setReadingGoal(minutes);
      state = state.copyWith(dailyGoalMinutes: minutes);
      AppLogger.info('Daily reading goal set to: $minutes minutes');
    });
  }
  
  Future<void> addReadingTime(int minutes) async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    // Check if last reading was yesterday
    final lastDate = state.lastReadingDate;
    final shouldIncrementStreak = lastDate != null &&
        lastDate.isBefore(todayStart) &&
        lastDate.isAfter(todayStart.subtract(const Duration(days: 2)));
    
    final newStreak = shouldIncrementStreak 
        ? state.currentStreak + 1
        : (lastDate == null || lastDate.isBefore(todayStart.subtract(const Duration(days: 1))))
            ? 1
            : state.currentStreak;
    
    final newLongestStreak = newStreak > state.longestStreak 
        ? newStreak 
        : state.longestStreak;
    
    final isToday = lastDate != null && 
        lastDate.year == today.year &&
        lastDate.month == today.month &&
        lastDate.day == today.day;
    
    final newTodayMinutes = isToday 
        ? state.todayMinutes + minutes
        : minutes;
    
    state = state.copyWith(
      todayMinutes: newTodayMinutes,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastReadingDate: today,
    );
    
    // ignore: todo
    // TODO: Save to Firestore or local storage
    AppLogger.info('Reading time added: $minutes minutes');
  }
  
  void resetToday() {
    state = state.copyWith(todayMinutes: 0);
  }
}

/// Goals controller provider
final goalsControllerProvider = Provider<GoalsController>((ref) {
  return GoalsController(ref.read(readingGoalsProvider.notifier));
});

class GoalsController {
  final ReadingGoalsNotifier _notifier;
  
  GoalsController(this._notifier);
  
  Future<void> setDailyGoal(int minutes) => _notifier.setDailyGoal(minutes);
  Future<void> addReadingTime(int minutes) => _notifier.addReadingTime(minutes);
  void resetToday() => _notifier.resetToday();
}

