// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReadingModeNotifier)
final readingModeProvider = ReadingModeNotifierProvider._();

final class ReadingModeNotifierProvider
    extends $NotifierProvider<ReadingModeNotifier, ReadingMode> {
  ReadingModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingModeNotifierHash();

  @$internal
  @override
  ReadingModeNotifier create() => ReadingModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingMode>(value),
    );
  }
}

String _$readingModeNotifierHash() =>
    r'1392db63c5dee8f691c290717948b66126e2b692';

abstract class _$ReadingModeNotifier extends $Notifier<ReadingMode> {
  ReadingMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ReadingMode, ReadingMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReadingMode, ReadingMode>,
              ReadingMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ControlsVisibility)
final controlsVisibilityProvider = ControlsVisibilityProvider._();

final class ControlsVisibilityProvider
    extends $NotifierProvider<ControlsVisibility, bool> {
  ControlsVisibilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'controlsVisibilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$controlsVisibilityHash();

  @$internal
  @override
  ControlsVisibility create() => ControlsVisibility();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$controlsVisibilityHash() =>
    r'4635064a7b1951ce60d21fabd94aba731a580fc5';

abstract class _$ControlsVisibility extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
