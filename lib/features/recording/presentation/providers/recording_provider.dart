import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recording_service.dart';

/// Recording service provider
final recordingServiceProvider = Provider<RecordingService>((ref) {
  final service = RecordingService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Recording controller provider
final recordingControllerProvider = Provider<RecordingController>((ref) {
  return RecordingController(ref.read(recordingServiceProvider));
});

class RecordingController {
  final RecordingService _service;
  
  RecordingController(this._service);
  
  Future<bool> isRecordingSupported() => _service.isRecordingSupported();
  Future<bool> requestPermission() => _service.requestPermission();
  Future<String?> startRecording() => _service.startRecording();
  Future<String?> stopRecording() => _service.stopRecording();
  Future<void> cancelRecording() => _service.cancelRecording();
  Future<Duration?> getRecordingDuration() => _service.getRecordingDuration();
  
  bool get isRecording => _service.isRecording;
  String? get currentRecordingPath => _service.currentRecordingPath;
}

