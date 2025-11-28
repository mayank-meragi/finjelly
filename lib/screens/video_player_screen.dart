import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../providers/library_provider.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String itemId;
  final String itemName;
  final Duration? initialPosition;

  const VideoPlayerScreen({
    super.key,
    required this.itemId,
    required this.itemName,
    this.initialPosition,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late final player = Player();
  late final controller = VideoController(player);
  bool _showControls = true;
  Timer? _hideTimer;
  final FocusNode _focusNode = FocusNode();
  List<dynamic> _chapters = [];
  bool _hoveringSeekBar = false;
  bool _isFullscreen = false;

  bool get _supportsOrientation {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _fetchChapters();
    _startHideTimer();
  }

  Future<void> _initPlayer() async {
    final jellyfinService = ref.read(jellyfinServiceProvider);
    final url = await jellyfinService.getPlaybackUrl(widget.itemId);
    await player.open(Media(url));
    final startPosition = widget.initialPosition;
    if (startPosition != null && startPosition > Duration.zero) {
      await player.seek(startPosition);
    }
    // Request focus for keyboard shortcuts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _fetchChapters() async {
    final jellyfinService = ref.read(jellyfinServiceProvider);
    final chapters = await jellyfinService.getChapters(widget.itemId);
    if (mounted) {
      setState(() {
        _chapters = chapters;
      });
    }
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

  void _onUserInteraction() {
    if (!_showControls) {
      setState(() {
        _showControls = true;
      });
    }
    _startHideTimer();
  }

  void _togglePlayPause() {
    player.playOrPause();
    _onUserInteraction();
  }

  Duration? _ticksToDuration(dynamic ticks) {
    if (ticks is num) {
      return Duration(microseconds: ticks ~/ 10);
    }
    return null;
  }

  Duration _clampPosition(Duration value) {
    var target = value;
    if (target < Duration.zero) {
      target = Duration.zero;
    }
    final total = player.state.duration;
    if (total > Duration.zero && target > total) {
      target = total;
    }
    return target;
  }

  Future<void> _seekTo(Duration position) async {
    await player.seek(_clampPosition(position));
    _onUserInteraction();
  }

  Future<void> _seekRelative(Duration offset) async {
    final current = player.state.position;
    await _seekTo(current + offset);
  }

  bool get _hasChapterNavigation {
    return _chapters.any(
      (chapter) => _ticksToDuration(chapter['StartPositionTicks']) != null,
    );
  }

  Future<void> _jumpToPreviousChapter() async {
    if (_chapters.isEmpty) return;
    final position = player.state.position;
    const threshold = Duration(seconds: 2);
    for (var i = _chapters.length - 1; i >= 0; i--) {
      final start = _ticksToDuration(_chapters[i]['StartPositionTicks']);
      if (start == null) continue;
      if (start < position - threshold) {
        await _seekTo(start);
        return;
      }
    }
    await _seekTo(Duration.zero);
  }

  Future<void> _jumpToNextChapter() async {
    if (_chapters.isEmpty) return;
    final position = player.state.position;
    const threshold = Duration(seconds: 1);
    for (final chapter in _chapters) {
      final start = _ticksToDuration(chapter['StartPositionTicks']);
      if (start == null) continue;
      if (start > position + threshold) {
        await _seekTo(start);
        return;
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '$minutes:${twoDigits(seconds)}';
    }
  }

  String _formatTime(DateTime time) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = twoDigits(time.minute);
    return '$hour:$minute $period';
  }

  String _trackLabelFromFields({
    required String? title,
    required String? language,
    required String id,
  }) {
    final trimmedTitle = title?.trim();
    if (trimmedTitle != null && trimmedTitle.isNotEmpty) {
      return trimmedTitle;
    }
    final trimmedLanguage = language?.trim();
    if (trimmedLanguage != null && trimmedLanguage.isNotEmpty) {
      return trimmedLanguage;
    }
    if (id == 'auto') return 'Auto';
    if (id == 'no') return 'None';
    return id;
  }

  String _describeTrack(dynamic track) {
    if (track is VideoTrack) {
      return _trackLabelFromFields(
        title: track.title,
        language: track.language,
        id: track.id,
      );
    }
    if (track is AudioTrack) {
      return _trackLabelFromFields(
        title: track.title,
        language: track.language,
        id: track.id,
      );
    }
    if (track is SubtitleTrack) {
      return _trackLabelFromFields(
        title: track.title,
        language: track.language,
        id: track.id,
      );
    }
    return track.toString();
  }

  void _showTrackSelection(
    String title,
    List<dynamic> tracks,
    Function(dynamic) onSelect,
    dynamic currentTrack,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    final isSelected = track == currentTrack;
                    final trackName = _describeTrack(track);
                    return ListTile(
                      title: Text(trackName),
                      trailing: isSelected ? const Icon(Icons.check) : null,
                      onTap: () {
                        onSelect(track);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _restoreSystemUI();
    player.dispose();
    _hideTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _enterFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    if (_supportsOrientation) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    if (mounted) {
      setState(() {
        _isFullscreen = true;
      });
    }
  }

  Future<void> _restoreSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (_supportsOrientation) {
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
  }

  Future<void> _exitFullscreen() async {
    await _restoreSystemUI();
    if (mounted) {
      setState(() {
        _isFullscreen = false;
      });
    }
  }

  Future<void> _toggleFullscreen() async {
    if (_isFullscreen) {
      await _exitFullscreen();
    } else {
      await _enterFullscreen();
    }
    _onUserInteraction();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): _togglePlayPause,
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: MouseRegion(
            onHover: (_) => _onUserInteraction(),
            child: GestureDetector(
              onTap: _togglePlayPause, // Click anywhere to toggle play/pause
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  Video(controller: controller, controls: NoVideoControls),
                  if (_showControls) ...[
                    // Top Bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text(
                              widget.itemName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _toggleFullscreen,
                              color: Colors.white,
                              icon: Icon(
                                _isFullscreen
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                              ),
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
                      child: GestureDetector(
                        onTap:
                            () {}, // Prevent tap from bubbling to video (toggle play)
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Seek Bar with Buffer and Chapters
                              MouseRegion(
                                onEnter: (_) {
                                  setState(() {
                                    _hoveringSeekBar = true;
                                  });
                                },
                                onExit: (_) {
                                  setState(() {
                                    _hoveringSeekBar = false;
                                  });
                                },
                                child: StreamBuilder<Duration>(
                                  stream: player.stream.position,
                                  builder: (context, positionSnapshot) {
                                    final position =
                                        positionSnapshot.data ?? Duration.zero;
                                    final duration = player.state.duration;

                                    return StreamBuilder<Duration>(
                                      stream: player.stream.buffer,
                                      builder: (context, bufferSnapshot) {
                                        final buffer =
                                            bufferSnapshot.data ??
                                            Duration.zero;

                                        return LayoutBuilder(
                                          builder: (context, constraints) {
                                            final positionPercent =
                                                duration.inMilliseconds > 0
                                                ? position.inMilliseconds /
                                                      duration.inMilliseconds
                                                : 0.0;

                                            return SizedBox(
                                              height: 40,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Background track
                                                  Container(
                                                    height: 4,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[800],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2,
                                                          ),
                                                    ),
                                                  ),
                                                  // Buffer Bar
                                                  if (duration.inMilliseconds >
                                                      0)
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: FractionallySizedBox(
                                                        widthFactor:
                                                            buffer
                                                                .inMilliseconds /
                                                            duration
                                                                .inMilliseconds,
                                                        child: Container(
                                                          height: 4,
                                                          decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey[600],
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  2,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  // Progress Bar
                                                  if (duration.inMilliseconds >
                                                      0)
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: FractionallySizedBox(
                                                        widthFactor:
                                                            positionPercent,
                                                        child: Container(
                                                          height: 4,
                                                          decoration: BoxDecoration(
                                                            color: Colors.amber,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  2,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  // Chapter Markers
                                                  if (_chapters.isNotEmpty &&
                                                      duration.inMilliseconds >
                                                          0)
                                                    ..._chapters.map((chapter) {
                                                      final chapterTime =
                                                          chapter['StartPositionTicks'] /
                                                          10000000; // Ticks to seconds
                                                      final percent =
                                                          chapterTime /
                                                          duration.inSeconds;
                                                      if (percent < 0 ||
                                                          percent > 1) {
                                                        return const SizedBox.shrink();
                                                      }
                                                      return Positioned(
                                                        left:
                                                            constraints
                                                                .maxWidth *
                                                            percent,
                                                        child: Container(
                                                          width: 2,
                                                          height: 16,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white
                                                                .withValues(
                                                                  alpha: 0.8,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  1,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  // Custom Seek Interaction
                                                  GestureDetector(
                                                    onTapDown: (details) {
                                                      final RenderBox box =
                                                          context.findRenderObject()
                                                              as RenderBox;
                                                      final localPosition = box
                                                          .globalToLocal(
                                                            details
                                                                .globalPosition,
                                                          );
                                                      final percent =
                                                          (localPosition.dx /
                                                                  box
                                                                      .size
                                                                      .width)
                                                              .clamp(0.0, 1.0);
                                                      final seekPosition = Duration(
                                                        seconds:
                                                            (percent *
                                                                    duration
                                                                        .inSeconds)
                                                                .toInt(),
                                                      );
                                                      player.seek(seekPosition);
                                                      _onUserInteraction();
                                                    },
                                                    onHorizontalDragUpdate: (details) {
                                                      final RenderBox box =
                                                          context.findRenderObject()
                                                              as RenderBox;
                                                      final localPosition = box
                                                          .globalToLocal(
                                                            details
                                                                .globalPosition,
                                                          );
                                                      final percent =
                                                          (localPosition.dx /
                                                                  box
                                                                      .size
                                                                      .width)
                                                              .clamp(0.0, 1.0);
                                                      final seekPosition = Duration(
                                                        seconds:
                                                            (percent *
                                                                    duration
                                                                        .inSeconds)
                                                                .toInt(),
                                                      );
                                                      player.seek(seekPosition);
                                                      _onUserInteraction();
                                                    },
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      height: 40,
                                                    ),
                                                  ),
                                                  // Seek Thumb (hover only)
                                                  if (_hoveringSeekBar &&
                                                      duration.inMilliseconds >
                                                          0)
                                                    Positioned(
                                                      left:
                                                          (constraints
                                                                  .maxWidth *
                                                              positionPercent) -
                                                          8, // Center the 16px thumb
                                                      child: Container(
                                                        width: 16,
                                                        height: 16,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color:
                                                                  Colors.amber,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Time and Info Row
                              StreamBuilder<Duration>(
                                stream: player.stream.position,
                                builder: (context, snapshot) {
                                  final position =
                                      snapshot.data ?? Duration.zero;
                                  final duration = player.state.duration;
                                  final remaining = duration - position;
                                  final endsAt = DateTime.now().add(remaining);

                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (duration.inSeconds > 0)
                                        Text(
                                          'Ends at ${_formatTime(endsAt)}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              // Controls Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Subtitle button
                                  IconButton(
                                    icon: const Icon(
                                      Icons.subtitles,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _showTrackSelection(
                                        'Subtitles',
                                        player.state.tracks.subtitle,
                                        (track) =>
                                            player.setSubtitleTrack(track),
                                        player.state.track.subtitle,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.skip_previous,
                                      color: Colors.white,
                                    ),
                                    onPressed: _hasChapterNavigation
                                        ? _jumpToPreviousChapter
                                        : null,
                                  ),
                                  // Skip back 10s
                                  IconButton(
                                    icon: const Icon(
                                      Icons.replay_10,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _seekRelative(
                                        const Duration(seconds: -10),
                                      );
                                    },
                                  ),
                                  // Play/Pause
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
                                        onPressed: _togglePlayPause,
                                      );
                                    },
                                  ),
                                  // Skip forward 30s
                                  IconButton(
                                    icon: const Icon(
                                      Icons.forward_30,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _seekRelative(
                                        const Duration(seconds: 30),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.skip_next,
                                      color: Colors.white,
                                    ),
                                    onPressed: _hasChapterNavigation
                                        ? _jumpToNextChapter
                                        : null,
                                  ),
                                  // Audio button
                                  IconButton(
                                    icon: const Icon(
                                      Icons.audiotrack,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _showTrackSelection(
                                        'Audio Tracks',
                                        player.state.tracks.audio,
                                        (track) => player.setAudioTrack(track),
                                        player.state.track.audio,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
