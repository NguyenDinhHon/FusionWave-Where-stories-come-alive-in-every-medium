import 'package:just_audio/just_audio.dart';
import '../../../../core/utils/logger.dart';

/// Audio player service using just_audio
class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  AudioPlayer get player => _audioPlayer;
  
  // Current playing state
  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;
  double get speed => _audioPlayer.speed;
  
  // Streams
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  
  // Play audio from URL
  Future<void> play(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      AppLogger.info('Playing audio: $url');
    } catch (e) {
      AppLogger.error('Play audio error', error: e);
      rethrow;
    }
  }
  
  // Play audio from file path
  Future<void> playFile(String path) async {
    try {
      await _audioPlayer.setFilePath(path);
      await _audioPlayer.play();
      AppLogger.info('Playing audio file: $path');
    } catch (e) {
      AppLogger.error('Play audio file error', error: e);
      rethrow;
    }
  }
  
  // Set playlist
  Future<void> setPlaylist(List<String> urls, {int initialIndex = 0}) async {
    try {
      final playlist = ConcatenatingAudioSource(
        children: urls.map((url) => AudioSource.uri(Uri.parse(url))).toList(),
      );
      await _audioPlayer.setAudioSource(playlist, initialIndex: initialIndex);
      AppLogger.info('Playlist set with ${urls.length} items');
    } catch (e) {
      AppLogger.error('Set playlist error', error: e);
      rethrow;
    }
  }
  
  // Play
  Future<void> playAudio() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      AppLogger.error('Play error', error: e);
      rethrow;
    }
  }
  
  // Pause
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      AppLogger.error('Pause error', error: e);
      rethrow;
    }
  }
  
  // Stop
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      AppLogger.error('Stop error', error: e);
      rethrow;
    }
  }
  
  // Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      AppLogger.error('Seek error', error: e);
      rethrow;
    }
  }
  
  // Set playback speed
  Future<void> setSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed.clamp(0.5, 2.0));
      AppLogger.info('Playback speed set to: $speed');
    } catch (e) {
      AppLogger.error('Set speed error', error: e);
      rethrow;
    }
  }
  
  // Skip to next
  Future<void> skipToNext() async {
    try {
      await _audioPlayer.seekToNext();
    } catch (e) {
      AppLogger.error('Skip to next error', error: e);
    }
  }
  
  // Skip to previous
  Future<void> skipToPrevious() async {
    try {
      await _audioPlayer.seekToPrevious();
    } catch (e) {
      AppLogger.error('Skip to previous error', error: e);
    }
  }
  
  // Set volume
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      AppLogger.error('Set volume error', error: e);
      rethrow;
    }
  }
  
  // Get current index in playlist
  int? get currentIndex => _audioPlayer.currentIndex;
  
  // Get sequence (playlist)
  SequenceState? get sequenceState => _audioPlayer.sequenceState;
  
  // Dispose
  void dispose() {
    _audioPlayer.dispose();
  }
}

