import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/features/settings/action_utils/settings_action_utils.dart';
import 'package:refyn/app/features/settings/controllers/settings_controller.dart';
import 'package:refyn/app/features/settings/controllers/settings_spotlight_controller.dart';
import 'package:refyn/app/features/settings/ui/utils/settings_pallete.dart';
import 'package:refyn/app/features/settings/ui/widgets/settings_ai_config_card/widgets/ai_config_info_button.dart';
import 'package:refyn/app/features/settings/ui/widgets/settings_ai_config_card/widgets/ai_config_status_switcher.dart';
import 'package:refyn/app/features/settings/ui/widgets/settings_ai_config_card/widgets/model_selection_section.dart';
import 'package:refyn/app/features/settings/ui/widgets/shared/settings_card_frame.dart';
import 'package:refyn/app/features/settings/ui/widgets/shared/settings_section_header.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart';

class SettingsAiConfigCard extends StatefulWidget {
  const SettingsAiConfigCard({super.key, this.thinkingModeKey});

  final GlobalKey? thinkingModeKey;

  @override
  State<SettingsAiConfigCard> createState() => _SettingsAiConfigCardState();
}

class _SettingsAiConfigCardState extends State<SettingsAiConfigCard> {
  late final TextEditingController _apiKeyController;
  SettingsController? _settingsController;
  SettingsSpotlightController? _spotlightController;
  bool _isExpanded = true;
  bool _highlightThinkingMode = false;
  int _lastHandledSpotlightId = 0;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<SettingsController>();
    if (_settingsController != controller) {
      _settingsController?.removeListener(_syncApiKeyDraft);
      _settingsController = controller;
      _settingsController!.addListener(_syncApiKeyDraft);
      _syncApiKeyDraft();
    }

