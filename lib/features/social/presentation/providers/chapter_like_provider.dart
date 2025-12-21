import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/social_provider.dart';

/// Provider to check if a chapter is liked
final chapterLikedProvider = FutureProvider.family<bool, String>((ref, chapterId) async {
  final controller = ref.read(socialControllerProvider);
  return controller.isChapterLiked(chapterId);
});

/// Provider to get chapter like count
final chapterLikeCountProvider = FutureProvider.family<int, String>((ref, chapterId) async {
  final controller = ref.read(socialControllerProvider);
  return controller.getChapterLikeCount(chapterId);
});

