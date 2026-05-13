import 'package:flutter/material.dart';
import 'package:refyn/theme/app_spacing.dart';

class ScanErrorView extends StatelessWidget {
  const ScanErrorView({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    required this.retryLabel,
    required this.onReset,
    required this.resetLabel,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;
  final VoidCallback onReset;
  final String resetLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: errorColor.withValues(alpha: 0.55),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: errorColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: errorColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(message),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: Text(retryLabel),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: onReset,
                  child: Text(resetLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}