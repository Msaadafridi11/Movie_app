import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/presentation/widgets/video_playlist_modal.dart';
import 'package:movie_app/features/movies/presentation/widgets/video_settings_modal.dart';

/// Cinematic Custom Video Player Controls Overlay (Netflix / YouTube inspired)
class CustomVideoControlsOverlay extends StatefulWidget {
  final Video? currentVideo;
  final String movieTitle;
  final List<Video> playlist;
  final int currentIndex;
  final Set<String> failedVideoKeys;
  final bool isPlaying;
  final bool isBuffering;
  final bool isMuted;
  final bool isLooping;
  final bool isCaptionsEnabled;
  final bool isFullScreen;
  final bool isOffline;
  final Duration currentPosition;
  final Duration totalDuration;
  final double bufferedFraction;
  final double playbackSpeed;
  final String playbackQuality;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleLoop;
  final VoidCallback onToggleCaptions;
  final VoidCallback onToggleFullScreen;
  final VoidCallback onPlayNext;
  final VoidCallback onPlayPrevious;
  final VoidCallback? onClose;
  final ValueChanged<Duration> onSeekTo;
  final ValueChanged<int> onSeekRelative;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<int> onSelectPlaylistVideo;
  final VoidCallback? onRetryOffline;

  const CustomVideoControlsOverlay({
    super.key,
    required this.currentVideo,
    required this.movieTitle,
    required this.playlist,
    required this.currentIndex,
    required this.failedVideoKeys,
    required this.isPlaying,
    required this.isBuffering,
    required this.isMuted,
    required this.isLooping,
    required this.isCaptionsEnabled,
    required this.isFullScreen,
    required this.isOffline,
    required this.currentPosition,
    required this.totalDuration,
    required this.bufferedFraction,
    required this.playbackSpeed,
    required this.playbackQuality,
    required this.onTogglePlayPause,
    required this.onToggleMute,
    required this.onToggleLoop,
    required this.onToggleCaptions,
    required this.onToggleFullScreen,
    required this.onPlayNext,
    required this.onPlayPrevious,
    this.onClose,
    required this.onSeekTo,
    required this.onSeekRelative,
    required this.onSpeedChanged,
    required this.onSelectPlaylistVideo,
    this.onRetryOffline,
  });

  @override
  State<CustomVideoControlsOverlay> createState() => _CustomVideoControlsOverlayState();
}

