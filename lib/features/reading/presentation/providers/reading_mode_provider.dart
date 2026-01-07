import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/reading_mode.dart';

part 'reading_mode_provider.g.dart';

@riverpod
class ReadingModeNotifier extends _$ReadingModeNotifier {
  @override
  ReadingMode build() => ReadingMode.standard;
  
  void setMode(ReadingMode mode) {
    state = mode;
  }
}

@riverpod
class ControlsVisibility extends _$ControlsVisibility {
  @override
  bool build() => true;
  
  void show() {
    state = true;
  }
  
  void hide() {
    state = false;
  }
  
  void toggle() {
    state = !state;
  }
}
