import 'dart:io';
import 'package:video_player/video_player.dart';
import '../../../../core/utils/logger.dart';

/// Video player service
class VideoPlayerService {
  VideoPlayerController? _controller;
  
  VideoPlayerController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get isPlaying => _controller?.value.isPlaying ?? false;
  Duration get position => _controller?.value.position ?? Duration.zero;
  Duration get duration => _controller?.value.duration ?? Duration.zero;
  
  // Initialize from URL
  Future<void> initializeFromUrl(String url) async {
    try {
      await dispose();
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await _controller!.initialize();
      AppLogger.info('Video initialized from URL: $url');
    } catch (e) {
      AppLogger.error('Initialize video from URL error', error: e);
      rethrow;
    }
  }
  
  // Initialize from file path
  Future<void> initializeFromFile(String path) async {
    try {
      await dispose();
      _controller = VideoPlayerController.file(File(path));
      await _controller!.initialize();
      AppLogger.info('Video initialized from file: $path');
    } catch (e) {
      AppLogger.error('Initialize video from file error', error: e);
      rethrow;
    }
  }
  
  // Play
  Future<void> play() async {
    try {
      await _controller?.play();
    } catch (e) {
      AppLogger.error('Play video error', error: e);
      rethrow;
    }
  }
  
  // Pause
  Future<void> pause() async {
    try {
      await _controller?.pause();
    } catch (e) {
      AppLogger.error('Pause video error', error: e);
      rethrow;
    }
  }
  
  // Seek
  Future<void> seekTo(Duration position) async {
    try {
      await _controller?.seekTo(position);
    } catch (e) {
      AppLogger.error('Seek video error', error: e);
      rethrow;
    }
  }
  
  // Set volume
  Future<void> setVolume(double volume) async {
    try {
      await _controller?.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      AppLogger.error('Set volume error', error: e);
      rethrow;
    }
  }
  
  // Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      await _controller?.setPlaybackSpeed(speed);
    } catch (e) {
      AppLogger.error('Set playback speed error', error: e);
      rethrow;
    }
  }
  
  // Toggle fullscreen (platform specific)
  Future<void> toggleFullscreen() async {
    // This would need platform-specific implementation
    // For now, just a placeholder
  }
  
  // Dispose
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}