    final spotlight = context.read<SettingsSpotlightController>();
    if (_spotlightController != spotlight) {
      _spotlightController?.removeListener(_handleSpotlight);
      _spotlightController = spotlight;
      _spotlightController!.addListener(_handleSpotlight);
    }
  }

  @override
  void dispose() {
    _settingsController?.removeListener(_syncApiKeyDraft);
    _spotlightController?.removeListener(_handleSpotlight);
    _apiKeyController.dispose();
    super.dispose();
  }

  void _syncApiKeyDraft() {
    final controller = _settingsController;
    if (controller == null) return;
    if (_apiKeyController.text == controller.apiKeyDraft) return;
    _apiKeyController.value = TextEditingValue(
      text: controller.apiKeyDraft,
      selection: TextSelection.collapsed(offset: controller.apiKeyDraft.length),
    );
  }

  void _handleSpotlight() {
    final controller = _spotlightController;
    if (!mounted || controller == null) return;
    if (controller.requestId == _lastHandledSpotlightId ||
        controller.target != SettingsSpotlightTarget.thinkingMode) {
      return;
    }
    _lastHandledSpotlightId = controller.requestId;
    setState(() {
      _isExpanded = true;
      _highlightThinkingMode = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _highlightThinkingMode = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final isEditingCustomKey = _apiKeyController.text.trim().isNotEmpty;
    final shouldProtectBuiltInKeyDisplay =
        controller.hasProtectedDefaultApiKey && !isEditingCustomKey;

    return SettingsCardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SettingsSectionHeader(
                      icon: Icons.auto_awesome_rounded,
                      title: context.l10n.aiConfiguration,
                    ),
                  ),
                  const AiConfigInfoButton(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.aiConfigurationDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? _ExpandedBody(
              controller: controller,
              apiKeyController: _apiKeyController,
              shouldProtectBuiltInKeyDisplay: shouldProtectBuiltInKeyDisplay,
              thinkingModeKey: widget.thinkingModeKey,
              highlightThinkingMode: _highlightThinkingMode,
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// The expanded content of the card. Kept private here since it only exists
/// as a structural split — not a reusable component.
class _ExpandedBody extends StatelessWidget {
  const _ExpandedBody({
    required this.controller,
    required this.apiKeyController,
    required this.shouldProtectBuiltInKeyDisplay,
    required this.thinkingModeKey,
    required this.highlightThinkingMode,
  });

  final SettingsController controller;
  final TextEditingController apiKeyController;
  final bool shouldProtectBuiltInKeyDisplay;
  final GlobalKey? thinkingModeKey;
  final bool highlightThinkingMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 18),
        Text(
          context.l10n.apiKey,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 430;
            return Flex(
              direction: isCompact ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: isCompact ? 0 : 1,
                  child: _ApiKeyField(
                    controller: controller,
                    apiKeyController: apiKeyController,
                    shouldProtectBuiltInKeyDisplay: shouldProtectBuiltInKeyDisplay,
                  ),
                ),
                SizedBox(
                  width: isCompact ? 0 : 12,
                  height: isCompact ? 12 : 0,
                ),
                _ApiKeyConfirmButton(
                  controller: controller,
                  isCompact: isCompact,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        AiConfigStatusSwitcher(controller: controller),
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: controller.hasModelSelection
              ? Padding(
            padding: const EdgeInsets.only(top: 18),
            child: ModelSelectionSection(
              controller: controller,
              thinkingModeKey: thinkingModeKey,
              highlightThinkingMode: highlightThinkingMode,
            ),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ApiKeyField extends StatelessWidget {
  const _ApiKeyField({
    required this.controller,
    required this.apiKeyController,
    required this.shouldProtectBuiltInKeyDisplay,
  });

  final SettingsController controller;
  final TextEditingController apiKeyController;
  final bool shouldProtectBuiltInKeyDisplay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final borderRadius = BorderRadius.circular(12);
    final borderColor = SettingsPagePalette.cardBorder(context);

    return TextField(
      controller: apiKeyController,
      enableInteractiveSelection: !shouldProtectBuiltInKeyDisplay,
      obscureText: shouldProtectBuiltInKeyDisplay
          ? true
          : !controller.isApiKeyVisible,
      onChanged: controller.updateApiKeyDraft,
      style: theme.textTheme.bodyLarge?.copyWith(
        letterSpacing: controller.isApiKeyVisible ? 0 : 1.1,
      ),
      decoration: InputDecoration(
        hintText: shouldProtectBuiltInKeyDisplay
            ? context.l10n.builtInKeyActive
            : context.l10n.pasteGoogleAiKey,
        filled: true,
        fillColor: SettingsPagePalette.fieldBackground(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: cs.primary, width: 1.4),
        ),
        suffixIcon: shouldProtectBuiltInKeyDisplay
            ? null
            : IconButton(
          onPressed: controller.toggleApiKeyVisibility,
          icon: Icon(
            controller.isApiKeyVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
        helperText: shouldProtectBuiltInKeyDisplay
            ? context.l10n.defaultKeyHiddenHelper
            : null,
        helperMaxLines: 2,
        helperStyle: theme.textTheme.bodySmall?.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ApiKeyConfirmButton extends StatelessWidget {
  const _ApiKeyConfirmButton({
    required this.controller,
    required this.isCompact,
  });

  final SettingsController controller;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final VoidCallback? onPressed = controller.isApiKeyConfirmed
        ? controller.canResetAiConfiguration
        ? () => SettingsActionUtils.resetAiConfiguration(context)
        : null
        : controller.canConfirmApiKey
        ? () => SettingsActionUtils.confirmApiKey(context)
        : null;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: Size(isCompact ? double.infinity : 118, 52),
        backgroundColor: controller.isApiKeyConfirmed
            ? cs.surfaceContainerHighest
            : cs.primary,
        foregroundColor: controller.isApiKeyConfirmed
            ? cs.onSurface
            : cs.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: controller.isConfirmingApiKey
          ? const WigglyLoader.indeterminate(
        size: 20,
        arcSpan: 0.8,
        strokeWidth: 1,
        wiggleAmplitude: 1,
      )
          : Text(
        controller.isApiKeyConfirmed
            ? context.l10n.reset
            : context.l10n.confirm,
      ),
    );
  }
}