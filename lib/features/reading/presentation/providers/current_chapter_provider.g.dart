// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_chapter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChaptersList)
const chaptersListProvider = ChaptersListProvider._();

final class ChaptersListProvider
    extends $NotifierProvider<ChaptersList, List<Chapter>> {
  const ChaptersListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chaptersListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chaptersListHash();

  @$internal
  @override
  ChaptersList create() => ChaptersList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Chapter> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Chapter>>(value),
    );
  }
}

String _$chaptersListHash() => r'ecf1eda0d672b2471bfe80894cad32f7d560af7e';

abstract class _$ChaptersList extends $Notifier<List<Chapter>> {
  List<Chapter> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Chapter>, List<Chapter>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Chapter>, List<Chapter>>,
              List<Chapter>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CurrentChapter)
const currentChapterProvider = CurrentChapterProvider._();

final class CurrentChapterProvider
    extends $NotifierProvider<CurrentChapter, Chapter?> {
  const CurrentChapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentChapterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentChapterHash();

  @$internal
  @override
  CurrentChapter create() => CurrentChapter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Chapter? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Chapter?>(value),
    );
  }
}

String _$currentChapterHash() => r'fd1cfaefd758148ae749108ab9d0eb9bc2c07898';

abstract class _$CurrentChapter extends $Notifier<Chapter?> {
  Chapter? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Chapter?, Chapter?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Chapter?, Chapter?>,
              Chapter?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChapterNavigation)
const chapterNavigationProvider = ChapterNavigationProvider._();

final class ChapterNavigationProvider
    extends $NotifierProvider<ChapterNavigation, int> {
  const ChapterNavigationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chapterNavigationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chapterNavigationHash();

  @$internal
  @override
  ChapterNavigation create() => ChapterNavigation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$chapterNavigationHash() => r'5753b417408e63200051a5cae4f63cb5ba73f35a';

abstract class _$ChapterNavigation extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
