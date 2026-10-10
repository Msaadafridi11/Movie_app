import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';

/// Immersive Full-Screen YouTube player with playlist auto-play
class FullScreenVideoPlayerPage extends StatefulWidget {
  final List<Video> videos;
  final int initialIndex;
  final String movieTitle;

  const FullScreenVideoPlayerPage({
    super.key,
    required this.videos,
    this.initialIndex = 0,
    required this.movieTitle,
  });

  @override
  State<FullScreenVideoPlayerPage> createState() => _FullScreenVideoPlayerPageState();
}

class _FullScreenVideoPlayerPageState extends State<FullScreenVideoPlayerPage>
    with WidgetsBindingObserver {
  late int _currentIndex;
  YoutubePlayerController? _controller;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.initialIndex;

    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initPlayer();
  }

  void _initPlayer() {
    if (widget.videos.isEmpty) return;
    final video = widget.videos[_currentIndex];

    _controller?.dispose();
    _controller = YoutubePlayerController(
      initialVideoId: video.key,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: _isMuted,
        isLive: false,
        forceHD: true,
        enableCaption: false,
      ),
    )..addListener(_playerListener);
  }

  void _playerListener() {
    final controller = _controller;
    if (controller == null) return;

    if (controller.value.playerState == PlayerState.ended) {
      _playNext();
    }
  }

  void _playNext() {
    if (widget.videos.isEmpty) return;
    if (_currentIndex < widget.videos.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _controller?.load(widget.videos[_currentIndex].key);
    }
  }

  void _playPrevious() {
    if (widget.videos.isEmpty) return;
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _controller?.load(widget.videos[_currentIndex].key);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _controller?.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _controller?.removeListener(_playerListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentVideo = widget.videos.isNotEmpty ? widget.videos[_currentIndex] : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.primary,
                topActions: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentVideo?.name ?? widget.movieTitle,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                      if (_isMuted) {
                        _controller?.mute();
                      } else {
                        _controller?.unMute();
                      }
                    },
                  ),
                  if (widget.videos.length > 1)
                    IconButton(
                      icon: const Icon(Icons.playlist_play_rounded, color: Colors.white, size: 28),
                      onPressed: _showPlaylistSheet,
                    ),
                ],
                bottomActions: [
                  CurrentPosition(),
                  const SizedBox(width: 8),
                  ProgressBar(
                    isExpanded: true,
                    colors: const ProgressBarColors(
                      playedColor: AppColors.primary,
                      handleColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RemainingDuration(),
                  const PlaybackSpeedButton(),
                ],
              ),
              builder: (context, player) {
                return Stack(
                  children: [
                    Center(child: player),

                    // Skip Next / Previous overlay pills
                    if (widget.videos.length > 1)
                      Positioned(
                        bottom: 45,
                        right: 20,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_currentIndex > 0)
                              IconButton(
                                icon: const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Icons.skip_previous_rounded, color: Colors.white, size: 20),
                                ),
                                onPressed: _playPrevious,
                              ),
                            if (_currentIndex < widget.videos.length - 1)
                              IconButton(
                                icon: const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Icons.skip_next_rounded, color: Colors.white, size: 20),
                                ),
                                onPressed: _playNext,
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  void _showPlaylistSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161922),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Video Playlist (${widget.videos.length})',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.videos.length,
                  itemBuilder: (context, index) {
                    final v = widget.videos[index];
                    final isPlaying = index == _currentIndex;

                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          v.thumbnailUrl,
                          width: 60,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 40,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                      title: Text(
                        v.name,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
                          color: isPlaying ? AppColors.primary : Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        v.categoryBadge,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                      trailing: isPlaying
                          ? const Icon(Icons.equalizer_rounded, color: AppColors.primary)
                          : null,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        setState(() {
                          _currentIndex = index;
                        });
                        _controller?.load(v.key);
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
}