class _CustomVideoControlsOverlayState extends State<CustomVideoControlsOverlay>
    with SingleTickerProviderStateMixin {
  bool _showControls = true;
  Timer? _hideTimer;

  // Double-tap skip ripple feedback
  int? _skipFeedbackSeconds;
  Alignment? _skipFeedbackAlignment;
  Timer? _feedbackTimer;

  // Scrubbing state
  bool _isScrubbing = false;
  double _scrubbingSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void didUpdateWidget(covariant CustomVideoControlsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying && widget.isPlaying) {
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (_showControls && widget.isPlaying && !_isScrubbing) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showControls = false);
        }
      });
    }
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

  void _triggerDoubleTapSkip(int seconds, Alignment alignment) {
    widget.onSeekRelative(seconds);
    _feedbackTimer?.cancel();
    setState(() {
      _skipFeedbackSeconds = seconds;
      _skipFeedbackAlignment = alignment;
      _showControls = true;
    });
    _feedbackTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _skipFeedbackSeconds = null;
          _skipFeedbackAlignment = null;
        });
        _startHideTimer();
      }
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final hours = d.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final totalSecs = widget.totalDuration.inMilliseconds / 1000.0;
    final posSecs = _isScrubbing
        ? _scrubbingSeconds
        : widget.currentPosition.inMilliseconds / 1000.0;
    final clampedPos = totalSecs > 0 ? posSecs.clamp(0.0, totalSecs) : 0.0;
    final clampedTotal = totalSecs > 0 ? totalSecs : 1.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Gesture detector layer for single & double tap
        Row(
          children: [
            // Left 50% for double tap rewind
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleControls,
                onDoubleTap: () => _triggerDoubleTapSkip(-10, Alignment.centerLeft),
              ),
            ),
            // Right 50% for double tap forward
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleControls,
                onDoubleTap: () => _triggerDoubleTapSkip(10, Alignment.centerRight),
              ),
            ),
          ],
        ),

        // Double-tap visual feedback indicator
        if (_skipFeedbackSeconds != null && _skipFeedbackAlignment != null)
          Align(
            alignment: _skipFeedbackAlignment!,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _skipFeedbackSeconds! > 0
                          ? Icons.fast_forward_rounded
                          : Icons.fast_rewind_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _skipFeedbackSeconds! > 0 ? '+10s' : '-10s',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Buffering spinner indicator (always centered if buffering)
        if (widget.isBuffering)
          IgnorePointer(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Buffering...',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Offline Banner
        if (widget.isOffline)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No Internet connection • Check network',
                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  if (widget.onRetryOffline != null)
                    GestureDetector(
                      onTap: widget.onRetryOffline,
                      child: Text(
                        'Retry',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Animated Controls Overlay
        IgnorePointer(
          ignoring: !_showControls,
          child: AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                top: widget.isFullScreen,
                bottom: widget.isFullScreen,
                left: widget.isFullScreen,
                right: widget.isFullScreen,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar
                    _buildTopBar(context),

                    // Center Playback Controls
                    _buildCenterControls(),

                    // Bottom Bar (Progress bar, Times, Mute, Fullscreen)
                    _buildBottomBar(context, clampedPos, clampedTotal),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Close or Back Button
          IconButton(
            icon: Icon(
              widget.isFullScreen
                  ? Icons.arrow_back_rounded
                  : Icons.close_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              if (widget.isFullScreen) {
                widget.onToggleFullScreen();
              } else if (widget.onClose != null) {
                widget.onClose!();
              }
            },
          ),
          const SizedBox(width: 4),

          // Title & Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.currentVideo?.name ?? widget.movieTitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.movieTitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Captions Toggle
          IconButton(
            tooltip: 'Captions / Subtitles',
            icon: Icon(
              Icons.closed_caption_rounded,
              color: widget.isCaptionsEnabled ? AppColors.primary : Colors.white70,
              size: 22,
            ),
            onPressed: () {
              _startHideTimer();
              widget.onToggleCaptions();
            },
          ),

          // Settings (Gear) Button
          IconButton(
            tooltip: 'Playback Settings',
            icon: const Icon(
              Icons.settings_rounded,
              color: Colors.white70,
              size: 20,
            ),
            onPressed: () {
              _hideTimer?.cancel();
              VideoSettingsModal.show(
                context: context,
                currentSpeed: widget.playbackSpeed,
                onSpeedChanged: widget.onSpeedChanged,
                currentQuality: widget.playbackQuality,
                isLooping: widget.isLooping,
                onLoopChanged: (_) => widget.onToggleLoop(),
                isCaptionsEnabled: widget.isCaptionsEnabled,
                onCaptionsChanged: (_) => widget.onToggleCaptions(),
              );
            },
          ),

          // Playlist button (if multiple videos)
          if (widget.playlist.length > 1)
            IconButton(
              tooltip: 'Playlist',
              icon: const Icon(
                Icons.playlist_play_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                _hideTimer?.cancel();
                VideoPlaylistModal.show(
                  context: context,
                  videos: widget.playlist,
                  currentIndex: widget.currentIndex,
                  failedVideoKeys: widget.failedVideoKeys,
                  onSelectVideo: widget.onSelectPlaylistVideo,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    final hasMultiple = widget.playlist.length > 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Video
          if (hasMultiple)
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 28),
              onPressed: () {
                _startHideTimer();
                widget.onPlayPrevious();
              },
            ),

          const SizedBox(width: 8),

          // Skip -10s
          IconButton(
            tooltip: 'Rewind 10 seconds',
            icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 30),
            onPressed: () {
              _startHideTimer();
              widget.onSeekRelative(-10);
            },
          ),

          const SizedBox(width: 14),

          // Big Circular Play/Pause Button
          GestureDetector(
            onTap: () {
              _startHideTimer();
              widget.onTogglePlayPause();
            },
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFFFF4545)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Skip +10s
          IconButton(
            tooltip: 'Forward 10 seconds',
            icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 30),
            onPressed: () {
              _startHideTimer();
              widget.onSeekRelative(10);
            },
          ),

          const SizedBox(width: 8),

          // Next Video
          if (hasMultiple)
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
              onPressed: () {
                _startHideTimer();
                widget.onPlayNext();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, double clampedPos, double clampedTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrubbing / Progress Bar with Buffered Progress
          _buildProgressBar(clampedPos, clampedTotal),

          // Row with current position, total duration, volume, and fullscreen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Times
              Row(
                children: [
                  Text(
                    _formatDuration(
                      _isScrubbing
                          ? Duration(seconds: _scrubbingSeconds.toInt())
                          : widget.currentPosition,
                    ),
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    ' / ${_formatDuration(widget.totalDuration)}',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Speed badge if not 1.0x
                  if ((widget.playbackSpeed - 1.0).abs() > 0.01)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${widget.playbackSpeed}x',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              // Controls on right: Mute & Fullscreen
              Row(
                children: [
                  // Mute / Unmute
                  IconButton(
                    icon: Icon(
                      widget.isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      _startHideTimer();
                      widget.onToggleMute();
                    },
                  ),

                  // Fullscreen toggle
                  IconButton(
                    icon: Icon(
                      widget.isFullScreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      _startHideTimer();
                      widget.onToggleFullScreen();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double clampedPos, double clampedTotal) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final playedFraction = clampedTotal > 0 ? (clampedPos / clampedTotal).clamp(0.0, 1.0) : 0.0;
        final bufferedFraction = widget.bufferedFraction.clamp(0.0, 1.0);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (details) {
            _hideTimer?.cancel();
            setState(() {
              _isScrubbing = true;
              final frac = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
              _scrubbingSeconds = frac * clampedTotal;
            });
          },
          onHorizontalDragUpdate: (details) {
            setState(() {
              final frac = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
              _scrubbingSeconds = frac * clampedTotal;
            });
          },
          onHorizontalDragEnd: (_) {
            setState(() {
              _isScrubbing = false;
            });
            widget.onSeekTo(Duration(seconds: _scrubbingSeconds.toInt()));
            _startHideTimer();
          },
          onTapDown: (details) {
            final frac = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
            final targetSecs = frac * clampedTotal;
            widget.onSeekTo(Duration(seconds: targetSecs.toInt()));
            _startHideTimer();
          },
          child: Container(
            height: 24,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Background Track
                Container(
                  height: 4,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Buffered Track
                Container(
                  height: 4,
                  width: constraints.maxWidth * bufferedFraction,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Played Track
                Container(
                  height: 4,
                  width: constraints.maxWidth * playedFraction,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Scrubbing Thumb
                Positioned(
                  left: (constraints.maxWidth * playedFraction - 6).clamp(0.0, constraints.maxWidth - 12),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.7),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
