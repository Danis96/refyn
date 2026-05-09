class CurrencyPreset {
  const CurrencyPreset({
    required this.code,
    required this.label,
    required this.flag,
  });

  final String code;
  final String label;
  final String flag;
}

const List<CurrencyPreset> kCurrencyPresets = <CurrencyPreset>[
  CurrencyPreset(code: 'BAM', label: 'BAM', flag: '\u{1F1E7}\u{1F1E6}'),
  CurrencyPreset(code: 'EUR', label: 'EUR', flag: '\u{1F1EA}\u{1F1FA}'),
  CurrencyPreset(code: 'USD', label: 'USD', flag: '\u{1F1FA}\u{1F1F8}'),
  CurrencyPreset(code: 'GBP', label: 'GBP', flag: '\u{1F1EC}\u{1F1E7}'),
  CurrencyPreset(code: 'DKK', label: 'DKK', flag: '\u{1F1E9}\u{1F1F0}'),
  CurrencyPreset(code: 'SEK', label: 'SEK', flag: '\u{1F1F8}\u{1F1EA}'),
  CurrencyPreset(code: 'NOK', label: 'NOK', flag: '\u{1F1F3}\u{1F1F4}'),
  CurrencyPreset(code: 'CHF', label: 'CHF', flag: '\u{1F1E8}\u{1F1ED}'),
  CurrencyPreset(code: 'HRK', label: 'HRK', flag: '\u{1F1ED}\u{1F1F7}'),
  CurrencyPreset(code: 'RSD', label: 'RSD', flag: '\u{1F1F7}\u{1F1F8}'),
  CurrencyPreset(code: 'TRY', label: 'TRY', flag: '\u{1F1F9}\u{1F1F7}'),
  CurrencyPreset(code: 'PLN', label: 'PLN', flag: '\u{1F1F5}\u{1F1F1}'),
];
