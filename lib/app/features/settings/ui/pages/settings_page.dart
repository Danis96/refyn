import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/features/export/repository/receipt_export_service.dart';
import 'package:refyn/app/features/settings/action_utils/settings_action_utils.dart';
import 'package:refyn/app/features/settings/controllers/settings_controller.dart';
import 'package:refyn/app/features/settings/controllers/settings_spotlight_controller.dart';
import 'package:refyn/app/features/settings/ui/widgets/settings_about_card.dart';
import 'package:refyn/app/features/settings/ui/widgets/settings_ai_config_card/settings_ai_config_card.dart';
import 'package:refyn/app/features/settings/ui/widgets/settings_currency_card.dart';
import 'package:refyn/app/features/settings/ui/widgets/settings_export_card.dart';
import 'package:refyn/app/features/settings/ui/widgets/settings_language_card.dart';
import 'package:refyn/app/features/settings/ui/widgets/settings_legal_card.dart';
import 'package:refyn/app/features/settings/ui/widgets/settings_theme_card.dart';
import 'package:refyn/app/features/settings/ui/widgets/settings_title_block.dart';
import 'package:refyn/app/features/travel_mode/action_utils/travel_mode_action_utils.dart';
import 'package:refyn/app/features/travel_mode/ui/widgets/travel_mode_settings_card/travel_mode_settings_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _thinkingModeKey = GlobalKey();
  SettingsSpotlightController? _spotlightController;
  int _lastHandledSpotlightId = 0;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (!mounted) {
        return;
      }
      setState(() {
        _appVersion = info.version;
      });
    } catch (_) {
      // Leave version empty; About card will hide it.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final SettingsSpotlightController controller =
        context.read<SettingsSpotlightController>();
    if (_spotlightController == controller) {
      return;
    }
    _spotlightController?.removeListener(_handleSpotlight);
    _spotlightController = controller;
    _spotlightController!.addListener(_handleSpotlight);
  }

  void _handleSpotlight() {
    final SettingsSpotlightController? controller = _spotlightController;
    if (!mounted || controller == null) {
      return;
    }
    if (controller.requestId == _lastHandledSpotlightId ||
        controller.target != SettingsSpotlightTarget.thinkingMode) {
      return;
    }
    _lastHandledSpotlightId = controller.requestId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? targetContext = _thinkingModeKey.currentContext;
      if (!mounted || targetContext == null) {
        return;
      }
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: 0.2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (BuildContext context, SettingsController controller, _) {
        return SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SettingsTitleBlock(),
                const SizedBox(height: 16),
                TravelModeSettingsCard(
                  onStartTrip: () => TravelModeActionUtils.startTrip(context),
                  onEndTrip: () => TravelModeActionUtils.endTrip(context),
                  onOpenReceipts: () => TravelModeActionUtils.showTripReceipts(context),
                ),
                const SizedBox(height: 14),
                SettingsThemeCard(
                  selectedMode: controller.themeMode,
                  onChanged: (ThemeMode mode) => SettingsActionUtils.onThemeModeChanged(context, mode),
                ),
                const SizedBox(height: 14),
                SettingsLanguageCard(
                  languageCode: controller.locale.languageCode,
                  onChanged: (String code) => SettingsActionUtils.onLanguageChanged(context, Locale(code)),
                ),
                const SizedBox(height: 14),
                SettingsCurrencyCard(currencyCode: controller.currencyCode),
                const SizedBox(height: 14),
                SettingsAiConfigCard(thinkingModeKey: _thinkingModeKey),
                const SizedBox(height: 14),
                SettingsExportCard(
                  exporting: controller.exporting,
                  receiptExporting: controller.receiptExporting,
                  importing: controller.importing,
                  clearing: controller.clearing,
                  onExportCsvPressed: () => SettingsActionUtils.exportReceipts(
                    context,
                    ReceiptExportFormat.csv,
                  ),
                  onExportPdfPressed: () => SettingsActionUtils.exportReceipts(
                    context,
                    ReceiptExportFormat.pdf,
                  ),
                  onEmailReceiptsPressed: () =>
                      SettingsActionUtils.emailReceipts(context),
                  onExportBackupPressed: () =>
                      SettingsActionUtils.exportBackup(context),
                  onImportBackupPressed: () =>
                      SettingsActionUtils.importBackup(context),
                  onClearDataPressed: () =>
                      SettingsActionUtils.clearAllLocalData(context),
                ),
                const SizedBox(height: 14),
                SettingsLegalCard(
                  onPrivacyPolicyTap: () =>
                      SettingsActionUtils.showPrivacyPolicy(context),
                ),
                const SizedBox(height: 14),
                SettingsAboutCard(appVersion: _appVersion),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _spotlightController?.removeListener(_handleSpotlight);
    _scrollController.dispose();
    super.dispose();
  }
}
