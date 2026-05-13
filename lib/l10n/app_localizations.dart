import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('bs'),
    Locale('da'),
  ];

  static final AppLocalizations fallback = AppLocalizations(const Locale('en'));

  static AppLocalizations get current {
    final String localeName = Intl.getCurrentLocale();
    final String languageCode = localeName
        .split(RegExp('[-_]'))
        .first
        .trim()
        .toLowerCase();
    return AppLocalizations(Locale(languageCode.isEmpty ? 'en' : languageCode));
  }

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? result = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return result ?? fallback;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Refyn',
      'home': 'Home',
      'scan': 'Scan',
      'history': 'History',
      'settings': 'Settings',
      'language': 'Language',
      'languageEnglish': 'English',
      'languageBosnian': 'Bosnian',
      'languageDanish': 'Danish',
      'homePlaceholder': 'Home screen (Phase 1)',
      'scanPlaceholder': 'Scan screen (Phase 1)',
      'historyPlaceholder': 'History screen (Phase 1)',
      'settingsPlaceholder': 'App settings',
      'themeMode': 'Theme Mode',
      'lightTheme': 'Light',
      'darkTheme': 'Dark',
      'systemTheme': 'System',
      'saveDemoReceipt': 'Save Demo Receipt',
      'demoReceiptSaved': 'Demo receipt saved to history',
      'refreshHistory': 'Refresh History',
      'noReceiptsYet': 'No receipts yet. Save one from Scan tab.',
      'scanReceiptTitle': 'Scan Receipt',
      'scanReceiptSubtitle': 'Upload or capture a receipt image',
      'scanUpload': 'Upload',
      'scanCamera': 'Camera',
      'scanUploadTitle': 'Upload Receipt',
      'scanUploadSubtitle': 'Tap to select from gallery',
      'scanCameraTitle': 'Take Photo',
      'scanCameraSubtitle': 'Use camera to capture',
      'scanSupportFormats': 'Supports JPG, PNG • Max 10MB',
      'scanLongReceiptHint':
          'Long bill? Add up to 3 images — top, middle, bottom — and we will scan them as one receipt.',
      'scanAddPage': 'Add page',
      'scanAddPageHint': 'Add another section',
      'scanPageBadge': 'Page {index} / {total}',
      'scanRemoveImage': 'Remove image',
      'scanImageLimitReached': 'Up to 3 images per receipt.',
      'scanFromGallery': 'From gallery',
      'scanFromCamera': 'From camera',
      'scanAddSourceTitle': 'Add another section',
      'scanReceiptButton': 'Scan Receipt',
      'scanReset': 'Reset',
      'scanAnother': 'Scan Another',
      'scanRecentTitle': 'Recent Scans',
      'scanSuccessTitle': 'Receipt Scanned Successfully!',
      'scanErrorTitle': 'Scan Failed',
      'scanErrorFallback': 'Could not process receipt image.',
      'scanStepUploading': 'Uploading image',
      'scanStepReading': 'Reading text',
      'scanStepDetecting': 'Detecting items',
      'scanStepCategorizing': 'Categorizing receipt',
      'scanStepFinalizing': 'Finalizing data',
      'scanInProgress': 'Scanning…',
      'scanMerchant': 'Merchant',
      'scanTotal': 'Total',
      'scanDate': 'Date',
      'scanCategory': 'Category',
      'scanItems': 'Items',
      'scanConfidence': 'Confidence',
      'scanRetry': 'Retry Scan',
      'scanPickAnotherImage': 'Pick Image',
      'scanSaveReceipt': 'Save Receipt',
      'scanEditBeforeSave': 'Edit Before Save',
      'scanSaving': 'Saving...',
      'scanLowConfidenceWarning': 'Low confidence parse. Review before save.',
      'scanReceiptSaved': 'Receipt saved.',
      'scanDraftUpdated': 'Draft updated.',
      'scanTotalValidationError': 'Total must be valid number > 0.',
      'scanMerchantValidationError': 'Merchant name cannot be empty.',
      'scanPaymentValidationError': 'Payment method cannot be empty.',
      'scanEditParsedReceipt': 'Edit parsed receipt',
      'scanEditMerchant': 'Merchant',
      'scanEditCategory': 'Category',
      'scanEditPaymentMethod': 'Payment method',
      'scanEditTotal': 'Total',
      'scanDialogCancel': 'Cancel',
      'scanDialogApply': 'Apply',
      'scanErrorDismiss': 'Dismiss',
      'scanErrorRetry': 'Retry',
      'scanRecentEmptyHint': 'Scan first receipt to build history cards here.',
      'next': 'Next',
      'skip': 'Skip',
      'preparingRefyn': 'Preparing Refyn',
      'onboardingReadyToScan': 'Ready to scan with Refyn',
      'onboardingOpenRefyn': 'Open Refyn',
      'introRefynFlow': 'Refyn flow',
      'introLive': 'Live',
      'receiptPaperStore': 'Store',
      'receiptPaperItems': 'Items',
      'receiptPaperSubtotal': 'Subtotal',
      'receiptPaperTax': 'Tax',
      'receiptPaperTotal': 'Total',
      'receiptPaperShowMore': 'Show more',
      'receiptPaperShowLess': 'Show less',
      'receiptPaperTripReceipt': 'Trip receipt',
      'receiptPaperReceiptId': 'Receipt ID',
      'receiptPaperThankYou': 'Thank you!',
      'receiptPaperScanConfidence': 'Scan confidence',
      'receiptPaperScannedOnTrip': 'Scanned on trip',
      'receiptNotLoaded': 'Receipt not loaded',
      'introMayReport': 'May Report',
      'introReceiptCount': 'receipts',
      'introFreshMarket': 'Fresh Market',
      'introShellStation': 'Shell Station',
      'introAiParse': 'AI Parse',
      'introReceiptLabel': 'Receipt',
      'introDetectedItems': 'detected',
      'introOneTap': 'One tap',
      'introMayBudget': 'May Budget',
      'introOnTrack': 'On track',
      'introReady': 'Ready',
      'introLocalStorage': 'Local storage',
      'introAiScanning': 'AI scanning',
      'introNoAccounts': 'No accounts',
      'introAutoCategorized': 'Auto-categorized',
      'noSpending': 'No spending',
      'exportReportTitle': 'Receipt Export Report',
      'exportReceiptOverview': 'Receipt Overview',
      'exportFullDetails': 'Full Details',
      'generatedOn': 'Generated on',
      'created': 'Created',
      'payment': 'Payment',
      'notAvailable': 'Not available',
      'receipts': 'Receipts',
      'savedReceipts': 'saved receipts',
    },
    'bs': {
      'appTitle': 'Refyn',
      'home': 'Početna',
      'scan': 'Skeniraj',
      'history': 'Historija',
      'settings': 'Postavke',
      'language': 'Jezik',
      'languageEnglish': 'Engleski',
      'languageBosnian': 'Bosanski',
      'languageDanish': 'Danski',
      'settingsPlaceholder': 'Upravljanje postavkama aplikacije',
      'themeMode': 'Tema',
      'lightTheme': 'Svijetla',
      'darkTheme': 'Tamna',
      'systemTheme': 'Sistemska',
      'noReceiptsYet': 'Još nema računa. Sačuvaj jedan iz kartice Skeniraj.',
      'scanReceiptTitle': 'Skeniraj račun',
      'scanReceiptSubtitle': 'Učitaj ili uslikaj račun',
      'scanUpload': 'Učitaj',
      'scanCamera': 'Kamera',
      'scanUploadTitle': 'Učitaj račun',
      'scanUploadSubtitle': 'Dodirni za odabir iz galerije',
      'scanCameraTitle': 'Fotografiši',
      'scanCameraSubtitle': 'Koristi kameru za snimanje',
      'scanSupportFormats': 'Podržano JPG, PNG • Maks 10MB',
      'scanLongReceiptHint':
          'Dugačak račun? Dodaj do 3 slike — vrh, sredinu, dno — i skeniraćemo ih kao jedan račun.',
      'scanAddPage': 'Dodaj dio',
      'scanAddPageHint': 'Dodaj još jedan dio',
      'scanPageBadge': 'Dio {index} / {total}',
      'scanRemoveImage': 'Ukloni sliku',
      'scanImageLimitReached': 'Maksimalno 3 slike po računu.',
      'scanFromGallery': 'Iz galerije',
      'scanFromCamera': 'Iz kamere',
      'scanAddSourceTitle': 'Dodaj još jedan dio',
      'scanReceiptButton': 'Skeniraj račun',
      'scanReset': 'Poništi',
      'scanAnother': 'Skeniraj novi',
      'scanRecentTitle': 'Skorija skeniranja',
      'scanSuccessTitle': 'Račun uspješno skeniran!',
      'scanErrorTitle': 'Skeniranje nije uspjelo',
      'scanErrorFallback': 'Nije moguće obraditi sliku računa.',
      'scanStepUploading': 'Otpremanje slike',
      'scanStepReading': 'Čitanje teksta',
      'scanStepDetecting': 'Prepoznavanje stavki',
      'scanStepCategorizing': 'Kategorizacija računa',
      'scanStepFinalizing': 'Završna obrada',
      'scanInProgress': 'Skeniranje…',
      'scanMerchant': 'Prodavač',
      'scanTotal': 'Ukupno',
      'scanDate': 'Datum',
      'scanCategory': 'Kategorija',
      'scanItems': 'Stavke',
      'scanConfidence': 'Pouzdanost',
      'scanRetry': 'Pokušaj ponovo',
      'scanPickAnotherImage': 'Odaberi drugu sliku',
      'scanSaveReceipt': 'Sačuvaj račun',
      'scanEditBeforeSave': 'Uredi prije čuvanja',
      'scanSaving': 'Čuvanje...',
      'scanLowConfidenceWarning':
          'Niska pouzdanost parsiranja. Pregledaj prije čuvanja.',
      'scanReceiptSaved': 'Račun sačuvan.',
      'scanDraftUpdated': 'Nacrt ažuriran.',
      'scanTotalValidationError': 'Ukupno mora biti broj > 0.',
      'scanMerchantValidationError': 'Naziv prodavača ne može biti prazan.',
      'scanPaymentValidationError': 'Način plaćanja ne može biti prazan.',
      'scanEditParsedReceipt': 'Uredi parsirani račun',
      'scanEditMerchant': 'Prodavač',
      'scanEditCategory': 'Kategorija',
      'scanEditPaymentMethod': 'Način plaćanja',
      'scanEditTotal': 'Ukupno',
      'scanDialogCancel': 'Odustani',
      'scanDialogApply': 'Primijeni',
      'scanErrorDismiss': 'Zatvori',
      'scanErrorRetry': 'Ponovo',
      'scanRecentEmptyHint':
          'Skeniraj prvi račun da ovdje prikažemo historiju.',
      'next': 'Dalje',
      'skip': 'Preskoči',
      'preparingRefyn': 'Pripremam Refyn',
      'onboardingReadyToScan': 'Spremno za skeniranje uz Refyn',
      'onboardingOpenRefyn': 'Otvori Refyn',
      'introRefynFlow': 'Refyn tok',
      'introLive': 'Uživo',
      'receiptPaperStore': 'Prodavnica',
      'receiptPaperItems': 'Stavke',
      'receiptPaperSubtotal': 'Međuzbir',
      'receiptPaperTax': 'Porez',
      'receiptPaperTotal': 'Ukupno',
      'receiptPaperShowMore': 'Prikaži više',
      'receiptPaperShowLess': 'Prikaži manje',
      'receiptPaperTripReceipt': 'Putni račun',
      'receiptPaperReceiptId': 'ID računa',
      'receiptPaperThankYou': 'Hvala!',
      'receiptPaperScanConfidence': 'Pouzdanost skena',
      'receiptPaperScannedOnTrip': 'Skenirano na putovanju',
      'receiptNotLoaded': 'Račun nije učitan',
      'introMayReport': 'Majski izvještaj',
      'introReceiptCount': 'računa',
      'introFreshMarket': 'Svježa pijaca',
      'introShellStation': 'Shell stanica',
      'introAiParse': 'AI obrada',
      'introReceiptLabel': 'Račun',
      'introDetectedItems': 'otkriveno',
      'introOneTap': 'Jedan dodir',
      'introMayBudget': 'Majski budžet',
      'introOnTrack': 'Po planu',
      'introReady': 'Spremno',
      'introLocalStorage': 'Lokalna pohrana',
      'introAiScanning': 'AI skeniranje',
      'introNoAccounts': 'Bez naloga',
      'introAutoCategorized': 'Automatski kategorizirano',
      'noSpending': 'Nema potrošnje',
      'exportReportTitle': 'Izvještaj izvoza računa',
      'exportReceiptOverview': 'Pregled računa',
      'exportFullDetails': 'Puni detalji',
      'generatedOn': 'Generisano',
      'created': 'Kreirano',
      'payment': 'Plaćanje',
      'notAvailable': 'Nije dostupno',
      'receipts': 'Računi',
      'savedReceipts': 'sačuvanih računa',
    },
    'da': {
      'appTitle': 'Refyn',
      'home': 'Hjem',
      'scan': 'Scan',
      'history': 'Historik',
      'settings': 'Indstillinger',
      'language': 'Sprog',
      'languageEnglish': 'Engelsk',
      'languageBosnian': 'Bosnisk',
      'languageDanish': 'Dansk',
      'homePlaceholder': 'Startskarm (Fase 1)',
      'scanPlaceholder': 'Scanskarm (Fase 1)',
      'historyPlaceholder': 'Historikskarm (Fase 1)',
      'settingsPlaceholder': 'Appindstillinger',
      'themeMode': 'Tema',
      'lightTheme': 'Lys',
      'darkTheme': 'Mork',
      'systemTheme': 'System',
      'saveDemoReceipt': 'Gem demokvittering',
      'demoReceiptSaved': 'Demokvittering gemt i historik',
      'refreshHistory': 'Opdater historik',
      'noReceiptsYet': 'Ingen kvitteringer endnu. Gem en fra fanen Scan.',
      'scanReceiptTitle': 'Scan kvittering',
      'scanReceiptSubtitle': 'Upload eller tag billede af en kvittering',
      'scanUpload': 'Upload',
      'scanCamera': 'Kamera',
      'scanUploadTitle': 'Upload kvittering',
      'scanUploadSubtitle': 'Tryk for at valge fra galleri',
      'scanCameraTitle': 'Tag foto',
      'scanCameraSubtitle': 'Brug kamera til optagelse',
      'scanSupportFormats': 'Understotter JPG, PNG • Maks 10 MB',
      'scanLongReceiptHint':
          'Lang kvittering? Tilfoj op til 3 billeder — top, midt, bund — og vi scanner dem som en kvittering.',
      'scanAddPage': 'Tilfoj side',
      'scanAddPageHint': 'Tilfoj endnu en del',
      'scanPageBadge': 'Side {index} / {total}',
      'scanRemoveImage': 'Fjern billede',
      'scanImageLimitReached': 'Maks. 3 billeder pr. kvittering.',
      'scanFromGallery': 'Fra galleri',
      'scanFromCamera': 'Fra kamera',
      'scanAddSourceTitle': 'Tilfoj endnu en del',
      'scanReceiptButton': 'Scan kvittering',
      'scanReset': 'Nulstil',
      'scanAnother': 'Scan en til',
      'scanRecentTitle': 'Seneste scanninger',
      'scanSuccessTitle': 'Kvittering scannet!',
      'scanErrorTitle': 'Scanning mislykkedes',
      'scanErrorFallback': 'Kunne ikke behandle kvitteringsbilledet.',
      'scanStepUploading': 'Uploader billede',
      'scanStepReading': 'Laser tekst',
      'scanStepDetecting': 'Finder varer',
      'scanStepCategorizing': 'Kategoriserer kvittering',
      'scanStepFinalizing': 'Faerdiggor data',
      'scanInProgress': 'Scanner…',
      'scanMerchant': 'Butik',
      'scanTotal': 'I alt',
      'scanDate': 'Dato',
      'scanCategory': 'Kategori',
      'scanItems': 'Varer',
      'scanConfidence': 'Sikkerhed',
      'scanRetry': 'Prov igen',
      'scanPickAnotherImage': 'Vaelg billede',
      'scanSaveReceipt': 'Gem kvittering',
      'scanEditBeforeSave': 'Rediger for gem',
      'scanSaving': 'Gemmer...',
      'scanLowConfidenceWarning':
          'Lav parse-sikkerhed. Gennemga før du gemmer.',
      'scanReceiptSaved': 'Kvittering gemt.',
      'scanDraftUpdated': 'Kladde opdateret.',
      'scanTotalValidationError': 'Belob skal vaere et gyldigt tal > 0.',
      'scanMerchantValidationError': 'Butiksnavn ma ikke vaere tomt.',
      'scanPaymentValidationError': 'Betalingsmetode ma ikke vaere tom.',
      'scanEditParsedReceipt': 'Rediger fortolket kvittering',
      'scanEditMerchant': 'Butik',
      'scanEditCategory': 'Kategori',
      'scanEditPaymentMethod': 'Betalingsmetode',
      'scanEditTotal': 'I alt',
      'scanDialogCancel': 'Annuller',
      'scanDialogApply': 'Anvend',
      'scanErrorDismiss': 'Luk',
      'scanErrorRetry': 'Prov igen',
      'scanRecentEmptyHint':
          'Scan din forste kvittering for at vise historik her.',
      'next': 'Naeste',
      'skip': 'Spring over',
      'preparingRefyn': 'Forbereder Refyn',
      'onboardingReadyToScan': 'Klar til at scanne med Refyn',
      'onboardingOpenRefyn': 'Abn Refyn',
      'introRefynFlow': 'Refyn-flow',
      'introLive': 'Live',
      'receiptPaperStore': 'Butik',
      'receiptPaperItems': 'Varer',
      'receiptPaperSubtotal': 'Subtotal',
      'receiptPaperTax': 'Moms',
      'receiptPaperTotal': 'I alt',
      'receiptPaperShowMore': 'Vis mere',
      'receiptPaperShowLess': 'Vis mindre',
      'receiptPaperTripReceipt': 'Rejsekvittering',
      'receiptPaperReceiptId': 'Kvitterings-id',
      'receiptPaperThankYou': 'Tak!',
      'receiptPaperScanConfidence': 'Scan-sikkerhed',
      'receiptPaperScannedOnTrip': 'Scannet pa tur',
      'receiptNotLoaded': 'Kvittering er ikke indlaest',
      'introMayReport': 'Majrapport',
      'introReceiptCount': 'kvitteringer',
      'introFreshMarket': 'Frisk marked',
      'introShellStation': 'Shell station',
      'introAiParse': 'AI-fortolkning',
      'introReceiptLabel': 'Kvittering',
      'introDetectedItems': 'fundet',
      'introOneTap': 'Et tryk',
      'introMayBudget': 'Majbudget',
      'introOnTrack': 'Pa sporet',
      'introReady': 'Klar',
      'introLocalStorage': 'Lokal lagring',
      'introAiScanning': 'AI-scanning',
      'introNoAccounts': 'Ingen konti',
      'introAutoCategorized': 'Automatisk kategoriseret',
      'noSpending': 'Intet forbrug',
      'exportReportTitle': 'Kvitteringseksport-rapport',
      'exportReceiptOverview': 'Kvitteringsoversigt',
      'exportFullDetails': 'Alle detaljer',
      'generatedOn': 'Genereret',
      'created': 'Oprettet',
      'payment': 'Betaling',
      'notAvailable': 'Ikke tilgaengelig',
      'receipts': 'Kvitteringer',
      'savedReceipts': 'gemte kvitteringer',
    },
  };

  String get appTitle => _text('appTitle');
  String get home => _text('home');
  String get scan => _text('scan');
  String get history => _text('history');
  String get settings => _text('settings');
  String get language => _text('language');
  String get languageEnglish => _text('languageEnglish');
  String get languageBosnian => _text('languageBosnian');
  String get languageDanish => _text('languageDanish');
  String get homePlaceholder => _text('homePlaceholder');
  String get scanPlaceholder => _text('scanPlaceholder');
  String get historyPlaceholder => _text('historyPlaceholder');
  String get settingsPlaceholder => _text('settingsPlaceholder');
  String get themeMode => _text('themeMode');
  String get lightTheme => _text('lightTheme');
  String get darkTheme => _text('darkTheme');
  String get systemTheme => _text('systemTheme');
  String get saveDemoReceipt => _text('saveDemoReceipt');
  String get demoReceiptSaved => _text('demoReceiptSaved');
  String get refreshHistory => _text('refreshHistory');
  String get noReceiptsYet => _text('noReceiptsYet');
  String get scanReceiptTitle => _text('scanReceiptTitle');
  String get scanReceiptSubtitle => _text('scanReceiptSubtitle');
  String get scanUpload => _text('scanUpload');
  String get scanCamera => _text('scanCamera');
  String get scanUploadTitle => _text('scanUploadTitle');
  String get scanUploadSubtitle => _text('scanUploadSubtitle');
  String get scanCameraTitle => _text('scanCameraTitle');
  String get scanCameraSubtitle => _text('scanCameraSubtitle');
  String get scanSupportFormats => _text('scanSupportFormats');
  String get scanLongReceiptHint => _text('scanLongReceiptHint');
  String get scanAddPage => _text('scanAddPage');
  String get scanAddPageHint => _text('scanAddPageHint');
  String get scanRemoveImage => _text('scanRemoveImage');
  String get scanImageLimitReached => _text('scanImageLimitReached');
  String get scanFromGallery => _text('scanFromGallery');
  String get scanFromCamera => _text('scanFromCamera');
  String get scanAddSourceTitle => _text('scanAddSourceTitle');
  String scanPageBadge(int index, int total) => _text('scanPageBadge')
      .replaceAll('{index}', index.toString())
      .replaceAll('{total}', total.toString());
  String get scanReceiptButton => _text('scanReceiptButton');
  String get scanReset => _text('scanReset');
  String get scanAnother => _text('scanAnother');
  String get scanRecentTitle => _text('scanRecentTitle');
  String get scanSuccessTitle => _text('scanSuccessTitle');
  String get scanErrorTitle => _text('scanErrorTitle');
  String get scanErrorFallback => _text('scanErrorFallback');
  String get scanStepUploading => _text('scanStepUploading');
  String get scanStepReading => _text('scanStepReading');
  String get scanStepDetecting => _text('scanStepDetecting');
  String get scanStepCategorizing => _text('scanStepCategorizing');
  String get scanStepFinalizing => _text('scanStepFinalizing');
  String get scanInProgress => _text('scanInProgress');
  String get scanMerchant => _text('scanMerchant');
  String get scanTotal => _text('scanTotal');
  String get scanDate => _text('scanDate');
  String get scanCategory => _text('scanCategory');
  String get scanItems => _text('scanItems');
  String get scanConfidence => _text('scanConfidence');
  String get scanRetry => _text('scanRetry');
  String get scanPickAnotherImage => _text('scanPickAnotherImage');
  String get scanSaveReceipt => _text('scanSaveReceipt');
  String get scanEditBeforeSave => _text('scanEditBeforeSave');
  String get scanSaving => _text('scanSaving');
  String get scanLowConfidenceWarning => _text('scanLowConfidenceWarning');
  String get scanReceiptSaved => _text('scanReceiptSaved');
  String get scanDraftUpdated => _text('scanDraftUpdated');
  String get scanTotalValidationError => _text('scanTotalValidationError');
  String get scanMerchantValidationError =>
      _text('scanMerchantValidationError');
  String get scanPaymentValidationError => _text('scanPaymentValidationError');
  String get scanEditParsedReceipt => _text('scanEditParsedReceipt');
  String get scanEditMerchant => _text('scanEditMerchant');
  String get scanEditCategory => _text('scanEditCategory');
  String get scanEditPaymentMethod => _text('scanEditPaymentMethod');
  String get scanEditTotal => _text('scanEditTotal');
  String get scanDialogCancel => _text('scanDialogCancel');
  String get scanDialogApply => _text('scanDialogApply');
  String get scanErrorDismiss => _text('scanErrorDismiss');
  String get scanErrorRetry => _text('scanErrorRetry');
  String get scanRecentEmptyHint => _text('scanRecentEmptyHint');
  String get next => _text('next');
  String get skip => _text('skip');
  String get preparingRefyn => _text('preparingRefyn');
  String get onboardingReadyToScan => _text('onboardingReadyToScan');
  String get onboardingOpenRefyn => _text('onboardingOpenRefyn');
  String get introRefynFlow => _text('introRefynFlow');
  String get introLive => _text('introLive');
  String get receiptPaperStore => _text('receiptPaperStore');
  String get receiptPaperItems => _text('receiptPaperItems');
  String get receiptPaperSubtotal => _text('receiptPaperSubtotal');
  String get receiptPaperTax => _text('receiptPaperTax');
  String get receiptPaperTotal => _text('receiptPaperTotal');
  String get receiptPaperShowMore => _text('receiptPaperShowMore');
  String get receiptPaperShowLess => _text('receiptPaperShowLess');
  String get receiptPaperTripReceipt => _text('receiptPaperTripReceipt');
  String get receiptPaperReceiptId => _text('receiptPaperReceiptId');
  String get receiptPaperThankYou => _text('receiptPaperThankYou');
  String get receiptPaperScanConfidence => _text('receiptPaperScanConfidence');
  String get receiptPaperScannedOnTrip => _text('receiptPaperScannedOnTrip');
  String get receiptNotLoaded => _text('receiptNotLoaded');
  String get introMayReport => _text('introMayReport');
  String get introReceiptCount => _text('introReceiptCount');
  String get introFreshMarket => _text('introFreshMarket');
  String get introShellStation => _text('introShellStation');
  String get introAiParse => _text('introAiParse');
  String get introReceiptLabel => _text('introReceiptLabel');
  String get introDetectedItems => _text('introDetectedItems');
  String get introOneTap => _text('introOneTap');
  String get introMayBudget => _text('introMayBudget');
  String get introOnTrack => _text('introOnTrack');
  String get introReady => _text('introReady');
  String get introLocalStorage => _text('introLocalStorage');
  String get introAiScanning => _text('introAiScanning');
  String get introNoAccounts => _text('introNoAccounts');
  String get introAutoCategorized => _text('introAutoCategorized');
  String get noSpending => _text('noSpending');
  String get exportReportTitle => _text('exportReportTitle');
  String get exportReceiptOverview => _text('exportReceiptOverview');
  String get exportFullDetails => _text('exportFullDetails');
  String get generatedOn => _text('generatedOn');
  String get created => _text('created');
  String get payment => _text('payment');
  String get notAvailable => _text('notAvailable');
  String get receipts => _text('receipts');
  String get savedReceipts => _text('savedReceipts');

  String get close => _byLanguage(en: 'Close', bs: 'Zatvori', da: 'Luk');
  String get cancel =>
      _byLanguage(en: 'Cancel', bs: 'Odustani', da: 'Annuller');
  String get save => _byLanguage(en: 'Save', bs: 'Sačuvaj', da: 'Gem');
  String get clear => _byLanguage(en: 'Clear', bs: 'Očisti', da: 'Ryd');
  String get delete => _byLanguage(en: 'Delete', bs: 'Obriši', da: 'Slet');
  String get edit => _byLanguage(en: 'Edit', bs: 'Uredi', da: 'Rediger');
  String get retry =>
      _byLanguage(en: 'Retry', bs: 'Pokušaj ponovo', da: 'Prov igen');
  String get confirm =>
      _byLanguage(en: 'Confirm', bs: 'Potvrdi', da: 'Bekraeft');
  String get reset => _byLanguage(en: 'Reset', bs: 'Resetuj', da: 'Nulstil');
  String get about => _byLanguage(en: 'About', bs: 'O aplikaciji', da: 'Om');
  String get appVersion => _byLanguage(
    en: 'App Version',
    bs: 'Verzija aplikacije',
    da: 'App-version',
  );
  String get export => _byLanguage(en: 'Export', bs: 'Izvoz', da: 'Eksport');
  String get privacyPolicy => _byLanguage(
    en: 'Privacy Policy',
    bs: 'Pravila privatnosti',
    da: 'Privatlivspolitik',
  );
  String get termsOfService => _byLanguage(
    en: 'Terms of Service',
    bs: 'Uvjeti korištenja',
    da: 'Servicevilkar',
  );
  String get receiptDetails => _byLanguage(
    en: 'Receipt Details',
    bs: 'Detalji računa',
    da: 'Kvitteringsdetaljer',
  );
  String get receiptNumber => _byLanguage(
    en: 'Receipt Number',
    bs: 'Broj računa',
    da: 'Kvitteringsnummer',
  );
  String get paymentSummary => _byLanguage(
    en: 'Payment Summary',
    bs: 'Sažetak plaćanja',
    da: 'Betalingsoversigt',
  );
  String get date => _byLanguage(en: 'Date', bs: 'Datum', da: 'Dato');
  String get merchant =>
      _byLanguage(en: 'Merchant', bs: 'Prodavač', da: 'Butik');
  String get paymentMethod => _byLanguage(
    en: 'Payment Method',
    bs: 'Način plaćanja',
    da: 'Betalingsmetode',
  );
  String get subtotal =>
      _byLanguage(en: 'Subtotal', bs: 'Međuzbir', da: 'Subtotal');
  String get tax => _byLanguage(en: 'Tax', bs: 'Porez', da: 'Moms');
  String get total => _byLanguage(en: 'Total', bs: 'Ukupno', da: 'I alt');
  String get unknownMerchant => _byLanguage(
    en: 'Unknown merchant',
    bs: 'Nepoznat prodavač',
    da: 'Ukendt butik',
  );
  String get unknown =>
      _byLanguage(en: 'Unknown', bs: 'Nepoznato', da: 'Ukendt');
  String get unnamedItem => _byLanguage(
    en: 'Unnamed item',
    bs: 'Neimenovana stavka',
    da: 'Unavngivet vare',
  );
  String get shareUnavailable => _byLanguage(
    en: 'Share is not available yet.',
    bs: 'Dijeljenje još nije dostupno.',
    da: 'Deling er ikke tilgaengelig endnu.',
  );
  String get keepReceiptForRecords => _byLanguage(
    en: 'Keep this receipt for your records',
    bs: 'Sačuvaj ovaj račun za svoju evidenciju',
    da: 'Gem denne kvittering til dine poster',
  );
  String get searchHistoryHint => _byLanguage(
    en: 'Search by merchant, item, or category...',
    bs: 'Pretraži po prodavaču, stavci ili kategoriji...',
    da: 'Sog efter butik, vare eller kategori...',
  );
  String get noItemsFound => _byLanguage(
    en: 'No items found',
    bs: 'Nema pronađenih stavki',
    da: 'Ingen varer fundet',
  );
  String get noItemsFoundAll => _byLanguage(
    en: 'Try a different merchant, item, category, or date range. Saved receipt items will appear here.',
    bs: 'Pokušaj drugog prodavača, stavku, kategoriju ili datum. Sačuvane stavke računa će se prikazati ovdje.',
    da: 'Prov en anden butik, vare, kategori eller datoperiode. Gemte kvitteringsvarer vises her.',
  );
  String noItemsFoundCategory(String categoryLabel) => _byLanguage(
    en: 'No ${categoryLabel.toLowerCase()} items match the current search or date range.',
    bs: 'Nijedna stavka kategorije ${categoryLabel.toLowerCase()} ne odgovara trenutnoj pretrazi ili datumu.',
    da: 'Ingen ${categoryLabel.toLowerCase()}-varer matcher den aktuelle sogning eller datoperiode.',
  );
  String qtyLabel(String quantity) => _byLanguage(
    en: 'Qty: $quantity',
    bs: 'Kol: $quantity',
    da: 'Antal: $quantity',
  );
  String get recentReceipts => _byLanguage(
    en: 'Recent Receipts',
    bs: 'Skoriji računi',
    da: 'Seneste kvitteringer',
  );
  String get viewAll =>
      _byLanguage(en: 'View All', bs: 'Vidi sve', da: 'Se alle');
  String get all => _byLanguage(en: 'All', bs: 'Sve', da: 'Alle');
  String get oldestFirst => _byLanguage(
    en: 'Oldest First',
    bs: 'Najstarije prvo',
    da: 'Aeldste forst',
  );
  String get highestAmount => _byLanguage(
    en: 'Highest Amount',
    bs: 'Najveći iznos',
    da: 'Hojeste belob',
  );
  String get lowestAmount => _byLanguage(
    en: 'Lowest Amount',
    bs: 'Najmanji iznos',
    da: 'Laveste belob',
  );
  String historyTotalsLabel(int itemCount, int receiptCount) => _byLanguage(
    en: '$itemCount total items from $receiptCount receipts',
    bs: '$itemCount ukupno stavki iz $receiptCount računa',
    da: '$itemCount varer fra $receiptCount kvitteringer',
  );
  String get noBudgetsYet => _byLanguage(
    en: 'No budgets yet',
    bs: 'Još nema budžeta',
    da: 'Ingen budgetter endnu',
  );
  String get noBudgetsYetMessage => _byLanguage(
    en: 'Create monthly category budgets from Manage and track each spend bucket here.',
    bs: 'Kreiraj mjesečne budžete po kategoriji iz Upravljaj i prati potrošnju ovdje.',
    da: 'Opret manedlige kategoribudgetter fra Administrer og spor hvert forbrugsomrade her.',
  );
  String get show => _byLanguage(en: 'Show', bs: 'Prikaži', da: 'Vis');
  String get hide => _byLanguage(en: 'Hide', bs: 'Sakrij', da: 'Skjul');
  String get manage =>
      _byLanguage(en: 'Manage', bs: 'Upravljaj', da: 'Administrer');
  String get categoryBudgets => _byLanguage(
    en: 'Category Budgets',
    bs: 'Budžeti po kategoriji',
    da: 'Kategoribudgetter',
  );
  String get localDeviceData => _byLanguage(
    en: 'Local device data',
    bs: 'Lokalni podaci uređaja',
    da: 'Lokale enhedsdata',
  );
  String get theme => _byLanguage(en: 'Theme', bs: 'Tema', da: 'Tema');
  String get aiConfiguration => _byLanguage(
    en: 'AI configuration',
    bs: 'AI konfiguracija',
    da: 'AI-konfiguration',
  );
  String get homeSpendingOverview => _byLanguage(
    en: "Here's your spending overview",
    bs: 'Ovo je pregled tvoje potrošnje',
    da: 'Her er dit forbrugsoverblik',
  );
  String get thisMonth =>
      _byLanguage(en: 'This Month', bs: 'Ovaj mjesec', da: 'Denne maned');
  String get budget => _byLanguage(en: 'Budget', bs: 'Budžet', da: 'Budget');
  String spentAmountLabel(String amount, [String currency = '']) => _byLanguage(
    en: '$amount${currency.isNotEmpty ? ' $currency' : ''} spent',
    bs: 'Potrošeno $amount${currency.isNotEmpty ? ' $currency' : ''}',
    da: '$amount${currency.isNotEmpty ? ' $currency' : ''} brugt',
  );
  String remainingAmountLabel(String amount, [String currency = '']) =>
      _byLanguage(
        en: '$amount${currency.isNotEmpty ? ' $currency' : ''} left',
        bs: 'Preostalo $amount${currency.isNotEmpty ? ' $currency' : ''}',
        da: '$amount${currency.isNotEmpty ? ' $currency' : ''} tilbage',
      );
  String overBudgetLabel(String amount, [String currency = '']) => _byLanguage(
    en: '$amount${currency.isNotEmpty ? ' $currency' : ''} over',
    bs: '$amount${currency.isNotEmpty ? ' $currency' : ''} preko',
    da: '$amount${currency.isNotEmpty ? ' $currency' : ''} over',
  );
  String get itemsInThisCategory => _byLanguage(
    en: 'Items in this category',
    bs: 'Stavke u ovoj kategoriji',
    da: 'Varer i denne kategori',
  );
  String itemsInCategoryThisMonthLabel(String categoryLabel) => _byLanguage(
    en: 'Current month purchases matched to ${categoryLabel.toLowerCase()}.',
    bs: 'Kupovine iz tekućeg mjeseca povezane sa kategorijom ${categoryLabel.toLowerCase()}.',
    da: 'Denne maneds kob matcher kategorien ${categoryLabel.toLowerCase()}.',
  );
  String noTrackedItemsInCategoryLabel(String categoryLabel) => _byLanguage(
    en: 'No tracked items yet for $categoryLabel in current month.',
    bs: 'Još nema praćenih stavki za kategoriju $categoryLabel u tekućem mjesecu.',
    da: 'Ingen sporede varer endnu for $categoryLabel i denne maned.',
  );
  String get item => _byLanguage(en: 'Item', bs: 'Stavka', da: 'Vare');
  String get receiptNotFound => _byLanguage(
    en: 'Receipt not found',
    bs: 'Račun nije pronađen',
    da: 'Kvittering ikke fundet',
  );
  String usedPercentLabel(int percent) => _byLanguage(
    en: '$percent% used',
    bs: '$percent% potrošeno',
    da: '$percent% brugt',
  );
  String remainingBudgetLabel(String amount, [String currency = '']) =>
      _byLanguage(
        en: '$amount${currency.isNotEmpty ? ' $currency' : ''} left',
        bs: 'Preostalo $amount${currency.isNotEmpty ? ' $currency' : ''}',
        da: '$amount${currency.isNotEmpty ? ' $currency' : ''} tilbage',
      );
  String get retryHome =>
      _byLanguage(en: 'Retry', bs: 'Pokušaj ponovo', da: 'Prov igen');
  String activeBudgetsLabel(int count) => _byLanguage(
    en: '$count active budgets',
    bs: '$count aktivnih budžeta',
    da: '$count aktive budgetter',
  );
  String budgetCategoriesHiddenLabel(int count) => _byLanguage(
    en: '$count budget categories hidden',
    bs: '$count kategorija budžeta skriveno',
    da: '$count budgetkategorier skjult',
  );
  String get budgetSheetDescription => _byLanguage(
    en: 'Set monthly limits by category. Save each card when ready.',
    bs: 'Postavi mjesečne limite po kategoriji. Sačuvaj svaku karticu kada završiš.',
    da: 'Saet manedlige graenser pr. kategori. Gem hvert kort, nar du er klar.',
  );
  String get noBudgetSet => _byLanguage(
    en: 'No budget set',
    bs: 'Budžet nije postavljen',
    da: 'Intet budget sat',
  );
  String activeBudgetAmountLabel(String amount, [String currency = '']) =>
      _byLanguage(
        en: '$amount${currency.isNotEmpty ? ' $currency' : ''} active',
        bs: '$amount${currency.isNotEmpty ? ' $currency' : ''} aktivno',
        da: '$amount${currency.isNotEmpty ? ' $currency' : ''} aktivt',
      );
  String get enterMonthlyBudget => _byLanguage(
    en: 'Enter monthly budget',
    bs: 'Unesi mjesečni budžet',
    da: 'Indtast manedligt budget',
  );
  String get enterValidBudgetAmount => _byLanguage(
    en: 'Enter a valid budget amount.',
    bs: 'Unesi ispravan iznos budžeta.',
    da: 'Indtast et gyldigt budgetbelob.',
  );
  String budgetDeletedLabel(String category) => _byLanguage(
    en: '$category budget deleted.',
    bs: 'Budžet za $category je obrisan.',
    da: '$category-budget slettet.',
  );
  String budgetSavedLabel(String category) => _byLanguage(
    en: '$category budget saved.',
    bs: 'Budžet za $category je sačuvan.',
    da: '$category-budget gemt.',
  );
  String get settingsExportDescription => _byLanguage(
    en: 'Share all saved receipts as CSV, PDF, or a prefilled email draft.',
    bs: 'Podijeli sve sačuvane račune kao CSV, PDF ili unaprijed popunjen e-mail.',
    da: 'Del alle gemte kvitteringer som CSV, PDF eller et forudfyldt e-mailudkast.',
  );
  String get localDeviceDataDescription => _byLanguage(
    en: 'Manage on-device data with backup export, restore, and full reset.',
    bs: 'Upravljaj lokalnim podacima kroz izvoz sigurnosne kopije, vraćanje i potpuno brisanje.',
    da: 'Administrer lokale data med backup-eksport, gendannelse og fuld nulstilling.',
  );
  String get preparingBackup => _byLanguage(
    en: 'Preparing backup...',
    bs: 'Priprema sigurnosne kopije...',
    da: 'Forbereder backup...',
  );
  String get exportBackup => _byLanguage(
    en: 'Export backup',
    bs: 'Izvezi sigurnosnu kopiju',
    da: 'Eksporter backup',
  );
  String get importingBackup => _byLanguage(
    en: 'Importing backup...',
    bs: 'Uvoz sigurnosne kopije...',
    da: 'Importerer backup...',
  );
  String get importBackup => _byLanguage(
    en: 'Import backup',
    bs: 'Uvezi sigurnosnu kopiju',
    da: 'Importer backup',
  );
  String get clearingData => _byLanguage(
    en: 'Clearing data...',
    bs: 'Brisanje podataka...',
    da: 'Rydder data...',
  );
  String get clearLocalData => _byLanguage(
    en: 'Clear local data',
    bs: 'Obriši lokalne podatke',
    da: 'Ryd lokale data',
  );
  String get csvExportTitle =>
      _byLanguage(en: 'CSV export', bs: 'CSV izvoz', da: 'CSV-eksport');
  String get csvExportSubtitle => _byLanguage(
    en: 'Spreadsheet-friendly export for all saved receipts.',
    bs: 'Izvoz prilagođen tabelama za sve sačuvane račune.',
    da: 'Regnearksvenlig eksport for alle gemte kvitteringer.',
  );
  String get exportCsv =>
      _byLanguage(en: 'Export CSV', bs: 'Izvezi CSV', da: 'Eksporter CSV');
  String get preparingCsv => _byLanguage(
    en: 'Preparing CSV...',
    bs: 'Priprema CSV-a...',
    da: 'Forbereder CSV...',
  );
  String get pdfReportTitle =>
      _byLanguage(en: 'PDF report', bs: 'PDF izvještaj', da: 'PDF-rapport');
  String get pdfReportSubtitle => _byLanguage(
    en: 'Readable summary report with receipt totals and items.',
    bs: 'Čitljiv sažetak sa ukupnim iznosima i stavkama računa.',
    da: 'Laesbar oversigtsrapport med kvitteringstotaler og varer.',
  );
  String get exportPdf =>
      _byLanguage(en: 'Export PDF', bs: 'Izvezi PDF', da: 'Eksporter PDF');
  String get preparingPdf => _byLanguage(
    en: 'Preparing PDF...',
    bs: 'Priprema PDF-a...',
    da: 'Forbereder PDF...',
  );
  String get emailDraftTitle =>
      _byLanguage(en: 'Email draft', bs: 'Nacrt e-maila', da: 'E-mailudkast');
  String get emailDraftSubtitle => _byLanguage(
    en: 'Open mail app with a prefilled receipt report and attachments.',
    bs: 'Otvori aplikaciju za e-mail sa unaprijed popunjenim izvještajem i prilozima.',
    da: 'Abn mailappen med en forudfyldt kvitteringsrapport og vedhaeftninger.',
  );
  String get composeEmail =>
      _byLanguage(en: 'Compose email', bs: 'Napiši e-mail', da: 'Skriv e-mail');
  String get openingMail => _byLanguage(
    en: 'Opening mail...',
    bs: 'Otvaranje e-maila...',
    da: 'Abner mail...',
  );
  String get builtInKeyActive => _byLanguage(
    en: 'Built-in key active',
    bs: 'Ugrađeni ključ aktivan',
    da: 'Indbygget nogle aktiv',
  );
  String get pasteGoogleAiKey => _byLanguage(
    en: 'Paste your Google AI API key',
    bs: 'Zalijepi svoj Google AI API ključ',
    da: 'Indsaet din Google AI API-nogle',
  );
  String get defaultKeyHiddenHelper => _byLanguage(
    en: 'Default key is hidden. Enter a custom key to override.',
    bs: 'Zadani ključ je skriven. Unesi vlastiti ključ za zamjenu.',
    da: 'Standardnoglen er skjult. Indtast en brugerdefineret nogel for at tilsidesaette den.',
  );
  String get apiKey =>
      _byLanguage(en: 'API key', bs: 'API ključ', da: 'API-nogle');
  String get model => _byLanguage(en: 'Model', bs: 'Model', da: 'Model');
  String get modelSelectionDescription => _byLanguage(
    en: 'Pick which Gemma model handles receipt extraction.',
    bs: 'Odaberi koji Gemma model obrađuje ekstrakciju računa.',
    da: 'Vaelg hvilken Gemma-model der handterer kvitteringsudtraek.',
  );
  String get deeperThinking => _byLanguage(
    en: 'Deeper thinking',
    bs: 'Dublje razmišljanje',
    da: 'Dybere taenkning',
  );
  String get deeperThinkingOn => _byLanguage(
    en: 'Slower scans, more accurate parsing for tricky receipts.',
    bs: 'Sporije skeniranje, preciznije parsiranje za zahtjevne račune.',
    da: 'Langsommere scanninger, mere praecis parsing for svaere kvitteringer.',
  );
  String get deeperThinkingOff => _byLanguage(
    en: 'Fast scans with minimal reasoning. Best default for clear receipts.',
    bs: 'Brzo skeniranje sa minimalnim razmišljanjem. Najbolji izbor za jasne račune.',
    da: 'Hurtige scanninger med minimal taenkning. Bedste standardvalg for tydelige kvitteringer.',
  );
  String aiModelsAvailableLabel(int count) => _byLanguage(
    en: 'Key confirmed. $count Gemma models available.',
    bs: 'Ključ potvrđen. Dostupno $count Gemma modela.',
    da: 'Nogle bekraeftet. $count Gemma-modeller tilgaengelige.',
  );
  String get builtInKeyInUse => _byLanguage(
    en: 'Built-in key in use. Override by entering your own key.',
    bs: 'Ugrađeni ključ je u upotrebi. Zamijeni ga unosom vlastitog ključa.',
    da: 'Indbygget nogel er i brug. Tilsidesaet den ved at indtaste din egen nogel.',
  );
  String get savedKeyInvalid => _byLanguage(
    en: 'Saved key is invalid. Re-enter and confirm again.',
    bs: 'Sačuvani ključ nije ispravan. Unesi ga ponovo i potvrdi.',
    da: 'Den gemte nogel er ugyldig. Indtast og bekraeft igen.',
  );
  String get noKeySet => _byLanguage(
    en: 'No key set. Add one to enable scanning.',
    bs: 'Ključ nije postavljen. Dodaj ga da omogućiš skeniranje.',
    da: 'Ingen nogel sat. Tilfoj en for at aktivere scanning.',
  );
  String get loadingSavedAiConfiguration => _byLanguage(
    en: 'Loading saved AI configuration...',
    bs: 'Učitavam sačuvanu AI konfiguraciju...',
    da: 'Indlaeser gemt AI-konfiguration...',
  );
  String get confirmingKeyWithGoogleAi => _byLanguage(
    en: 'Confirming key with Google AI...',
    bs: 'Potvrda ključa sa Google AI...',
    da: 'Bekraefter nogle med Google AI...',
  );
  String get aiConfigurationDescription => _byLanguage(
    en: 'Connect a Google AI key to scan receipts. Pick a Gemma model and toggle deeper thinking when needed.',
    bs: 'Poveži Google AI ključ za skeniranje računa. Odaberi Gemma model i uključi dublje razmišljanje po potrebi.',
    da: 'Forbind en Google AI-nogle for at scanne kvitteringer. Vaelg en Gemma-model og sla dybere taenkning til ved behov.',
  );
  String get howAiConfigurationWorks => _byLanguage(
    en: 'How AI configuration works',
    bs: 'Kako radi AI konfiguracija',
    da: 'Sadan fungerer AI-konfiguration',
  );
  String get aiInfoSubtitle => _byLanguage(
    en: 'How your key, model, and thinking level affect scans.',
    bs: 'Kako ključ, model i nivo razmišljanja utječu na skeniranje.',
    da: 'Hvordan din nogel, model og taenkeniveau paavirker scanninger.',
  );
  String get bringYourOwnKey => _byLanguage(
    en: 'Bring your own key',
    bs: 'Koristi vlastiti ključ',
    da: 'Brug din egen nogel',
  );
  String get bringYourOwnKeyBody => _byLanguage(
    en: 'Receipt sends image data directly to Google AI using your API key. No middleman.',
    bs: 'Aplikacija šalje podatke slike direktno Google AI koristeći tvoj API ključ. Bez posrednika.',
    da: 'Appen sender billeddata direkte til Google AI med din API-nogle. Ingen mellemmand.',
  );
  String get staysOnDevice => _byLanguage(
    en: 'Stays on device',
    bs: 'Ostaje na uređaju',
    da: 'Bliver pa enheden',
  );
  String get staysOnDeviceBody => _byLanguage(
    en: 'Your key is stored locally only. It never leaves the app except in requests to Google AI.',
    bs: 'Tvoj ključ se čuva samo lokalno. Ne napušta aplikaciju osim u zahtjevima prema Google AI.',
    da: 'Din nogel gemmes kun lokalt. Den forlader kun appen i anmodninger til Google AI.',
  );
  String get quotaIsYours => _byLanguage(
    en: '15,000 free requests per day',
    bs: '15.000 besplatnih zahtjeva dnevno',
    da: 'Kvoten er din',
  );
  String get quotaIsYoursBody => _byLanguage(
    en: 'Receipt scan calls count against your own Google AI quota and billing.',
    bs: 'Pozivi za skeniranje računa troše tvoju Google AI kvotu i naplatu.',
    da: 'Kvitteringsscanninger taeller mod din egen Google AI-kvote og fakturering.',
  );
  String get pickGemmaModel => _byLanguage(
    en: 'Pick a Gemma model',
    bs: 'Odaberi Gemma model',
    da: 'Vaelg en Gemma-model',
  );
  String get pickGemmaModelBody => _byLanguage(
    en: 'After confirming a key, Receipt loads compatible Gemma models you can pick from.',
    bs: 'Nakon potvrde ključa aplikacija učitava kompatibilne Gemma modele koje možeš odabrati.',
    da: 'Efter bekraeftelse af en nogel indlaeser appen kompatible Gemma-modeller, du kan vaelge imellem.',
  );
  String get quickSteps =>
      _byLanguage(en: 'Quick steps', bs: 'Brzi koraci', da: 'Hurtige trin');
  String get quickStep1 => _byLanguage(
    en: '1. Get a Google AI Studio API key.',
    bs: '1. Nabavi Google AI Studio API ključ.',
    da: '1. Hent en Google AI Studio API-nogle.',
  );
  String get quickStep2 => _byLanguage(
    en: '2. Paste it above and tap Confirm.',
    bs: '2. Zalijepi ga gore i dodirni Potvrdi.',
    da: '2. Indsaet den ovenfor og tryk Bekraeft.',
  );
  String get quickStep3 => _byLanguage(
    en: '3. Pick a Gemma model from the dropdown.',
    bs: '3. Odaberi Gemma model iz padajućeg izbornika.',
    da: '3. Vaelg en Gemma-model fra rullemenuen.',
  );
  String get quickStep4 => _byLanguage(
    en: '4. Optional: enable deeper thinking for tricky receipts.',
    bs: '4. Opcionalno: uključi dublje razmišljanje za zahtjevne račune.',
    da: '4. Valgfrit: aktiver dybere taenkning for svaere kvitteringer.',
  );
  String get gotIt =>
      _byLanguage(en: 'Got it', bs: 'Razumijem', da: 'Forstaet');
  String get aiConfigurationFailed => _byLanguage(
    en: 'AI configuration failed',
    bs: 'AI konfiguracija nije uspjela',
    da: 'AI-konfiguration mislykkedes',
  );
  String get addApiKeyBeforeConfirming => _byLanguage(
    en: 'Add an API key before confirming.',
    bs: 'Dodaj API ključ prije potvrde.',
    da: 'Tilfoj en API-nogle for bekraeftelse.',
  );
  String get aiConfigurationConfirmFailed => _byLanguage(
    en: 'Could not confirm AI configuration. Try again.',
    bs: 'Nije moguće potvrditi AI konfiguraciju. Pokušaj ponovo.',
    da: 'Kunne ikke bekraefte AI-konfiguration. Prov igen.',
  );
  String get backupFailed => _byLanguage(
    en: 'Backup failed',
    bs: 'Sigurnosna kopija nije uspjela',
    da: 'Backup mislykkedes',
  );
  String backupReadyLabel(int receiptCount, int attachmentCount) => _byLanguage(
    en: 'Backup ready. Receipts: $receiptCount, attachments: $attachmentCount.',
    bs: 'Sigurnosna kopija spremna. Računi: $receiptCount, prilozi: $attachmentCount.',
    da: 'Backup klar. Kvitteringer: $receiptCount, vedhaeftninger: $attachmentCount.',
  );
  String get exportFailed => _byLanguage(
    en: 'Export failed',
    bs: 'Izvoz nije uspio',
    da: 'Eksport mislykkedes',
  );
  String exportReadyLabel(String formatLabel) => _byLanguage(
    en: '$formatLabel export ready.',
    bs: '$formatLabel izvoz je spreman.',
    da: '$formatLabel-eksport klar.',
  );
  String get backupShareSubject => _byLanguage(
    en: 'Receipt backup',
    bs: 'Sigurnosna kopija računa',
    da: 'Kvitteringsbackup',
  );
  String backupShareBody(int receiptCount, int attachmentCount) => _byLanguage(
    en: 'Receipt local backup\nReceipts: $receiptCount\nAttachments: $attachmentCount',
    bs: 'Lokalna sigurnosna kopija računa\nRačuni: $receiptCount\nPrilozi: $attachmentCount',
    da: 'Lokal kvitteringsbackup\nKvitteringer: $receiptCount\nVedhaeftninger: $attachmentCount',
  );
  String exportShareSubject(String formatLabel) => _byLanguage(
    en: 'Receipt export $formatLabel',
    bs: 'Izvoz računa $formatLabel',
    da: 'Kvitteringseksport $formatLabel',
  );
  String exportShareBody(String formatLabel) => _byLanguage(
    en: 'Receipt export ready ($formatLabel).',
    bs: 'Izvoz računa je spreman ($formatLabel).',
    da: 'Kvitteringseksport er klar ($formatLabel).',
  );
  String get mailAppOpenedWithExport => _byLanguage(
    en: 'Mail app opened with receipt export.',
    bs: 'Aplikacija za e-mail otvorena sa izvozom računa.',
    da: 'Mailappen blev abnet med kvitteringseksport.',
  );
  String get mailAppOpenedManualAttachments => _byLanguage(
    en: 'Mail app opened. Attachments may need manual add.',
    bs: 'Aplikacija za e-mail otvorena. Prilozi će možda trebati ručno dodati.',
    da: 'Mailappen blev abnet. Vedhaeftninger skal muligvis tilfojes manuelt.',
  );
  String get emailUnavailable => _byLanguage(
    en: 'Email unavailable',
    bs: 'E-mail nije dostupan',
    da: 'E-mail ikke tilgaengelig',
  );
  String get noMailAppAvailable => _byLanguage(
    en: 'No mail app available on this device.',
    bs: 'Na ovom uređaju nema dostupne aplikacije za e-mail.',
    da: 'Ingen mailapp tilgaengelig pa denne enhed.',
  );
  String get emailExportFailed => _byLanguage(
    en: 'Email export failed',
    bs: 'Izvoz e-maila nije uspio',
    da: 'E-maileksport mislykkedes',
  );
  String get importBackupQuestion => _byLanguage(
    en: 'Import backup?',
    bs: 'Uvesti sigurnosnu kopiju?',
    da: 'Importer backup?',
  );
  String get importBackupWarning => _byLanguage(
    en: 'This replaces all current local receipts, budgets, and settings on this device.',
    bs: 'Ovo zamjenjuje sve trenutne lokalne račune, budžete i postavke na ovom uređaju.',
    da: 'Dette erstatter alle nuvaerende lokale kvitteringer, budgetter og indstillinger pa denne enhed.',
  );
  String get restoreFailed => _byLanguage(
    en: 'Restore failed',
    bs: 'Vraćanje nije uspjelo',
    da: 'Gendannelse mislykkedes',
  );
  String backupRestoredLabel(
    int receiptCount,
    int attachmentCount,
  ) => _byLanguage(
    en: 'Backup restored. Receipts: $receiptCount, attachments: $attachmentCount.',
    bs: 'Sigurnosna kopija vraćena. Računi: $receiptCount, prilozi: $attachmentCount.',
    da: 'Backup gendannet. Kvitteringer: $receiptCount, vedhaeftninger: $attachmentCount.',
  );
  String get clearLocalDataQuestion => _byLanguage(
    en: 'Clear local data?',
    bs: 'Obrisati lokalne podatke?',
    da: 'Ryd lokale data?',
  );
  String get clearLocalDataWarning => _byLanguage(
    en: 'This deletes receipts, budgets, and app settings from this device.',
    bs: 'Ovo briše račune, budžete i postavke aplikacije sa ovog uređaja.',
    da: 'Dette sletter kvitteringer, budgetter og appindstillinger fra denne enhed.',
  );
  String get localDataCleared => _byLanguage(
    en: 'Local data cleared.',
    bs: 'Lokalni podaci obrisani.',
    da: 'Lokale data ryddet.',
  );
  String get clearFailed => _byLanguage(
    en: 'Clear failed',
    bs: 'Brisanje nije uspjelo',
    da: 'Rydning mislykkedes',
  );
  String get privacyPolicyPlaceholder => _byLanguage(
    en: 'Privacy policy details will be added in a future phase.',
    bs: 'Detalji pravila privatnosti će biti dodani u narednoj fazi.',
    da: 'Detaljer om privatlivspolitik tilfojes i en fremtidig fase.',
  );
  String get termsOfServicePlaceholder => _byLanguage(
    en: 'Terms of service details will be added in a future phase.',
    bs: 'Detalji uvjeta korištenja će biti dodani u narednoj fazi.',
    da: 'Detaljer om servicevilkar tilfojes i en fremtidig fase.',
  );
  String get unknownError => _byLanguage(
    en: 'Unknown error.',
    bs: 'Nepoznata greška.',
    da: 'Ukendt fejl.',
  );
  String get deleteReceiptQuestion => _byLanguage(
    en: 'Delete Receipt?',
    bs: 'Obrisati račun?',
    da: 'Slet kvittering?',
  );
  String get deleteReceiptWarning => _byLanguage(
    en: 'This action cannot be undone. This will permanently delete this receipt from your history.',
    bs: 'Ovu radnju nije moguće poništiti. Račun će trajno biti obrisan iz historije.',
    da: 'Denne handling kan ikke fortrydes. Denne kvittering slettes permanent fra din historik.',
  );
  String fileSavedLabel(String formatLabel, String path) => _byLanguage(
    en: '$formatLabel saved: $path',
    bs: '$formatLabel sačuvan: $path',
    da: '$formatLabel gemt: $path',
  );
  String get editReceipt => _byLanguage(
    en: 'Edit Receipt',
    bs: 'Uredi račun',
    da: 'Rediger kvittering',
  );
  String get receiptUpdated => _byLanguage(
    en: 'Receipt updated.',
    bs: 'Račun ažuriran.',
    da: 'Kvittering opdateret.',
  );
  String get changeItemCategory => _byLanguage(
    en: 'Change item category',
    bs: 'Promijeni kategoriju stavke',
    da: 'Aendr varekategori',
  );
  String get itemName =>
      _byLanguage(en: 'Item name', bs: 'Naziv stavke', da: 'Varenavn');
  String get saveChanges => _byLanguage(
    en: 'Save changes',
    bs: 'Sačuvaj izmjene',
    da: 'Gem aendringer',
  );
  String itemUpdatedLabel(String itemName) => _byLanguage(
    en: '$itemName updated.',
    bs: '$itemName ažuriran.',
    da: '$itemName opdateret.',
  );
  String get noReceiptImageAvailable => _byLanguage(
    en: 'No receipt image available.',
    bs: 'Slika računa nije dostupna.',
    da: 'Intet kvitteringsbillede tilgaengeligt.',
  );
  String get unableToLoadImage => _byLanguage(
    en: 'Unable to load image.',
    bs: 'Nije moguće učitati sliku.',
    da: 'Kan ikke indlaese billede.',
  );
  String get scanImageUploadFailedTitle => _byLanguage(
    en: 'Image upload failed',
    bs: 'Otpremanje slike nije uspjelo',
    da: 'Billedupload mislykkedes',
  );
  String get scanImageUploadFailedMessage => _byLanguage(
    en: 'Could not read selected image. Please try another image.',
    bs: 'Nije moguće pročitati odabranu sliku. Pokušaj drugu sliku.',
    da: 'Kunne ikke laese det valgte billede. Prov et andet billede.',
  );
  String get scanNoImageSelectedTitle => _byLanguage(
    en: 'No image selected',
    bs: 'Nijedna slika nije odabrana',
    da: 'Intet billede valgt',
  );
  String get scanNoImageSelectedMessage => _byLanguage(
    en: 'Select image first, then tap scan.',
    bs: 'Prvo odaberi sliku, pa zatim dodirni skeniraj.',
    da: 'Vaelg forst et billede, og tryk derefter scan.',
  );
  String get scanFinishedNotice => _byLanguage(
    en: 'Receipt scan finished.',
    bs: 'Skeniranje računa završeno.',
    da: 'Kvitteringsscanning faerdig.',
  );
  String get scanUnexpectedFailureTitle => _byLanguage(
    en: 'Unexpected scan failure',
    bs: 'Neočekivana greška pri skeniranju',
    da: 'Uventet scanningsfejl',
  );
  String get scanUnexpectedFailureMessage => _byLanguage(
    en: 'Something went wrong during scan.',
    bs: 'Došlo je do greške tokom skeniranja.',
    da: 'Noget gik galt under scanning.',
  );
  String get scanFailedNotice => _byLanguage(
    en: 'Receipt scan failed.',
    bs: 'Skeniranje računa nije uspjelo.',
    da: 'Kvitteringsscanning mislykkedes.',
  );
  String get scanSaveFailedTitle => _byLanguage(
    en: 'Save failed',
    bs: 'Čuvanje nije uspjelo',
    da: 'Gemming mislykkedes',
  );
  String get scanSaveFailedMessage => _byLanguage(
    en: 'Could not save receipt. Try again.',
    bs: 'Nije moguće sačuvati račun. Pokušaj ponovo.',
    da: 'Kunne ikke gemme kvittering. Prov igen.',
  );
  String get scanLowConfidenceDialogTitle => _byLanguage(
    en: 'Check low-confidence scan',
    bs: 'Provjeri sken niske pouzdanosti',
    da: 'Tjek scanning med lav sikkerhed',
  );
  String get scanLowConfidenceDialogMessage => _byLanguage(
    en: 'Confidence is below 90%. Check the total, then confirm if everything looks right.',
    bs: 'Pouzdanost je ispod 90%. Provjeri ukupni iznos pa potvrdi ako sve izgleda ispravno.',
    da: 'Sikkerheden er under 90%. Tjek totalen, og bekraeft hvis alt ser rigtigt ud.',
  );
  String get scanLowConfidenceOpenThinkingMode => _byLanguage(
    en: 'Open Thinking AI',
    bs: 'Otvori Thinking AI',
    da: 'Abn Thinking AI',
  );
  String get scanLowConfidenceConfirmSave => _byLanguage(
    en: 'Confirm receipt',
    bs: 'Potvrdi račun',
    da: 'Bekraeft kvittering',
  );
  String get scanLowConfidenceThinkingModeHint => _byLanguage(
    en: 'Need more help on tricky bills? ',
    bs: 'Trebaš više pomoći za zahtjevne račune? ',
    da: 'Har du brug for mere hjaelp til svaere kvitteringer? ',
  );
  String get scanLowConfidenceThinkingModeNudge => _byLanguage(
    en: 'Low-confidence scans keep happening. Consider turning this on by default. ',
    bs: 'Skenovi niske pouzdanosti se ponavljaju. Razmisli da ovo uključiš kao zadano. ',
    da: 'Scanninger med lav sikkerhed sker igen. Overvej at sla dette til som standard. ',
  );
  String get scanLowConfidenceThinkingModeLink => _byLanguage(
    en: 'Open Thinking AI settings.',
    bs: 'Otvori Thinking AI postavke.',
    da: 'Abn Thinking AI-indstillinger.',
  );
  String get notReceiptTitle => _byLanguage(
    en: 'Not a receipt',
    bs: 'Nije račun',
    da: 'Ikke en kvittering',
  );
  String notReceiptMessage(String reason) => _byLanguage(
    en: reason.isEmpty
        ? 'Selected image is not a receipt. Try a clear receipt photo.'
        : 'Selected image is not a receipt. $reason',
    bs: reason.isEmpty
        ? 'Odabrana slika nije račun. Pokušaj jasnu fotografiju računa.'
        : 'Odabrana slika nije račun. $reason',
    da: reason.isEmpty
        ? 'Det valgte billede er ikke en kvittering. Prov et tydeligt kvitteringsfoto.'
        : 'Det valgte billede er ikke en kvittering. $reason',
  );
  String get imageQualityIssueTitle => _byLanguage(
    en: 'Image quality issue',
    bs: 'Problem s kvalitetom slike',
    da: 'Problem med billedkvalitet',
  );
  String imageQualityIssueMessage(String reason) => _byLanguage(
    en: reason.isEmpty
        ? 'Receipt image is not clear enough. Try a sharper photo.'
        : 'Receipt image is not clear enough. $reason',
    bs: reason.isEmpty
        ? 'Slika računa nije dovoljno jasna. Pokušaj oštriju fotografiju.'
        : 'Slika računa nije dovoljno jasna. $reason',
    da: reason.isEmpty
        ? 'Kvitteringsbilledet er ikke tydeligt nok. Prov et skarpere foto.'
        : 'Kvitteringsbilledet er ikke tydeligt nok. $reason',
  );
  String get scanFailedTitle => _byLanguage(
    en: 'Scan failed',
    bs: 'Skeniranje nije uspjelo',
    da: 'Scanning mislykkedes',
  );
  String get scanFailedMessage => _byLanguage(
    en: 'Could not parse receipt data.',
    bs: 'Nije moguće obraditi podatke računa.',
    da: 'Kunne ikke parse kvitteringsdata.',
  );
  String get cannotSaveReceiptTitle => _byLanguage(
    en: 'Cannot save receipt',
    bs: 'Nije moguće sačuvati račun',
    da: 'Kan ikke gemme kvittering',
  );
  String get cannotSaveReceiptMessage => _byLanguage(
    en: 'Receipt fields invalid. Fix values before saving.',
    bs: 'Polja računa nisu ispravna. Ispravi vrijednosti prije čuvanja.',
    da: 'Kvitteringsfelter er ugyldige. Ret vaerdierne for gemning.',
  );
  String get invalidJsonResponseTitle => _byLanguage(
    en: 'Invalid JSON response',
    bs: 'Neispravan JSON odgovor',
    da: 'Ugyldigt JSON-svar',
  );
  String get invalidJsonResponseMessage => _byLanguage(
    en: 'AI returned broken JSON. Please retry scan.',
    bs: 'AI je vratio neispravan JSON. Pokušaj ponovo skenirati.',
    da: 'AI returnerede ugyldig JSON. Prov at scanne igen.',
  );
  String get aiResponseFailedTitle => _byLanguage(
    en: 'AI response failed',
    bs: 'AI odgovor nije uspio',
    da: 'AI-svar mislykkedes',
  );
  String get aiResponseFailedMessage => _byLanguage(
    en: 'Could not get valid AI response for this image.',
    bs: 'Nije moguće dobiti ispravan AI odgovor za ovu sliku.',
    da: 'Kunne ikke hente et gyldigt AI-svar for dette billede.',
  );
  String get currencyConversionFailedTitle => _byLanguage(
    en: 'Currency conversion failed',
    bs: 'Konverzija valute nije uspjela',
    da: 'Valutaomregning mislykkedes',
  );
  String currencyConversionFailedMessage(String from, String to) => _byLanguage(
    en: 'Could not convert $from to $to. Check your internet connection and try again.',
    bs: 'Nije moguće konvertovati $from u $to. Provjeri internetsku vezu i pokušaj ponovo.',
    da: 'Kunne ikke omregne $from til $to. Tjek din internetforbindelse og prov igen.',
  );

  String get currency =>
      _byLanguage(en: 'Currency', bs: 'Valuta', da: 'Valuta');
  String get currencyDescription => _byLanguage(
    en: 'Set the default currency for budgets and spending summaries.',
    bs: 'Postavi zadanu valutu za budžete i preglede potrošnje.',
    da: 'Indstil standardvalutaen for budgetter og forbrugsoversigter.',
  );
  String get currencyCustomHint => _byLanguage(
    en: 'Or type a custom currency code',
    bs: 'Ili unesi prilagođeni kod valute',
    da: 'Eller skriv en brugerdefineret valutakode',
  );
  String currencySavedLabel(String code) => _byLanguage(
    en: 'Currency set to $code.',
    bs: 'Valuta postavljena na $code.',
    da: 'Valuta sat til $code.',
  );
  String get currencyLockedDescription => _byLanguage(
    en: 'Your home currency is locked to keep your spending history consistent. Changing it would invalidate past receipt amounts and budget totals.',
    bs: 'Tvoja osnovna valuta je zaključana radi konzistentnosti historije potrošnje. Promjena bi onemogućila usporedbu historijskih iznosa i budžeta.',
    da: 'Din hjemvaluta er laast for at holde din forbrugshistorik konsistent. En aendring ville ugyldiggore tidligere kviteringsbelob og budgettotaler.',
  );
  String get currencyLockedResetHint => _byLanguage(
    en: 'Need a different currency? Use "Clear all data" in the Data section below.',
    bs: 'Trebaš drugu valutu? Koristi "Obriši sve podatke" u odjeljku Podaci ispod.',
    da: 'Har du brug for en anden valuta? Brug "Slet alle data" i afsnittet Data nedenfor.',
  );

  // ── Home view switcher ─────────────────────────────────────────────────────
  String get homeViewSwitcherHome =>
      _byLanguage(en: 'Home', bs: 'Početna', da: 'Hjem');
  String get homeViewSwitcherTrip =>
      _byLanguage(en: 'Trip', bs: 'Putovanje', da: 'Tur');

  // ── Trip info card ─────────────────────────────────────────────────────────
  String get tripInfoCardTitle => _byLanguage(
    en: 'Trip in progress',
    bs: 'Putovanje u toku',
    da: 'Tur i gang',
  );
  String tripInfoCardSubtitle(String homeCode) => _byLanguage(
    en: 'End the trip to convert receipts back to $homeCode.',
    bs: 'Završi putovanje da pretvoriš račune u $homeCode.',
    da: 'Afslut turen for at omregne kvitteringer tilbage til $homeCode.',
  );

  // ── Trip summary hero ──────────────────────────────────────────────────────
  String tripHeroAvgPerDay(String amount, String code) => _byLanguage(
    en: '$amount $code / day',
    bs: '$amount $code / dan',
    da: '$amount $code / dag',
  );
  String tripHeroConvertsTo(String homeCode) => _byLanguage(
    en: 'Converts to $homeCode',
    bs: 'Pretvara se u $homeCode',
    da: 'Omregnes til $homeCode',
  );

  // ── Scan travel banner ─────────────────────────────────────────────────────
  String scanTravelBannerTitle(String code) => _byLanguage(
    en: 'Scanning in $code',
    bs: 'Skenirate u $code',
    da: 'Scanner i $code',
  );
  String scanTravelBannerSubtitle(String homeCode) => _byLanguage(
    en: 'Receipts save to this trip and convert to $homeCode when you end it.',
    bs: 'Računi se čuvaju u putovanju i pretvaraju u $homeCode kad završiš.',
    da: 'Kvitteringer gemmes pa turen og omregnes til $homeCode, nar du afslutter.',
  );

  // ── Travel mode ────────────────────────────────────────────────────────────
  String get travelModeIdleTitle =>
      _byLanguage(en: 'Travel mode', bs: 'Putni način', da: 'Rejsetilstand');
  String get travelModeIdleSubtitle => _byLanguage(
    en: "Scan in a different currency while you're away. We'll convert it back to your home currency when the trip ends.",
    bs: 'Skeniraj u drugoj valuti dok si na putu. Pretvorit ćemo u tvoju zadanu valutu kad putovanje završi.',
    da: 'Scan i en anden valuta, mens du er pa rejse. Vi omregner det tilbage til din hjemmevaluta, nar turen slutter.',
  );
  String get travelModeStartTrip =>
      _byLanguage(en: 'Start a trip', bs: 'Započni putovanje', da: 'Start tur');
  String get travelModeInfoButton =>
      _byLanguage(en: 'How it works', bs: 'Kako radi', da: 'Sadan virker det');
  String get travelModeActiveLabel =>
      _byLanguage(en: 'Travel mode', bs: 'Putni način', da: 'Rejsetilstand');
  String get travelModeScanningIn =>
      _byLanguage(en: 'scanning in', bs: 'skenirate u', da: 'scanner i');
  String get travelModeSpentSoFar =>
      _byLanguage(en: 'SPENT SO FAR', bs: 'POTROŠENO', da: 'BRUGT INDTIL NU');
  String travelModeReceiptCount(int count) => _byLanguage(
    en: '$count receipt${count == 1 ? '' : 's'}',
    bs: '$count račun${count == 1 ? '' : 'a'}',
    da: '$count kvittering${count == 1 ? '' : 'er'}',
  );
  String travelModeDayBadge(int day) =>
      _byLanguage(en: 'Day $day', bs: 'Dan $day', da: 'Dag $day');
  String get travelModeEndTrip =>
      _byLanguage(en: 'End trip', bs: 'Završi putovanje', da: 'Slut tur');
  String get travelModeViewReceipts => _byLanguage(
    en: 'View trip receipts',
    bs: 'Prikaži račune',
    da: 'Se turkvitteringer',
  );
  String get travelModeSheetTitle => _byLanguage(
    en: 'Trip receipts',
    bs: 'Računi s putovanja',
    da: 'Turkvitteringer',
  );
  String travelModeSheetSubtitle(String code) => _byLanguage(
    en: 'Everything scanned in $code during this trip.',
    bs: 'Sve skenirano u $code tokom ovog putovanja.',
    da: 'Alt scannet i $code under denne tur.',
  );
  String get travelModeSheetItems =>
      _byLanguage(en: 'RECEIPTS', bs: 'RAČUNI', da: 'KVITTERINGER');
  String get travelModeSheetHint => _byLanguage(
    en: 'Tap any receipt to open details.',
    bs: 'Dodirni račun za detalje.',
    da: 'Tryk pa en kvittering for detaljer.',
  );
  String get travelModeSheetEmptyTitle => _byLanguage(
    en: 'No trip receipts yet',
    bs: 'Još nema računa s putovanja',
    da: 'Ingen turkvitteringer endnu',
  );
  String travelModeSheetEmptySubtitle(String code) => _byLanguage(
    en: 'Start scanning in $code and they will land here.',
    bs: 'Počni skenirati u $code i pojavit će se ovdje.',
    da: 'Start scanning i $code, sa lander de her.',
  );

  String get travelStartSheetTitle => _byLanguage(
    en: 'Pick your trip currency',
    bs: 'Odaberi valutu putovanja',
    da: 'Vaelg din rejsevaluta',
  );
  String get travelStartSheetSubtitle => _byLanguage(
    en: 'All scans during the trip will be saved in this currency.',
    bs: 'Sva skeniranja tokom putovanja čuvat će se u ovoj valuti.',
    da: 'Alle scanninger under turen gemmes i denne valuta.',
  );
  String get travelStartSheetConfirm =>
      _byLanguage(en: 'Start trip', bs: 'Započni', da: 'Start');
  String get travelModeInfoTitle => _byLanguage(
    en: 'How travel mode works',
    bs: 'Kako radi putni način',
    da: 'Sadan fungerer rejsetilstand',
  );
  String get travelModeInfoSubtitle => _byLanguage(
    en: 'Use it when you want to scan receipts in a temporary trip currency.',
    bs: 'Koristi ovo kad želiš skenirati račune u privremenoj valuti putovanja.',
    da: 'Brug dette, nar du vil scanne kvitteringer i en midlertidig rejsevaluta.',
  );
  String get travelModeInfoStep1Title => _byLanguage(
    en: 'Choose the trip currency',
    bs: 'Odaberi valutu putovanja',
    da: 'Vaelg rejsevaluta',
  );
  String get travelModeInfoStep1Body => _byLanguage(
    en: 'Start travel mode and pick the currency you will spend in during the trip.',
    bs: 'Pokreni putni način i odaberi valutu u kojoj ćeš trošiti tokom putovanja.',
    da: 'Start rejsetilstand og vaelg den valuta, du bruger under turen.',
  );
  String get travelModeInfoStep2Title => _byLanguage(
    en: 'Scan receipts as usual',
    bs: 'Skeniraj račune kao i inače',
    da: 'Scan kvitteringer som normalt',
  );
  String get travelModeInfoStep2Body => _byLanguage(
    en: 'Each receipt is saved in that trip currency and grouped into the active trip.',
    bs: 'Svaki račun se čuva u toj valuti i povezuje s aktivnim putovanjem.',
    da: 'Hver kvittering gemmes i rejsevalutaen og knyttes til den aktive tur.',
  );
  String get travelModeInfoStep3Title => _byLanguage(
    en: 'End trip and convert',
    bs: 'Završi putovanje i pretvori',
    da: 'Afslut turen og omregn',
  );
  String get travelModeInfoStep3Body => _byLanguage(
    en: 'When the trip ends, convert all trip receipts back to your home currency in one step.',
    bs: 'Kad putovanje završi, pretvori sve račune s putovanja nazad u svoju domaću valutu u jednom koraku.',
    da: 'Nar turen slutter, omregner du alle turkvitteringer tilbage til din hjemmevaluta i et trin.',
  );
  String get travelModeInfoNote => _byLanguage(
    en: 'You can choose a quick today-rate conversion or a more accurate per-day conversion when ending the trip.',
    bs: 'Pri završetku putovanja možeš odabrati brzu konverziju po današnjem kursu ili precizniju po danima.',
    da: 'Nar du afslutter turen, kan du vaelge en hurtig omregning med dagens kurs eller en mere praecis daglig omregning.',
  );
  String get travelModeInfoConfirm =>
      _byLanguage(en: 'Got it', bs: 'Jasno', da: 'Forstaet');
  String travelModeStartedSnackbar(String code) => _byLanguage(
    en: 'Travel mode started — scanning in $code.',
    bs: 'Putni način aktivan — skenirate u $code.',
    da: 'Rejsetilstand startet — scanner i $code.',
  );
  String travelModeEndedSnackbar(String from, String to) => _byLanguage(
    en: 'Trip ended — converted $from to $to.',
    bs: 'Putovanje završeno — pretvoreno $from u $to.',
    da: 'Tur afsluttet — omregnet $from til $to.',
  );

  // End-trip confirm dialog
  String get tripEndDialogTitle => _byLanguage(
    en: 'End your trip?',
    bs: 'Završiti putovanje?',
    da: 'Afslutte turen?',
  );
  String tripEndDialogIntro(
    int receipts,
    String from,
    String to,
  ) => _byLanguage(
    en: '$receipts receipt${receipts == 1 ? '' : 's'} in $from will be converted to $to.',
    bs: '$receipts račun${receipts == 1 ? '' : 'a'} u $from bit će pretvoren u $to.',
    da: '$receipts kvittering${receipts == 1 ? '' : 'er'} i $from bliver omregnet til $to.',
  );
  String get tripEndDialogConfirm => _byLanguage(
    en: 'Convert and finish',
    bs: 'Pretvori i završi',
    da: 'Omregn og afslut',
  );
  String get tripEndStrategyPerDayTitle => _byLanguage(
    en: 'Per-day rates',
    bs: 'Kursevi po danu',
    da: 'Daglige kurser',
  );
  String get tripEndStrategyPerDaySubtitle => _byLanguage(
    en: "Most accurate. Uses each receipt's purchase date.",
    bs: 'Najtačnije. Koristi datum kupovine za svaki račun.',
    da: 'Mest praecist. Bruger koebsdato for hver kvittering.',
  );
  String get tripEndStrategyTodayTitle =>
      _byLanguage(en: "Today's rate", bs: 'Današnji kurs', da: 'Dagens kurs');
  String get tripEndStrategyTodaySubtitle => _byLanguage(
    en: 'Fast. Same rate applied to every receipt.',
    bs: 'Brzo. Isti kurs primijenjen na svaki račun.',
    da: 'Hurtig. Samme kurs anvendes for alle kvitteringer.',
  );

  // End-trip loading dialog
  String get tripEndLoadingFetchingRate => _byLanguage(
    en: 'Fetching exchange rate',
    bs: 'Dohvatanje kursa',
    da: 'Henter valutakurs',
  );
  String tripEndLoadingFetchingDate(String date) => _byLanguage(
    en: 'Fetching rate for $date',
    bs: 'Dohvatanje kursa za $date',
    da: 'Henter kurs for $date',
  );
  String get tripEndLoadingConverting => _byLanguage(
    en: 'Converting trip receipts',
    bs: 'Pretvaranje računa',
    da: 'Omregner kvitteringer',
  );
  String get tripEndLoadingFinishing =>
      _byLanguage(en: 'Finishing up', bs: 'Završavam', da: 'Afslutter');

  // Onboarding
  String get onboardingCurrencyTitle => _byLanguage(
    en: 'Pick your home currency',
    bs: 'Odaberi zadanu valutu',
    da: 'Vaelg din hjemmevaluta',
  );
  String get onboardingCurrencySubtitle => _byLanguage(
    en: 'All your spending and budgets will live in this currency. You can\'t change it later without wiping your data.',
    bs: 'Sva potrošnja i budžeti bit će u ovoj valuti. Kasnije se može promijeniti samo brisanjem svih podataka.',
    da: 'Alt forbrug og alle budgetter vil vaere i denne valuta. Den kan kun aendres ved at slette dine data.',
  );
  String get onboardingCurrencyContinue =>
      _byLanguage(en: 'Continue', bs: 'Nastavi', da: 'Fortsaet');
  String onboardingFeaturesPreviewed(int current, int total) => _byLanguage(
    en: '$current/$total features previewed',
    bs: '$current/$total funkcija pregledano',
    da: '$current/$total funktioner vist',
  );
  String receiptPaperItemsLabel(int count) => _byLanguage(
    en: 'Items ($count)',
    bs: 'Stavke ($count)',
    da: 'Varer ($count)',
  );
  String receiptPaperReceiptIdLabel(String id) => _byLanguage(
    en: 'Receipt ID: $id',
    bs: 'ID računa: $id',
    da: 'Kvitterings-id: $id',
  );
  String receiptPaperScanConfidenceLabel(int percent) => _byLanguage(
    en: '$percent% ${receiptPaperScanConfidence.toUpperCase()}',
    bs: '$percent% ${receiptPaperScanConfidence.toUpperCase()}',
    da: '$percent% ${receiptPaperScanConfidence.toUpperCase()}',
  );
  String introReceiptCountLabel(int count) => _byLanguage(
    en: '$count ${count == 1 ? 'receipt' : 'receipts'}',
    bs: '$count račun${count == 1 ? '' : 'a'}',
    da: '$count kvittering${count == 1 ? '' : 'er'}',
  );
  String introDetectedItemsLabel(int count) => _byLanguage(
    en: '$count detected',
    bs: '$count otkriveno',
    da: '$count fundet',
  );

  String categoryLabel(String category) {
    switch (category.trim().toLowerCase()) {
      case 'groceries':
        return _byLanguage(en: 'Groceries', bs: 'Namirnice', da: 'Dagligvarer');
      case 'fuel':
        return _byLanguage(en: 'Fuel', bs: 'Gorivo', da: 'Braendstof');
      case 'household':
        return _byLanguage(
          en: 'Household',
          bs: 'Domaćinstvo',
          da: 'Husholdning',
        );
      case 'pets':
        return _byLanguage(en: 'Pets', bs: 'Kućni ljubimci', da: 'Kaledyr');
      case 'clothing':
        return _byLanguage(en: 'Clothing', bs: 'Odjeća', da: 'Toj');
      case 'pharmacy':
        return _byLanguage(en: 'Pharmacy', bs: 'Apoteka', da: 'Apotek');
      case 'dental':
        return _byLanguage(en: 'Dental', bs: 'Stomatologija', da: 'Tandlaege');
      case 'night out':
        return _byLanguage(en: 'Night Out', bs: 'Izlazak', da: 'Bytur');
      case 'cigarettes':
        return _byLanguage(en: 'Cigarettes', bs: 'Cigarete', da: 'Cigaretter');
      default:
        return _byLanguage(en: 'Misc', bs: 'Ostalo', da: 'Diverse');
    }
  }

  String _byLanguage({
    required String en,
    required String bs,
    required String da,
  }) {
    switch (_languageCode) {
      case 'bs':
        return bs;
      case 'da':
        return da;
      default:
        return en;
    }
  }

  String get _languageCode => _localizedValues.containsKey(locale.languageCode)
      ? locale.languageCode
      : 'en';

  String _text(String key) {
    return _localizedValues[_languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((item) => item.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future<AppLocalizations>.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
