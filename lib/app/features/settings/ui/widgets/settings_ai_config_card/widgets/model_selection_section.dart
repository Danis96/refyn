import 'package:flutter/material.dart';
import 'package:refyn/app/features/settings/action_utils/settings_action_utils.dart';
import 'package:refyn/app/features/settings/controllers/settings_controller.dart';
import 'package:refyn/app/features/settings/ui/utils/settings_pallete.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'thinking_toggle_tile.dart';

class ModelSelectionSection extends StatelessWidget {
  const ModelSelectionSection({
    super.key,
    required this.controller,
    required this.thinkingModeKey,
    required this.highlightThinkingMode,
  });

  final SettingsController controller;
  final GlobalKey? thinkingModeKey;
  final bool highlightThinkingMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Validate that the selected model still exists in the available list.
    final selectedModelId =
    controller.availableModels
        .where((o) => o.id == controller.selectedModelId)
        .length ==
        1
        ? controller.selectedModelId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.l10n.model,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.modelSelectionDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: ValueKey<String?>(selectedModelId),
          initialValue: selectedModelId,
          isExpanded: true,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight: 220,
          dropdownColor: cs.surface,
          decoration: InputDecoration(
            filled: true,
            fillColor: SettingsPagePalette.rowBackground(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: SettingsPagePalette.cardBorder(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: SettingsPagePalette.cardBorder(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 1.3),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
          items: controller.availableModels
              .map(
                (option) => DropdownMenuItem<String>(
              value: option.id,
              child: Text(
                option.id,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
              .toList(growable: false),
          onChanged: controller.isSavingSelectedModel
              ? null
              : (String? value) {
            if (value == null) return;
            SettingsActionUtils.saveSelectedAiModel(context, value);
          },
        ),
        const SizedBox(height: 14),
        ThinkingToggleTile(
          key: thinkingModeKey,
          controller: controller,
          highlighted: highlightThinkingMode,
        ),
      ],
    );
  }
}