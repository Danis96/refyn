import 'package:flutter/material.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/features/settings/ui/widgets/shared/settings_card_frame.dart';
import 'package:refyn/app/features/settings/ui/widgets/shared/settings_section_header.dart';

import '../utils/settings_pallete.dart';

class SettingsCurrencyCard extends StatelessWidget {
  const SettingsCurrencyCard({super.key, required this.currencyCode});

  final String currencyCode;

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
          Container(
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
                  child: Text(
                    code,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: SettingsPagePalette.mutedText(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
