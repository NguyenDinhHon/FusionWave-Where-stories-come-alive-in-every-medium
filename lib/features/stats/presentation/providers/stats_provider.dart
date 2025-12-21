import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/stats_repository.dart';
import '../../../../data/models/reading_stats_model.dart';

/// Stats repository provider
final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository();
});

/// Reading stats provider
final readingStatsProvider = StreamProvider<ReadingStatsModel?>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getReadingStatsStream();
});

/// Stats controller provider
final statsControllerProvider = Provider<StatsController>((ref) {
  return StatsController(ref.read(statsRepositoryProvider));
});

class StatsController {
  final StatsRepository _repository;
  
  StatsController(this._repository);
  
  Future<ReadingStatsModel?> getReadingStats() => _repository.getReadingStats();
  Future<void> updateReadingStats({
    int? pagesRead,
    int? chaptersRead,
    int? readingTimeMinutes,
    bool? chapterCompleted,
  }) => _repository.updateReadingStats(
    pagesRead: pagesRead,
    chaptersRead: chaptersRead,
    readingTimeMinutes: readingTimeMinutes,
    chapterCompleted: chapterCompleted,
  );
}

