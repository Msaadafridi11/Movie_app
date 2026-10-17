import 'package:flutter/material.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/theme/app_dimens.dart';
import 'package:movie_app/core/theme/app_text_styles.dart';

/// Friendly error screen presented when unhandled framework or rendering errors occur
/// Prevents red/grey error screens and hides raw technical stack traces from users
class GlobalFriendlyErrorWidget extends StatelessWidget {
  final FlutterErrorDetails? details;
  final VoidCallback? onRetry;

  const GlobalFriendlyErrorWidget({
    super.key,
    this.details,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space24,
              vertical: AppDimens.space32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Soft glowing error container
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.movie_filter_rounded,
                      size: 44,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.space24),

                // Friendly Title
                Text(
                  'Something Went Wrong',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineLarge(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppDimens.space10),

                // Friendly, actionable explanation
                Text(
                  'We encountered a temporary problem displaying this content. Please try again or return to the home screen.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppDimens.space28),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(130, AppDimens.minTouchTarget),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimens.borderRadiusMd,
                        ),
                      ),
                      onPressed: onRetry ??
                          () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Try Again'),
                    ),
                    const SizedBox(width: AppDimens.space12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(120, AppDimens.minTouchTarget),
                        side: BorderSide(
                          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimens.borderRadiusMd,
                        ),
                      ),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        'Go Back',
                        style: AppTextStyles.labelLarge(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
