// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReadingPreferencesNotifier)
final readingPreferencesProvider = ReadingPreferencesNotifierProvider._();

final class ReadingPreferencesNotifierProvider
    extends $NotifierProvider<ReadingPreferencesNotifier, ReadingPreferences> {
  ReadingPreferencesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingPreferencesNotifierHash();

  @$internal
  @override
  ReadingPreferencesNotifier create() => ReadingPreferencesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingPreferences>(value),
    );
  }
}

String _$readingPreferencesNotifierHash() =>
    r'c5579740b6fd275ab5a215c591efc7f53f170fb5';

abstract class _$ReadingPreferencesNotifier
    extends $Notifier<ReadingPreferences> {
  ReadingPreferences build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ReadingPreferences, ReadingPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReadingPreferences, ReadingPreferences>,
              ReadingPreferences,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
