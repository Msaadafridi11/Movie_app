import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/widgets/developer_footer.dart';
import 'package:movie_app/features/movies/presentation/screens/privacy_policy_screen.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/theme_viewmodel.dart';

/// Settings & About Screen with Theme switch, Required TMDB Attribution, and Legal notices
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeVm = context.watch<ThemeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings & About',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Appearance
            _buildSectionHeader('Appearance', isDark),
            Card(
              child: SwitchListTile(
                secondary: Icon(
                  themeVm.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Dark Theme',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  themeVm.isDarkMode ? 'Cinematic dark theme enabled' : 'Clean light theme enabled',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                value: themeVm.isDarkMode,
                activeTrackColor: AppColors.primary,
                onChanged: (_) => themeVm.toggleTheme(),
              ),
            ),

            const SizedBox(height: 20),

            // Section 2: Required TMDB Attribution
            _buildSectionHeader('API & Attribution', isDark),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 50,
                            height: 38,
                            color: const Color(0xFF0D253F), // TMDB Navy Blue
                            child: Center(
                              child: Text(
                                'TMDB',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF01B4E4), // TMDB Cyan
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'The Movie Database',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                'API v3 Services Connected',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF141720) : const Color(0xFFF1F3F8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Text(
                        ApiConstants.tmdbAttributionText,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section 3: Legal & Play Store Compliance
            _buildSectionHeader('Legal & Compliance', isDark),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shield_rounded, color: AppColors.primary),
                    title: Text(
                      'Legal Streaming Notice',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'CineFlix does NOT stream or host full movies. We only provide promotional trailers via YouTube and links to licensed providers.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_rounded, color: AppColors.primary),
                    title: Text(
                      'Privacy Policy',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Zero tracking, zero PII collection',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 4: About Application
            _buildSectionHeader('About Application', isDark),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, Color(0xFFFF5252)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.movie_creation_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.appName,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Version ${AppConstants.appVersion}',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${AppConstants.appName} is a production-grade movie & TV discovery application built with Flutter, Clean Architecture, and MVVM + Provider. Delivers smooth YouTube trailer playback and comprehensive streaming availability.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        height: 1.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildBadge('Clean Architecture', isDark),
                        _buildBadge('MVVM', isDark),
                        _buildBadge('Provider', isDark),
                        _buildBadge('YouTube iFrame', isDark),
                        _buildBadge('TMDB API', isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Developer Credit Footer
            Center(
              child: Column(
                children: [
                  const DeveloperFooter(showHeart: true),
                  const SizedBox(height: 8),
                  Text(
                    'Crafted with passion for cinema and code',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildBadge(String text, bool isDark) {
    return Chip(
      label: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      backgroundColor: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
