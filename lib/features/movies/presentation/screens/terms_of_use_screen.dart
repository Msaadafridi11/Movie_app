import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/theme/app_dimens.dart';
import 'package:movie_app/core/theme/app_text_styles.dart';

/// Terms of Use screen complying with App Store and Google Play guidelines
class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  Future<void> _openHostedUrl(BuildContext context) async {
    final uri = Uri.parse(AppConstants.termsOfUseUrl);
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
          'Terms of Use',
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
              '${AppConstants.appName} Terms of Service',
              style: AppTextStyles.headlineLarge(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppDimens.space6),
            Text(
              'Effective Date: Dynamic ${DateTime.now().year}',
              style: AppTextStyles.bodySmall(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const Divider(height: AppDimens.space28),

            _buildSection(
              title: '1. Acceptance of Terms',
              content:
                  'By downloading, accessing, or using ${AppConstants.appName} ("the Application"), developed by ${AppConstants.developerName}, you agree to be bound by these Terms of Use. If you do not agree to these terms, do not use the application.',
              isDark: isDark,
            ),

            _buildSection(
              title: '2. Purpose and Non-Hosting Disclaimer',
              content:
                  '${AppConstants.appName} is an informational movie and television discovery tool. ${AppConstants.contentDisclaimer}',
              isDark: isDark,
            ),

            _buildSection(
              title: '3. Intellectual Property & API Attribution',
              content:
                  '• TMDB: ${AppConstants.appName} uses the TMDB API for metadata, synopses, and imagery, but is not endorsed or certified by TMDB.\n\n• YouTube: Video previews are rendered via YouTube official embedding services in compliance with YouTube API Services Terms of Service.\n\n• OMDb: ${AppConstants.omdbAttribution}\n\n• Trademarks: All movie titles, character names, and promotional media are property of their respective studio copyright owners.',
              isDark: isDark,
            ),

            _buildSection(
              title: '4. Permitted Use',
              content:
                  'You agree to use this application exclusively for personal, non-commercial entertainment and discovery purposes. You may not decompile, reverse-engineer, exploit, or attempt to extract copyrighted source materials.',
              isDark: isDark,
            ),

            _buildSection(
              title: '5. Limitation of Liability',
              content:
                  'The application is provided "AS IS" and "AS AVAILABLE" without warranties of any kind. ${AppConstants.developerName} is not liable for indirect, incidental, or consequential damages resulting from the use or inability to use the service.',
              isDark: isDark,
            ),

            _buildSection(
              title: '6. Contact & Support',
              content:
                  'For legal inquiries, copyright notices, or general developer support, please contact:\nDeveloper: ${AppConstants.developerName}\nEmail: ${AppConstants.supportEmail}\nRepository: ${AppConstants.githubUrl}',
              isDark: isDark,
            ),

            const SizedBox(height: AppDimens.space32),
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
                label: const Text('View Online Terms'),
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
