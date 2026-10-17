import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/core/theme/app_colors.dart';

/// Modal bottom sheet for player settings:
/// Playback Speed (0.25x - 2.0x), Quality status (Auto adaptive), Loop toggle, Captions toggle.
class VideoSettingsModal extends StatelessWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedChanged;
  final String currentQuality;
  final bool isLooping;
  final ValueChanged<bool> onLoopChanged;
  final bool isCaptionsEnabled;
  final ValueChanged<bool> onCaptionsChanged;

  const VideoSettingsModal({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
    required this.currentQuality,
    required this.isLooping,
    required this.onLoopChanged,
    required this.isCaptionsEnabled,
    required this.onCaptionsChanged,
  });

  static const List<double> availableSpeeds = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  static void show({
    required BuildContext context,
    required double currentSpeed,
    required ValueChanged<double> onSpeedChanged,
    required String currentQuality,
    required bool isLooping,
    required ValueChanged<bool> onLoopChanged,
    required bool isCaptionsEnabled,
    required ValueChanged<bool> onCaptionsChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161922),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => VideoSettingsModal(
        currentSpeed: currentSpeed,
        onSpeedChanged: onSpeedChanged,
        currentQuality: currentQuality,
        isLooping: isLooping,
        onLoopChanged: onLoopChanged,
        isCaptionsEnabled: isCaptionsEnabled,
        onCaptionsChanged: onCaptionsChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Playback Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),

            // Quality Section
            Text(
              'STREAMING QUALITY',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.high_quality_rounded, color: Colors.white70, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quality: Auto ($currentQuality)',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'YouTube IFrame dynamically adapts resolution to network speed.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'AUTO',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Playback Speed Section
            Text(
              'PLAYBACK SPEED',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: availableSpeeds.map((speed) {
                  final isSelected = (currentSpeed - speed).abs() < 0.01;
                  final label = speed == 1.0 ? '1.0x (Normal)' : '${speed}x';

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.white12,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          onSpeedChanged(speed);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Switches: Loop & Captions
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    title: Text(
                      'Loop Current Video',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                    ),
                    subtitle: Text(
                      isLooping
                          ? 'Repeat single video indefinitely'
                          : 'Autoplay next video when finished',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
                    ),
                    value: isLooping,
                    onChanged: (val) {
                      onLoopChanged(val);
                    },
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  SwitchListTile(
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    title: Text(
                      'Closed Captions / Subtitles',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                    ),
                    subtitle: Text(
                      isCaptionsEnabled ? 'Subtitles enabled' : 'Subtitles disabled',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
                    ),
                    value: isCaptionsEnabled,
                    onChanged: (val) {
                      onCaptionsChanged(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

