import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/local_stats_repository.dart';
import '../../../../data/models/reading_stats_model.dart';

/// Stats repository provider
final statsRepositoryProvider = Provider<LocalStatsRepository>((ref) {
  return LocalStatsRepository();
});

/// Reading stats provider (one-shot read from local storage)
final readingStatsProvider = FutureProvider<ReadingStatsModel?>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getReadingStats();
});

/// Stats controller provider
final statsControllerProvider = Provider<StatsController>((ref) {
  return StatsController(ref.read(statsRepositoryProvider));
});

class StatsController {
  final LocalStatsRepository _repository;
  
  StatsController(this._repository);
  
  Future<ReadingStatsModel?> getReadingStats() => _repository.getReadingStats();
  Future<ReadingStatsModel> updateReadingStats({
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

