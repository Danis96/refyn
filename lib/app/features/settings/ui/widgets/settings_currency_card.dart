import 'package:flutter/material.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/features/settings/ui/widgets/shared/settings_card_frame.dart';
import 'package:refyn/app/features/settings/ui/widgets/shared/settings_section_header.dart';
import 'package:refyn/theme/app_colors.dart';

import '../utils/settings_pallete.dart';

class SettingsCurrencyCard extends StatelessWidget {
  const SettingsCurrencyCard({super.key, required this.currencyCode});

  final String currencyCode;

  void _showLockedInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        final ThemeData theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: <Widget>[
              const Icon(Icons.lock_outline, size: 20, color: AppColors.brandPrimary),
              const SizedBox(width: 10),
              Text(
                ctx.l10n.currency,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                ctx.l10n.currencyLockedDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SettingsPagePalette.mutedText(ctx),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SettingsPagePalette.rowBackground(ctx),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: SettingsPagePalette.cardBorder(ctx),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: SettingsPagePalette.mutedText(ctx),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ctx.l10n.currencyLockedResetHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SettingsPagePalette.mutedText(ctx),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(ctx.l10n.gotIt),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String code = currencyCode.trim().toUpperCase();

    return SettingsCardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SettingsSectionHeader(
            icon: Icons.payments_outlined,
            title: context.l10n.currency,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.currencyDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: SettingsPagePalette.mutedText(context),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showLockedInfo(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: SettingsPagePalette.rowBackground(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: SettingsPagePalette.cardBorder(context),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SettingsPagePalette.fieldBackground(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      code.isNotEmpty ? code.characters.first : '\$',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          code,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Text(
                          context.l10n.currencyLockedResetHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: SettingsPagePalette.mutedText(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: SettingsPagePalette.mutedText(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
