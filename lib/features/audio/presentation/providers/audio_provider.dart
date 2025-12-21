import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_player_service.dart';
import 'package:just_audio/just_audio.dart';

/// Audio player service provider
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Audio player state provider
final audioPlayerStateProvider = StreamProvider<PlayerState>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.playerStateStream;
});

/// Audio position provider
final audioPositionProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.positionStream;
});

/// Audio duration provider
final audioDurationProvider = StreamProvider<Duration?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.durationStream;
});

/// Audio playing state provider
final audioPlayingProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.playingStream;
});

/// Audio controller provider
final audioControllerProvider = Provider<AudioController>((ref) {
  return AudioController(ref.read(audioPlayerServiceProvider));
});

class AudioController {
  final AudioPlayerService _service;
  
  AudioController(this._service);
  
  Future<void> play(String url) => _service.play(url);
  Future<void> playFile(String path) => _service.playFile(path);
  Future<void> setPlaylist(List<String> urls, {int initialIndex = 0}) => 
      _service.setPlaylist(urls, initialIndex: initialIndex);
  Future<void> playAudio() => _service.playAudio();
  Future<void> pause() => _service.pause();
  Future<void> stop() => _service.stop();
  Future<void> seek(Duration position) => _service.seek(position);
  Future<void> setSpeed(double speed) => _service.setSpeed(speed);
  Future<void> skipToNext() => _service.skipToNext();
  Future<void> skipToPrevious() => _service.skipToPrevious();
  Future<void> setVolume(double volume) => _service.setVolume(volume);
  
  bool get isPlaying => _service.isPlaying;
  Duration get position => _service.position;
  Duration? get duration => _service.duration;
  double get speed => _service.speed;
  int? get currentIndex => _service.currentIndex;
}

