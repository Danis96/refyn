import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/shared/utils/currency_presets.dart';
import 'package:refyn/theme/app_colors.dart';

import '../../provider/introduction_provider.dart';

/// Final onboarding step. The user must pick a home currency before they can
/// reach the dashboard. After this is set, the only way to change it is to
/// wipe all local data via Settings.
class HomeCurrencyPickerPage extends StatefulWidget {
  const HomeCurrencyPickerPage({super.key});

  @override
  State<HomeCurrencyPickerPage> createState() => _HomeCurrencyPickerPageState();
}

class _HomeCurrencyPickerPageState extends State<HomeCurrencyPickerPage> {
  String? _selected;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 8),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.brandPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                context.l10n.onboardingCurrencyTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.onboardingCurrencySubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: kCurrencyPresets.map((CurrencyPreset p) {
                      final bool selected = _selected == p.code;
                      return _CurrencyChip(
                        preset: p,
                        selected: selected,
                        onTap: _busy
                            ? null
                            : () => setState(() => _selected = p.code),
                      );
                    }).toList(growable: false),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _selected == null || _busy
                    ? null
                    : () => _onContinue(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: AppColors.brandOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  context.l10n.onboardingCurrencyContinue,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContinue(BuildContext context) async {
    final String? code = _selected;
    if (code == null) {
      return;
    }
    setState(() => _busy = true);
    await context.read<IntroductionProvider>().setHomeCurrency(code);
  }
}

class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final CurrencyPreset preset;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color bg = selected
        ? AppColors.brandPrimary
        : scheme.surfaceContainerHighest;
    final Color fg = selected
        ? AppColors.brandOnPrimary
        : scheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(preset.flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                preset.code,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
