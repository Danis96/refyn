import 'package:flutter/material.dart';
import 'package:refyn/app/features/settings/ui/utils/settings_pallete.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/l10n/app_localizations.dart';
import 'ai_info_card.dart';

class AiConfigInfoSheet extends StatefulWidget {
  const AiConfigInfoSheet({super.key});

  @override
  State<AiConfigInfoSheet> createState() => _AiConfigInfoSheetState();
}

class _AiConfigInfoSheetState extends State<AiConfigInfoSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future<void>.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SettingsPagePalette.cardBorder(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Flexible(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/app_icon/receipt_app_icon_clean.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  context.l10n.aiConfiguration,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  context.l10n.aiInfoSubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AiInfoCard(
                        icon: Icons.public_rounded,
                        title: l10n.bringYourOwnKey,
                        body: l10n.bringYourOwnKeyBody,
                      ),
                      const SizedBox(height: 10),
                      AiInfoCard(
                        icon: Icons.shield_outlined,
                        title: l10n.staysOnDevice,
                        body: l10n.staysOnDeviceBody,
                      ),
                      const SizedBox(height: 10),
                      AiInfoCard(
                        icon: Icons.bolt_rounded,
                        title: l10n.quotaIsYours,
                        body: l10n.quotaIsYoursBody,
                      ),
                      const SizedBox(height: 10),
                      AiInfoCard(
                        icon: Icons.model_training_rounded,
                        title: l10n.pickGemmaModel,
                        body: l10n.pickGemmaModelBody,
                      ),
                      const SizedBox(height: 14),
                      _QuickStepsCard(l10n: l10n),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: Text(context.l10n.gotIt),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick steps box — a small private widget kept in this file since it is
/// only ever used by [AiConfigInfoSheet].
class _QuickStepsCard extends StatelessWidget {
  const _QuickStepsCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final stepStyle = theme.textTheme.bodySmall?.copyWith(
      color: cs.onSurfaceVariant,
      height: 1.45,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SettingsPagePalette.rowBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SettingsPagePalette.cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.quickSteps,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.quickStep1, style: stepStyle),
          const SizedBox(height: 4),
          Text(l10n.quickStep2, style: stepStyle),
          const SizedBox(height: 4),
          Text(l10n.quickStep3, style: stepStyle),
          const SizedBox(height: 4),
          Text(l10n.quickStep4, style: stepStyle),
        ],
      ),
    );
  }
}