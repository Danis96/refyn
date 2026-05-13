import 'package:flutter/material.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'ai_config_info_sheet.dart';

class AiConfigInfoButton extends StatelessWidget {
  const AiConfigInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showInfoModal(context),
      icon: const Icon(Icons.info_outline_rounded),
      iconSize: 20,
      visualDensity: VisualDensity.compact,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      tooltip: context.l10n.howAiConfigurationWorks,
    );
  }

  static void _showInfoModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiConfigInfoSheet(),
    );
  }
}