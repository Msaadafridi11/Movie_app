import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/widgets/developer_footer.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/theme_viewmodel.dart';

/// Settings & About Screen with Theme switch, API info, and Developer attribution
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
          style: GoogleFonts.poppins(
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
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  themeVm.isDarkMode ? 'Pitch-dark Netflix aesthetic enabled' : 'Clean light theme enabled',
                  style: GoogleFonts.poppins(
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

            // Section 2: Data Source & API
            _buildSectionHeader('Data Source', isDark),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.api_rounded, color: AppColors.primary),
                    title: Text(
                      'TMDB API Service',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Connected to api.themoviedb.org v3',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Active',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.key_rounded, color: AppColors.primary),
                    title: Text(
                      'API Key Status',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      ApiConstants.apiKey.isNotEmpty
                          ? 'Key configured in core/constants/api_constants.dart'
                          : 'No API key set',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 3: About Application
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
                            gradient: AppColors.brandGradient,
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
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Version ${AppConstants.appVersion}',
                              style: GoogleFonts.poppins(
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
                      '${AppConstants.appName} is a production-grade movie streaming discovery app built with Flutter, Clean Architecture, and MVVM design pattern. Designed to provide a sleek, fluid 60fps Netflix & Disney+ streaming experience.',
                      style: GoogleFonts.poppins(
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
                        _buildBadge('TMDB API', isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Stylish Developer Credit Footer
            Center(
              child: Column(
                children: [
                  const DeveloperFooter(showHeart: true),
                  const SizedBox(height: 10),
                  Text(
                    'Crafted with passion for cinema and code',
                    style: GoogleFonts.poppins(
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
        style: GoogleFonts.poppins(
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
        style: GoogleFonts.poppins(
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
