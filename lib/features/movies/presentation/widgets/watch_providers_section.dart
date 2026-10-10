import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/features/movies/domain/entities/watch_provider.dart';

/// Where to legally watch section with Stream, Rent, Buy options
class WatchProvidersSection extends StatelessWidget {
  final List<WatchProvider> providers;

  const WatchProvidersSection({super.key, required this.providers});

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.live_tv_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Where to Watch',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            Text(
              'Powered by JustWatch',
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: providers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final provider = providers[index];
              final logoUrl = ApiConstants.watchProviderLogo(provider.logoPath);

              return Container(
                width: 76,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E212A) : const Color(0xFFF1F3F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: logoUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: logoUrl,
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.tv_rounded,
                                size: 28,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(Icons.tv_rounded, size: 28, color: AppColors.primary),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: _badgeColor(provider.type).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        provider.typeLabel.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _badgeColor(provider.type),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _badgeColor(String type) {
    switch (type.toLowerCase()) {
      case 'stream':
      case 'flatrate':
        return Colors.greenAccent;
      case 'rent':
        return Colors.amberAccent;
      case 'buy':
        return Colors.lightBlueAccent;
      default:
        return AppColors.primary;
    }
  }
}
