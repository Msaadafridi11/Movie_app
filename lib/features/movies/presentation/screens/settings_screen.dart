import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/theme/app_dimens.dart';
import 'package:movie_app/core/theme/app_text_styles.dart';
import 'package:movie_app/core/widgets/developer_footer.dart';
import 'package:movie_app/features/movies/presentation/screens/privacy_policy_screen.dart';
import 'package:movie_app/features/movies/presentation/screens/terms_of_use_screen.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/theme_viewmodel.dart';

/// Comprehensive Settings & About screen meeting Google Play and Apple App Store legal requirements
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = AppConstants.appVersion;
  String _buildNumber = '1';
  final InAppReview _inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = info.version;
          _buildNumber = info.buildNumber;
        });
      }
    } catch (_) {}
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _sendSupportEmail() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      queryParameters: {
        'subject': '${AppConstants.appName} Support & Feedback',
        'body': 'App Version: $_version ($_buildNumber)\nDevice Feedback:\n',
      },
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please contact support directly at ${AppConstants.supportEmail}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        await _launchUrl(AppConstants.githubUrl);
      }
    } catch (_) {
      await _launchUrl(AppConstants.githubUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeVm = context.watch<ThemeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings & About',
          style: AppTextStyles.headlineMedium(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Appearance
            _buildSectionHeader('Appearance', isDark),
            Card(
              child: SwitchListTile(
                secondary: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppDimens.borderRadiusSm,
                  ),
                  child: Icon(
                    themeVm.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  'Dark Theme',
                  style: AppTextStyles.titleMedium(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                subtitle: Text(
                  themeVm.isDarkMode
                      ? 'Cinematic dark theme enabled'
                      : 'Clean light theme enabled',
                  style: AppTextStyles.bodySmall(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                value: themeVm.isDarkMode,
                activeTrackColor: AppColors.primary,
                onChanged: (_) => themeVm.toggleTheme(),
              ),
            ),

            const SizedBox(height: AppDimens.space24),

            // Section 2: Feedback & Rating
            _buildSectionHeader('Support & Feedback', isDark),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.12),
                        borderRadius: AppDimens.borderRadiusSm,
                      ),
                      child: const Icon(Icons.mail_outline_rounded, color: Colors.blueAccent),
                    ),
                    title: Text(
                      'Report a Problem / Contact',
                      style: AppTextStyles.titleMedium(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Reach out directly to developer Saad Afridi',
                      style: AppTextStyles.bodySmall(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _sendSupportEmail,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: AppDimens.borderRadiusSm,
                      ),
                      child: const Icon(Icons.star_rounded, color: AppColors.gold),
                    ),
                    title: Text(
                      'Rate this app',
                      style: AppTextStyles.titleMedium(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Share your feedback on the App Store / Play Store',
                      style: AppTextStyles.bodySmall(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _requestReview,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.space24),

            // Section 3: About & Legal
            _buildSectionHeader('About & Legal', isDark),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Logo, Name & Version Info
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: AppDimens.borderRadiusMd,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimens.space14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppConstants.appName,
                                style: AppTextStyles.headlineMedium(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                '${AppConstants.developerCreditText} • v$_version ($_buildNumber)',
                                style: AppTextStyles.bodySmall(
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.space16),

                    // Dynamic Copyright Notice
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.space12,
                        vertical: AppDimens.space8,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                        borderRadius: AppDimens.borderRadiusSm,
                      ),
                      child: Text(
                        AppConstants.copyrightNotice,
                        style: AppTextStyles.bodySmall(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.space16),

                    // TMDB Required Attribution with Logo and external link
                    Container(
                      padding: const EdgeInsets.all(AppDimens.space12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F121C) : const Color(0xFFF1F3F8),
                        borderRadius: AppDimens.borderRadiusMd,
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // TMDB Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimens.space8,
                                  vertical: AppDimens.space4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D253F),
                                  borderRadius: AppDimens.borderRadiusSm,
                                ),
                                child: Text(
                                  'TMDB',
                                  style: AppTextStyles.labelLarge(
                                    color: const Color(0xFF01B4E4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimens.space10),
                              Expanded(
                                child: Text(
                                  'The Movie Database (TMDB) API',
                                  style: AppTextStyles.titleSmall(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.space8),
                          Text(
                            ApiConstants.tmdbAttributionText,
                            style: AppTextStyles.bodySmall(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimens.space8),
                          InkWell(
                            onTap: () => _launchUrl(AppConstants.tmdbWebUrl),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Visit themoviedb.org',
                                  style: AppTextStyles.labelSmall(
                                    color: const Color(0xFF01B4E4),
                                  ),
                                ),
                                const SizedBox(width: AppDimens.space4),
                                const Icon(
                                  Icons.open_in_new_rounded,
                                  size: 13,
                                  color: Color(0xFF01B4E4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimens.space12),

                    // OMDb Attribution
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimens.space12),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
                        borderRadius: AppDimens.borderRadiusMd,
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Text(
                        AppConstants.omdbAttribution,
                        style: AppTextStyles.bodySmall(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimens.space12),

                    // Content Disclaimer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimens.space12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: AppDimens.borderRadiusMd,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppDimens.space10),
                          Expanded(
                            child: Text(
                              AppConstants.contentDisclaimer,
                              style: AppTextStyles.bodySmall(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimens.space16),
                    const Divider(height: 1),

                    // In-app Legal Screens Navigation
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                      title: Text(
                        'Privacy Policy',
                        style: AppTextStyles.titleMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'No personal data collection or tracking',
                        style: AppTextStyles.bodySmall(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.gavel_rounded, color: AppColors.primary),
                      title: Text(
                        'Terms of Use',
                        style: AppTextStyles.titleMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Terms of service and content policies',
                        style: AppTextStyles.bodySmall(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TermsOfUseScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.code_rounded, color: AppColors.primary),
                      title: Text(
                        'Open Source Licenses',
                        style: AppTextStyles.titleMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Software licenses and third-party dependencies',
                        style: AppTextStyles.bodySmall(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        showLicensePage(
                          context: context,
                          applicationName: AppConstants.appName,
                          applicationVersion: 'v$_version ($_buildNumber)',
                          applicationLegalese: AppConstants.copyrightNotice,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimens.space32),

            // Footer on the Settings Screen: "Made with ❤️ in Flutter by Saad Afridi"
            const Center(
              child: DeveloperFooter(showHeart: true),
            ),

            const SizedBox(height: AppDimens.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: AppDimens.space8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.sectionHeader(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
