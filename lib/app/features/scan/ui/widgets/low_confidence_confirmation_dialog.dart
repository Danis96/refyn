import 'package:flutter/material.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';

enum LowConfidenceDialogAction { dismiss, confirm, openThinkingSettings }

class LowConfidenceConfirmationDialog extends StatelessWidget {
  const LowConfidenceConfirmationDialog({
    super.key,
    required this.shouldSuggestThinkingMode,
  });

  final bool shouldSuggestThinkingMode;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextStyle? bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.4,
    );
    final TextStyle? linkStyle = bodyStyle?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w700,
    );
    final navigator = Navigator.of(context);

    return AlertDialog(
      title: Text(context.l10n.scanLowConfidenceDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.scanLowConfidenceDialogMessage,
            style: bodyStyle,
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => navigator.pop(LowConfidenceDialogAction.openThinkingSettings),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text.rich(
                TextSpan(
                  style: bodyStyle,
                  children: <InlineSpan>[
                    TextSpan(
                      text: shouldSuggestThinkingMode
                          ? context.l10n.scanLowConfidenceThinkingModeNudge
                          : context.l10n.scanLowConfidenceThinkingModeHint,
                    ),
                    TextSpan(
                      text: context.l10n.scanLowConfidenceThinkingModeLink,
                      style: linkStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => navigator.pop(LowConfidenceDialogAction.dismiss),
          child: Text(context.l10n.scanErrorDismiss),
        ),
        TextButton(
          onPressed: () => navigator.pop(LowConfidenceDialogAction.openThinkingSettings),
          child: Text(context.l10n.scanLowConfidenceOpenThinkingMode),
        ),
        FilledButton(
          onPressed: () => navigator.pop(LowConfidenceDialogAction.confirm),
          child: Text(context.l10n.scanLowConfidenceConfirmSave),
        ),
      ],
    );
  }
}
