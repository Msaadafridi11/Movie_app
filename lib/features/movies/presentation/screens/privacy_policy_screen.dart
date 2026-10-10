import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/core/theme/app_colors.dart';

/// In-app Privacy Policy screen complying with Google Play Store guidelines
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CineFlix Privacy Policy',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Last Updated: October 2026',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            const Divider(height: 28),

            _buildSection(
              title: '1. Overview',
              content:
                  'CineFlix ("we", "our", or "the app"), created by Saad Afridi, is a movie discovery and trailer preview application designed to help users browse movie metadata, watch official promotional trailers, and discover legal watch options.',
              isDark: isDark,
            ),

            _buildSection(
              title: '2. Information Collection and Use',
              content:
                  'CineFlix does NOT collect, harvest, sell, or share any personally identifiable information (PII). We do not require account registration or login. Your watchlist, favorites, and theme preferences are stored locally on your device via secure device storage (SharedPreferences) and never transmitted to our servers.',
              isDark: isDark,
            ),

            _buildSection(
              title: '3. Third-Party APIs and Services',
              content:
                  '• The Movie Database (TMDB): We use the TMDB API to deliver movie synopses, posters, credits, and metadata. This product uses the TMDB API but is not endorsed or certified by TMDB.\n\n• YouTube / Google LLC: Video playback of official trailers, teasers, and clips utilizes YouTube iFrame players in compliance with YouTube Terms of Service and Developer Policies. We do not download, rip, cache, or store YouTube video files.\n\n• OMDb API: Optional movie rating metrics (IMDb & Rotten Tomatoes).\n\n• JustWatch: Streaming availability provider attribution.',
              isDark: isDark,
            ),

            _buildSection(
              title: '4. Copyright & Legal Streaming Notice',
              content:
                  'CineFlix does NOT stream, host, or distribute full copyrighted movies or television series. All video content consists strictly of publicly available promotional trailers and featurettes embedded via official platform APIs.',
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
                  'CineFlix does not knowingly collect any information from children under 13 years of age. Our service complies with COPPA and global child protection standards.',
              isDark: isDark,
            ),

            _buildSection(
              title: '7. Contact Us',
              content:
                  'If you have any questions or feedback regarding this Privacy Policy, please contact developer Saad Afridi at:\nEmail: msaadafridi42@gmail.com\nGitHub: https://github.com/Msaadafridi11',
              isDark: isDark,
            ),
            const SizedBox(height: 30),
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
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 13,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
