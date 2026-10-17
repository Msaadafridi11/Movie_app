import 'package:flutter/material.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/theme/app_dimens.dart';
import 'package:movie_app/core/theme/app_text_styles.dart';

/// Generic Error View with illustration icon, friendly sanitized message, and retry button
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  String get _friendlyMessage {
    if (message.trim().isEmpty) {
      return 'Unable to load content right now. Please check your connection and try again.';
    }
    final lower = message.toLowerCase();
    if (lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('offline') ||
        lower.contains('connection')) {
      return 'No internet connection. Please verify your network settings and tap retry.';
    }
    if (lower.contains('dio') ||
        lower.contains('formatexception') ||
        lower.contains('handshake') ||
        lower.contains('status code')) {
      return 'A temporary network interruption occurred while connecting to the movie service. Please tap retry.';
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space24,
          vertical: AppDimens.space20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimens.space18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimens.space16),
            Text(
              'Oops! Something went wrong',
              style: AppTextStyles.headlineMedium(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              _friendlyMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimens.space24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, AppDimens.minTouchTarget),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimens.borderRadiusMd,
                  ),
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
