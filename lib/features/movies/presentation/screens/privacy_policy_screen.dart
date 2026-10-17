import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/theme/app_dimens.dart';
import 'package:movie_app/core/theme/app_text_styles.dart';

/// In-app Privacy Policy screen complying with Google Play Store & Apple App Store guidelines
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _openHostedUrl(BuildContext context) async {
    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open external browser link.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: AppTextStyles.headlineMedium(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Open in browser',
            icon: const Icon(Icons.open_in_browser_rounded),
            onPressed: () => _openHostedUrl(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space20,
          vertical: AppDimens.space16,
        ),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppConstants.appName} Privacy Policy',
              style: AppTextStyles.headlineLarge(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppDimens.space6),
            Text(
              'Last Updated: ${DateTime.now().year}',
              style: AppTextStyles.bodySmall(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const Divider(height: AppDimens.space28),

            _buildSection(
              title: '1. Overview',
              content:
                  '${AppConstants.appName} ("we", "our", or "the app"), created by ${AppConstants.developerName}, is a movie discovery and trailer preview application designed to help users browse movie metadata, watch official promotional trailers, and discover legal watch options.',
              isDark: isDark,
            ),

            _buildSection(
              title: '2. Information Collection and Use',
              content:
                  '${AppConstants.appName} does NOT collect, harvest, sell, or share any personally identifiable information (PII). We do not require account registration or login. Your watchlist, favorites, and theme preferences are stored locally on your device via secure device storage (SharedPreferences) and never transmitted to external servers.',
              isDark: isDark,
            ),

            _buildSection(
              title: '3. Third-Party APIs and Services',
              content:
                  '• The Movie Database (TMDB): We use the TMDB API to deliver movie synopses, posters, credits, and metadata. This product uses the TMDB API but is not endorsed or certified by TMDB.\n\n• YouTube / Google LLC: Video playback of official trailers, teasers, and clips utilizes YouTube iFrame players in compliance with YouTube Terms of Service and Developer Policies. We do not download, rip, cache, or store YouTube video files.\n\n• OMDb API: ${AppConstants.omdbAttribution}\n\n• JustWatch: Streaming availability provider attribution.',
              isDark: isDark,
            ),

            _buildSection(
              title: '4. Copyright & Non-Hosting Disclaimer',
              content: AppConstants.contentDisclaimer,
              isDark: isDark,
            ),

            _buildSection(
              title: '5. Permissions Used',
              content:
                  '• INTERNET: Required to load movie metadata and trailer thumbnails.\n• ACCESS_NETWORK_STATE: Required to detect offline mode and notify users.',
              isDark: isDark,
            ),

            _buildSection(
              title: '6. Children\'s Privacy',
              content:
                  '${AppConstants.appName} does not knowingly collect any information from children under 13 years of age. Our service complies with COPPA and global child protection standards.',
              isDark: isDark,
            ),

            _buildSection(
              title: '7. Contact Us',
              content:
                  'If you have any questions or feedback regarding this Privacy Policy, please contact developer ${AppConstants.developerName} at:\nEmail: ${AppConstants.supportEmail}\nGitHub: ${AppConstants.githubUrl}',
              isDark: isDark,
            ),

            const SizedBox(height: AppDimens.space24),
            Center(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, AppDimens.minTouchTarget),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimens.borderRadiusMd,
                  ),
                ),
                onPressed: () => _openHostedUrl(context),
                icon: const Icon(Icons.language_rounded, size: 18),
                label: const Text('View Online Policy'),
              ),
            ),
            const SizedBox(height: AppDimens.space40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppDimens.space8),
          Text(
            content,
            style: AppTextStyles.bodyMedium(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
