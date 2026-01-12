import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/chapter.dart';

part 'current_chapter_provider.g.dart';

@riverpod
class ChaptersList extends _$ChaptersList {
  @override
  List<Chapter> build() => [];
  
  void loadChapters(List<Chapter> chapters) {
    state = chapters;
  }
}

@riverpod
class CurrentChapter extends _$CurrentChapter {
  @override
  Chapter? build() => null;
  
  void setChapter(Chapter? chapter) {
    state = chapter;
  }
}

@riverpod
class ChapterNavigation extends _$ChapterNavigation {
  @override
  int build() => 0;
  
  void jumpToChapter(int index) {
    final chapters = ref.read(chaptersListProvider);
    if (index >= 0 && index < chapters.length) {
      state = index;
      ref.read(currentChapterProvider.notifier).setChapter(chapters[index]);
    }
  }
  
  void nextChapter() {
    if (!ref.mounted) return;
    final chapters = ref.read(chaptersListProvider);
    if (state < chapters.length - 1) {
      state++;
      if (ref.mounted) {
        ref.read(currentChapterProvider.notifier).setChapter(chapters[state]);
      }
    }
  }
  
  void previousChapter() {
    if (!ref.mounted) return;
    final chapters = ref.read(chaptersListProvider);
    if (state > 0) {
      state--;
      if (ref.mounted) {
        ref.read(currentChapterProvider.notifier).setChapter(chapters[state]);
      }
    }
  }
  
  bool get canGoNext {
    if (!ref.mounted) return false;
    final chapters = ref.read(chaptersListProvider);
    return state < chapters.length - 1;
  }
  
  bool get canGoPrevious {
    return state > 0;
  }
  
  /// Load chapters for a book
  void loadChapters(List<Chapter> chapters) {
    ref.read(chaptersListProvider.notifier).loadChapters(chapters);
    if (chapters.isNotEmpty) {
      state = 0;
      ref.read(currentChapterProvider.notifier).setChapter(chapters[0]);
    }
  }
}
