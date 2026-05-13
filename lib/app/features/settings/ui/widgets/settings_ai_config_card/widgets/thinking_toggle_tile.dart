import 'package:flutter/material.dart';
import 'package:refyn/app/features/settings/action_utils/settings_action_utils.dart';
import 'package:refyn/app/features/settings/controllers/settings_controller.dart';
import 'package:refyn/app/features/settings/ui/utils/settings_pallete.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';

class ThinkingToggleTile extends StatelessWidget {
  const ThinkingToggleTile({
    super.key,
    required this.controller,
    required this.highlighted,
  });

  final SettingsController controller;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: controller.isSavingThinkingMode ? 0.7 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: highlighted
              ? cs.primary.withValues(alpha: 0.12)
              : SettingsPagePalette.rowBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlighted
                ? cs.primary
                : SettingsPagePalette.cardBorder(context),
            width: highlighted ? 1.4 : 1,
          ),
          boxShadow: highlighted
              ? <BoxShadow>[
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.16),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ]
              : const <BoxShadow>[],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.l10n.deeperThinking,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.isThinkingEnabled
                        ? context.l10n.deeperThinkingOn
                        : context.l10n.deeperThinkingOff,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: controller.isThinkingEnabled,
              onChanged: controller.isSavingThinkingMode
                  ? null
                  : (bool value) =>
                  SettingsActionUtils.saveAiThinkingEnabled(context, value),
            ),
          ],
        ),
      ),
    );
  }
}