import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';

/// Mini audio player widget for reading page
class MiniAudioPlayer extends ConsumerWidget {
  final String? audioUrl;
  final String? title;
  final List<String>? playlist;
  final int? initialIndex;
  final VoidCallback? onExpand;
  
  const MiniAudioPlayer({
    super.key,
    this.audioUrl,
    this.title,
    this.playlist,
    this.initialIndex,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioController = ref.watch(audioControllerProvider);
    final playingAsync = ref.watch(audioPlayingProvider);
    final positionAsync = ref.watch(audioPositionProvider);
    final durationAsync = ref.watch(audioDurationProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title and expand button
          Row(
            children: [
              Expanded(
                child: Text(
                  title ?? 'Audio Player',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onExpand != null)
                IconButton(
                  icon: const Icon(Icons.expand_less, size: 20),
                  onPressed: onExpand,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Progress bar
          positionAsync.when(
            data: (position) {
              return durationAsync.when(
                data: (duration) {
                  if (duration == null) {
                    return const LinearProgressIndicator();
                  }
                  
                  return Column(
                    children: [
                      Slider(
                        value: position.inMilliseconds.toDouble(),
                        min: 0,
                        max: duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          audioController.seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const SizedBox(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox(),
          ),
          
          const SizedBox(height: 8),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              if (playlist != null && playlist!.length > 1)
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 28,
                  onPressed: () => audioController.skipToPrevious(),
                ),
              
              // Play/Pause button
              playingAsync.when(
                data: (isPlaying) => IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Theme.of(context).primaryColor,
                  ),
                  iconSize: 40,
                  onPressed: () {
                    if (isPlaying) {
                      audioController.pause();
                    } else {
                      if (playlist != null && playlist!.isNotEmpty) {
                        audioController.setPlaylist(
                          playlist!,
                          initialIndex: initialIndex ?? 0,
                        );
                      } else if (audioUrl != null) {
                        audioController.play(audioUrl!);
                      } else {
                        audioController.playAudio();
                      }
                    }
                  },
                ),
                loading: () => const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, _) => const Icon(Icons.error, size: 40),
              ),
              
              // Next button
              if (playlist != null && playlist!.length > 1)
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  iconSize: 28,
                  onPressed: () => audioController.skipToNext(),
                ),
              
              // Speed control
              PopupMenuButton<double>(
                icon: const Icon(Icons.speed, size: 24),
                tooltip: 'Playback Speed',
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                  const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                  const PopupMenuItem(value: 1.0, child: Text('1.0x')),
                  const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                  const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                  const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                ],
                onSelected: (speed) {
                  audioController.setSpeed(speed);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}

