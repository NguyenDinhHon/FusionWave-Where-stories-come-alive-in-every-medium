import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../services/video_player_service.dart';

/// Video player service provider
final videoPlayerServiceProvider = Provider<VideoPlayerService>((ref) {
  final service = VideoPlayerService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Video controller provider
final videoControllerProvider = Provider<VideoController>((ref) {
  return VideoController(ref.read(videoPlayerServiceProvider));
});

class VideoController {
  final VideoPlayerService _service;
  
  VideoController(this._service);
  
  VideoPlayerController? get controller => _service.controller;
  
  Future<void> initializeFromUrl(String url) => _service.initializeFromUrl(url);
  Future<void> initializeFromFile(String path) => _service.initializeFromFile(path);
  Future<void> play() => _service.play();
  Future<void> pause() => _service.pause();
  Future<void> seekTo(Duration position) => _service.seekTo(position);
  Future<void> setVolume(double volume) => _service.setVolume(volume);
  Future<void> setPlaybackSpeed(double speed) => _service.setPlaybackSpeed(speed);
  Future<void> toggleFullscreen() => _service.toggleFullscreen();
  
  bool get isInitialized => _service.isInitialized;
  bool get isPlaying => _service.isPlaying;
  Duration get position => _service.position;
  Duration get duration => _service.duration;
}

