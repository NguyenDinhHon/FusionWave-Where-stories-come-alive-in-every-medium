import 'package:flutter/material.dart';
import '../../../../core/widgets/interactive_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';

class AudioPlayerWidget extends ConsumerWidget {
  final String? audioUrl;
  final String? title;
  final List<String>? playlist;
  final int? initialIndex;
  
  const AudioPlayerWidget({
    super.key,
    this.audioUrl,
    this.title,
    this.playlist,
    this.initialIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioController = ref.watch(audioControllerProvider);
    final playingAsync = ref.watch(audioPlayingProvider);
    final positionAsync = ref.watch(audioPositionProvider);
    final durationAsync = ref.watch(audioDurationProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position)),
                            Text(_formatDuration(duration)),
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
                InteractiveIconButton(
                  icon: Icons.skip_previous,
                  onPressed: () => audioController.skipToPrevious(),
                  tooltip: 'Previous',
                  size: 48,
                ),
              
              // Play/Pause button
              playingAsync.when(
                data: (isPlaying) => InteractiveIconButton(
                  icon: isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 56,
                  onPressed: () {
                    if (isPlaying) {
                      audioController.pause();
                    } else {
                      if (playlist != null && playlist!.isNotEmpty) {
                        audioController.setPlaylist(playlist!, initialIndex: initialIndex ?? 0);
                      } else if (audioUrl != null) {
                        audioController.play(audioUrl!);
                      } else {
                        audioController.playAudio();
                      }
                    }
                  },
                  tooltip: isPlaying ? 'Pause' : 'Play',
                ),
                loading: () => const SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(),
                ),
                error: (_, _) => const Icon(Icons.error, size: 56),
              ),
              
              // Next button
              if (playlist != null && playlist!.length > 1)
                InteractiveIconButton(
                  icon: Icons.skip_next,
                  onPressed: () => audioController.skipToNext(),
                  tooltip: 'Next',
                  size: 48,
                ),
              
              // Speed control
              PopupMenuButton<double>(
                icon: const Icon(Icons.speed),
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

