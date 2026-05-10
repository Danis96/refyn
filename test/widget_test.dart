import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:refyn/app/features/dashboard/ui/widgets/bottom_navigation_tabs.dart';
import 'package:refyn/l10n/app_localizations.dart';

void main() {
  testWidgets('shows bottom navigation destinations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          bottomNavigationBar: BottomNavigationTabs(
            currentIndex: 1,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
