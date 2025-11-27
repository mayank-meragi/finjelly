import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../providers/library_provider.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String itemId;
  final String itemName;

  const VideoPlayerScreen({
    super.key,
    required this.itemId,
    required this.itemName,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late final player = Player();
  late final controller = VideoController(player);
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _startHideTimer();
  }

  Future<void> _initPlayer() async {
    final jellyfinService = ref.read(jellyfinServiceProvider);
    final url = await jellyfinService.getPlaybackUrl(widget.itemId);
    await player.open(Media(url));
  }

  @override
  void dispose() {
    player.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _onUserInteraction() {
    if (!_showControls) {
      setState(() {
        _showControls = true;
      });
    }
    _startHideTimer();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MouseRegion(
        onHover: (_) => _onUserInteraction(),
        child: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              Video(controller: controller, controls: NoVideoControls),
              if (_showControls) ...[
                // Top Bar (Back Button)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // TODO: Implement fullscreen toggle
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom Controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Progress Bar
                        StreamBuilder<Duration>(
                          stream: player.stream.position,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            final duration = player.state.duration;
                            return SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.amber,
                                inactiveTrackColor: Colors.grey,
                                thumbColor: Colors.amber,
                                trackHeight: 4.0,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6.0,
                                ),
                              ),
                              child: Slider(
                                value: position.inSeconds.toDouble(),
                                min: 0.0,
                                max: duration.inSeconds.toDouble(),
                                onChanged: (value) {
                                  player.seek(Duration(seconds: value.toInt()));
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        // Controls Row
                        Row(
                          children: [
                            // Left: Info
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.itemName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  StreamBuilder<Duration>(
                                    stream: player.stream.position,
                                    builder: (context, snapshot) {
                                      final position =
                                          snapshot.data ?? Duration.zero;
                                      final duration = player.state.duration;
                                      return Text(
                                        '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // Center: Playback Controls
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.skip_previous,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      // Previous item logic if needed
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.replay_10,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      player.seek(
                                        player.state.position -
                                            const Duration(seconds: 10),
                                      );
                                    },
                                  ),
                                  StreamBuilder<bool>(
                                    stream: player.stream.playing,
                                    builder: (context, snapshot) {
                                      final playing = snapshot.data ?? false;
                                      return IconButton(
                                        iconSize: 48,
                                        icon: Icon(
                                          playing
                                              ? Icons.pause_circle_filled
                                              : Icons.play_circle_filled,
                                          color: Colors.white,
                                        ),
                                        onPressed: player.playOrPause,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.forward_30,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      player.seek(
                                        player.state.position +
                                            const Duration(seconds: 30),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.skip_next,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      // Next item logic if needed
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // Right: Volume/Settings
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.volume_up,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      // TODO: Volume slider
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.settings,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      // TODO: Settings menu
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
