import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/interactive_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_provider.dart';

class VideoPlayerWidget extends ConsumerStatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool showControls;
  final bool allowFullScreen;
  
  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.showControls = true,
    this.allowFullScreen = true,
  });

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget> {
  bool _isFullScreen = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideo();
    });
  }
  
  Future<void> _initializeVideo() async {
    final controller = ref.read(videoControllerProvider);
    await controller.initializeFromUrl(widget.videoUrl);
    if (widget.autoPlay && mounted) {
      await controller.play();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(videoControllerProvider);
    final videoController = controller.controller;
    
    if (videoController == null || !videoController.value.isInitialized) {
      return Container(
        height: 200,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    
    return AspectRatio(
      aspectRatio: videoController.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Video player
          VideoPlayer(videoController),
          
          // Controls overlay
          if (widget.showControls)
            _buildControlsOverlay(context, controller, videoController),
        ],
      ),
    );
  }
  
  Widget _buildControlsOverlay(
    BuildContext context,
    VideoController controller,
    VideoPlayerController videoController,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          VideoProgressIndicator(
            videoController,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.red,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.white24,
            ),
          ),
          
          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Play/Pause button
                InteractiveIconButton(
                  icon: videoController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  iconColor: Colors.white,
                  size: 40,
                  onPressed: () {
                    if (videoController.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  },
                  tooltip: videoController.value.isPlaying ? 'Pause' : 'Play',
                ),
                
                // Position/Duration
                Expanded(
                  child: Text(
                    '${_formatDuration(videoController.value.position)} / ${_formatDuration(videoController.value.duration)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                
                // Fullscreen button
                if (widget.allowFullScreen)
                  InteractiveIconButton(
                    icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    iconColor: Colors.white,
                    size: 40,
                    onPressed: () async {
                      setState(() {
                        _isFullScreen = !_isFullScreen;
                      });
                      // Toggle system UI overlay
                      if (_isFullScreen) {
                        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                      } else {
                        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                      }
                    },
                    tooltip: _isFullScreen ? 'Exit Fullscreen' : 'Fullscreen',
                  ),
              ],
            ),
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

