import 'package:flutter/material.dart';
import 'package:refyn/app/features/settings/controllers/settings_controller.dart';
import 'package:refyn/l10n/app_localizations.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart';
import 'ai_config_status_row.dart';

class AiConfigStatusSwitcher extends StatelessWidget {
  const AiConfigStatusSwitcher({super.key, required this.controller});

  final SettingsController controller;

  static const _wigglyLoader = WigglyLoader.indeterminate(
    size: 20,
    arcSpan: 0.8,
    strokeWidth: 1,
    wiggleAmplitude: 1,
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _buildRow(cs, l10n),
    );
  }

  Widget _buildRow(ColorScheme cs, AppLocalizations l10n) {
    if (controller.isLoadingAiConfiguration) {
      return AiConfigStatusRow(
        key: const ValueKey<String>('loading'),
        color: cs.primary,
        icon: _wigglyLoader,
        label: l10n.loadingSavedAiConfiguration,
      );
    }
    if (controller.isConfirmingApiKey) {
      return AiConfigStatusRow(
        key: const ValueKey<String>('confirming'),
        color: cs.primary,
        icon: _wigglyLoader,
        label: l10n.confirmingKeyWithGoogleAi,
      );
    }
    if (controller.isApiKeyConfirmed) {
      return AiConfigStatusRow(
        key: const ValueKey<String>('confirmed'),
        color: const Color(0xFF2EBD73),
        icon: const Icon(Icons.check_rounded, size: 18),
        label: l10n.aiModelsAvailableLabel(controller.availableModels.length),
      );
    }
    if (controller.hasProtectedDefaultApiKey) {
      return AiConfigStatusRow(
        key: const ValueKey<String>('protected-default'),
        color: cs.secondary,
        icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
        label: l10n.builtInKeyInUse,
      );
    }
    if (controller.aiConfigurationError != null) {
      return AiConfigStatusRow(
        key: const ValueKey<String>('error'),
        color: cs.error,
        icon: const Icon(Icons.error_outline_rounded, size: 18),
        label: l10n.savedKeyInvalid,
      );
    }
    return AiConfigStatusRow(
      key: const ValueKey<String>('idle'),
      color: cs.onSurfaceVariant,
      icon: const Icon(Icons.lock_outline_rounded, size: 18),
      label: l10n.noKeySet,
    );
  }
}