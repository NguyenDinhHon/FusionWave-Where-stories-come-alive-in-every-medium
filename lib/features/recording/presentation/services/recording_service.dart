import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/utils/logger.dart';

/// Voice recording service
class RecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  
  bool _isRecording = false;
  String? _currentRecordingPath;
  
  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;
  
  // Check if recording is supported
  Future<bool> isRecordingSupported() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      AppLogger.error('Check recording support error', error: e);
      return false;
    }
  }
  
  // Request permission
  Future<bool> requestPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      AppLogger.error('Request permission error', error: e);
      return false;
    }
  }
  
  // Start recording
  Future<String?> startRecording() async {
    try {
      if (_isRecording) {
        AppLogger.warning('Recording already in progress');
        return _currentRecordingPath;
      }
      
      // Get directory for recordings
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }
      
      // Generate filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${recordingsDir.path}/recording_$timestamp.m4a';
      
      // Start recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );
      
      _isRecording = true;
      _currentRecordingPath = filePath;
      
      AppLogger.info('Recording started: $filePath');
      return filePath;
    } catch (e) {
      AppLogger.error('Start recording error', error: e);
      _isRecording = false;
      _currentRecordingPath = null;
      rethrow;
    }
  }
  
  // Stop recording
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        AppLogger.warning('No recording in progress');
        return null;
      }
      
      final path = await _recorder.stop();
      _isRecording = false;
      
      AppLogger.info('Recording stopped: $path');
      return path;
    } catch (e) {
      AppLogger.error('Stop recording error', error: e);
      _isRecording = false;
      rethrow;
    }
  }
  
  // Cancel recording
  Future<void> cancelRecording() async {
    try {
      if (!_isRecording) return;
      
      await _recorder.stop();
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      _isRecording = false;
      _currentRecordingPath = null;
      
      AppLogger.info('Recording cancelled');
    } catch (e) {
      AppLogger.error('Cancel recording error', error: e);
      rethrow;
    }
  }
  
  // Get recording duration (if available)
  Future<Duration?> getRecordingDuration() async {
    try {
      if (!_isRecording) return null;
      // Note: Record package doesn't provide duration directly
      // You might need to use a timer or other method
      return null;
    } catch (e) {
      AppLogger.error('Get recording duration error', error: e);
      return null;
    }
  }
  
  // Dispose
  Future<void> dispose() async {
    try {
      if (_isRecording) {
        await cancelRecording();
      }
      await _recorder.dispose();
    } catch (e) {
      AppLogger.error('Dispose recording service error', error: e);
    }
  }
}

