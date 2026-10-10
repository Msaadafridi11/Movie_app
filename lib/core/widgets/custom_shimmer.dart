import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:movie_app/core/theme/app_colors.dart';

/// Reusable Shimmer container that adapts automatically to theme brightness
class CustomShimmer extends StatelessWidget {
  final Widget child;

  const CustomShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
      highlightColor: isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlightLight,
      child: child,
    );
  }
}

/// Shimmer placeholder skeleton for movie cards in horizontal lists or grids
class ShimmerMovieCard extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerMovieCard({
    super.key,
    this.width = 140,
    this.height = 210,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return CustomShimmer(
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for the featured top carousel banner
class ShimmerBanner extends StatelessWidget {
  const ShimmerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.48;
    return CustomShimmer(
      child: Container(
        height: height,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }
}
