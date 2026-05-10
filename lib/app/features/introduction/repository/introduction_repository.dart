import 'package:flutter/material.dart';
import 'package:refyn/l10n/app_localizations.dart';

import '../../../../database/app_database.dart';
import '../models/introduction_step.dart';

class IntroductionRepository {
  const IntroductionRepository({required AppSettingsDao settingsDao})
    : _settingsDao = settingsDao;

  final AppSettingsDao _settingsDao;

  static const String _hasSeenIntroductionKey = 'has_seen_introduction';
  static const String _homeCurrencyKey = 'currency_code';

  Future<bool> hasHomeCurrency() async {
    final String? value = await _settingsDao.getSetting(_homeCurrencyKey);
    return value != null && value.trim().isNotEmpty;
  }

  Future<void> setHomeCurrency(String code) {
    return _settingsDao.upsertSetting(
      key: _homeCurrencyKey,
      value: code.trim().toUpperCase(),
    );
  }

  List<IntroductionStep> loadSteps() {
    final AppLocalizations l10n = AppLocalizations.current;
    String tr({required String en, required String bs, required String da}) {
      switch (l10n.locale.languageCode) {
        case 'bs':
          return bs;
        case 'da':
          return da;
        default:
          return en;
      }
    }

    return [
      IntroductionStep(
        badge: 'Snap',
        title: tr(
          en: 'Point. Snap. Done.',
          bs: 'Usmjeri. Slikaj. Gotovo.',
          da: 'Peg. Scan. Fardig.',
        ),
        description: tr(
          en: 'Capture any receipt in seconds — camera or gallery. Refyn handles the rest.',
          bs: 'Uslikaj bilo koji račun za par sekundi — kamerom ili iz galerije. Refyn rješava ostalo.',
          da: 'Indfang enhver kvittering pa sekunder — kamera eller galleri. Refyn klarer resten.',
        ),
        accentLabel: tr(
          en: 'Fast capture',
          bs: 'Brzo hvatanje',
          da: 'Hurtig scanning',
        ),
        points: [
          tr(
            en: 'Camera or gallery',
            bs: 'Kamera ili galerija',
            da: 'Kamera eller galleri',
          ),
          tr(
            en: 'One-handed use',
            bs: 'Korištenje jednom rukom',
            da: 'Brug med en hand',
          ),
          tr(
            en: 'Instant feedback',
            bs: 'Trenutna povratna informacija',
            da: 'Direkte feedback',
          ),
        ],
        icon: Icons.document_scanner_rounded,
        visualKind: IntroductionVisualKind.scan,
      ),
      IntroductionStep(
        badge: 'Decode',
        title: tr(
          en: 'AI reads what you bought.',
          bs: 'AI čita šta si kupio.',
          da: 'AI laeser, hvad du kobte.',
        ),
        description: tr(
          en: 'Merchant, items, totals, and categories surface automatically — no typing required.',
          bs: 'Prodavač, stavke, ukupni iznosi i kategorije pojavljuju se automatski — bez ručnog unosa.',
          da: 'Butik, varer, totaler og kategorier udfyldes automatisk — ingen tastning nodig.',
        ),
        accentLabel: tr(
          en: 'Smart extraction',
          bs: 'Pametna ekstrakcija',
          da: 'Smart udtraek',
        ),
        points: [
          tr(
            en: 'Single image scan',
            bs: 'Sken jedne slike',
            da: 'Scan af et enkelt billede',
          ),
          tr(
            en: 'Auto-categorization',
            bs: 'Automatska kategorizacija',
            da: 'Automatisk kategorisering',
          ),
          tr(
            en: 'Less manual work',
            bs: 'Manje ručnog rada',
            da: 'Mindre manuelt arbejde',
          ),
        ],
        icon: Icons.auto_awesome_rounded,
        visualKind: IntroductionVisualKind.ai,
      ),
      IntroductionStep(
        badge: 'Track',
        title: tr(
          en: 'Every receipt, organized.',
          bs: 'Svaki račun, organizovan.',
          da: 'Hver kvittering, organiseret.',
        ),
        description: tr(
          en: 'Browse your full history with filters, search, and sorting. No more lost paper.',
          bs: 'Pregledaj cijelu historiju uz filtere, pretragu i sortiranje. Nema više izgubljenih papira.',
          da: 'Gennemse hele din historik med filtre, sogning og sortering. Ingen flere mistede papirbonner.',
        ),
        accentLabel: tr(
          en: 'Clean history',
          bs: 'Čista historija',
          da: 'Ren historik',
        ),
        points: [
          tr(
            en: 'Search & filter',
            bs: 'Pretraga i filteri',
            da: 'Sogning og filtre',
          ),
          tr(
            en: 'Sort by date or amount',
            bs: 'Sortiraj po datumu ili iznosu',
            da: 'Sorter efter dato eller belob',
          ),
          tr(
            en: 'Category breakdown',
            bs: 'Pregled po kategorijama',
            da: 'Kategorioversigt',
          ),
        ],
        icon: Icons.layers_rounded,
        visualKind: IntroductionVisualKind.organize,
      ),
      IntroductionStep(
        badge: 'Budget',
        title: tr(
          en: 'Set limits, stay on track.',
          bs: 'Postavi limite, ostani na planu.',
          da: 'Saet graenser, hold kursen.',
        ),
        description: tr(
          en: 'Create monthly budgets per category and watch your spending in real time.',
          bs: 'Napravi mjesečne budžete po kategoriji i prati potrošnju u stvarnom vremenu.',
          da: 'Lav manedlige budgetter pr. kategori og folg dit forbrug i realtid.',
        ),
        accentLabel: tr(
          en: 'Spending control',
          bs: 'Kontrola potrošnje',
          da: 'Forbrugskontrol',
        ),
        points: [
          tr(
            en: 'Category budgets',
            bs: 'Budžeti po kategoriji',
            da: 'Kategoribudgetter',
          ),
          tr(
            en: 'Live progress tracking',
            bs: 'Praćenje napretka uživo',
            da: 'Live fremskridt',
          ),
          tr(
            en: 'Over-budget alerts',
            bs: 'Upozorenja za prekoračenje',
            da: 'Advarsler ved overskridelse',
          ),
        ],
        icon: Icons.account_balance_wallet_rounded,
        visualKind: IntroductionVisualKind.budgets,
      ),
      IntroductionStep(
        badge: 'Export',
        title: tr(
          en: 'Share when you need to.',
          bs: 'Podijeli kad ti zatreba.',
          da: 'Del, nar du har brug for det.',
        ),
        description: tr(
          en: 'Export receipts as CSV, PDF, or email draft. Your data, ready to move.',
          bs: 'Izvezi račune kao CSV, PDF ili nacrt e-maila. Tvoji podaci, spremni za dijeljenje.',
          da: 'Eksporter kvitteringer som CSV, PDF eller e-mailkladde. Dine data, klar til brug.',
        ),
        accentLabel: tr(
          en: 'Portable data',
          bs: 'Prenosivi podaci',
          da: 'Flytbare data',
        ),
        points: [
          tr(en: 'CSV spreadsheets', bs: 'CSV tabele', da: 'CSV-regneark'),
          tr(en: 'PDF reports', bs: 'PDF izvještaji', da: 'PDF-rapporter'),
          tr(
            en: 'Email-ready drafts',
            bs: 'Spremni nacrti e-maila',
            da: 'E-mailkladder klar til brug',
          ),
        ],
        icon: Icons.ios_share_rounded,
        visualKind: IntroductionVisualKind.export,
      ),
      IntroductionStep(
        badge: 'Private',
        title: tr(
          en: 'Your data stays yours.',
          bs: 'Tvoji podaci ostaju tvoji.',
          da: 'Dine data forbliver dine.',
        ),
        description: tr(
          en: 'Receipt images go to AI for extraction only. Everything is stored locally on your device — never on our servers.',
          bs: 'Slike računa idu AI-u samo radi ekstrakcije. Sve ostaje sačuvano lokalno na tvom uređaju — nikad na našim serverima.',
          da: 'Kvitteringsbilleder sendes kun til AI for udtraek. Alt lagres lokalt pa din enhed — aldrig pa vores servere.',
        ),
        accentLabel: tr(
          en: 'Your privacy',
          bs: 'Tvoja privatnost',
          da: 'Dit privatliv',
        ),
        points: [
          tr(
            en: 'Scan only, never stored remotely',
            bs: 'Samo skeniranje, bez udaljene pohrane',
            da: 'Kun scanning, aldrig fjernlagret',
          ),
          tr(
            en: 'Local-first storage',
            bs: 'Lokalna pohrana na prvom mjestu',
            da: 'Lokal lagring forst',
          ),
          tr(
            en: 'No accounts needed',
            bs: 'Bez naloga',
            da: 'Ingen konto nodig',
          ),
        ],
        icon: Icons.shield_rounded,
        visualKind: IntroductionVisualKind.privacy,
      ),
    ];
  }

  Future<bool> hasSeenIntroduction() async {
    final value = await _settingsDao.getSetting(_hasSeenIntroductionKey);
    return value == 'true';
  }

  Future<void> markIntroductionSeen() {
    return _settingsDao.upsertSetting(
      key: _hasSeenIntroductionKey,
      value: 'true',
    );
  }
}
