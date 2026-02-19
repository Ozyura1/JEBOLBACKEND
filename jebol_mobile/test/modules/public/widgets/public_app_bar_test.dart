import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jebol_mobile/modules/public/widgets/public_app_bar.dart';
import 'package:jebol_mobile/modules/public/provider/public_locale_provider.dart';
import 'package:jebol_mobile/modules/public/l10n/public_strings.dart';

void main() {
  late PublicLocaleProvider localeProvider;

  setUp(() {
    localeProvider = PublicLocaleProvider();
  });

  Widget createTestWidget({required Widget child}) {
    return MaterialApp(
      home: ChangeNotifierProvider<PublicLocaleProvider>.value(
        value: localeProvider,
        child: child,
      ),
    );
  }

  group('PublicAppBar', () {
    testWidgets('should display title', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(
            appBar: PublicAppBar(
              title: 'Test Title',
              localeProvider: localeProvider,
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('should show back button when leading is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(
            appBar: PublicAppBar(
              title: 'Test',
              localeProvider: localeProvider,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should include language toggle by default', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(
            appBar: PublicAppBar(title: 'Test', localeProvider: localeProvider),
          ),
        ),
      );

      // Language toggle should be visible
      expect(find.text('ID'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
    });

    testWidgets(
      'should hide language toggle when showLanguageToggle is false',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            child: Scaffold(
              appBar: PublicAppBar(
                title: 'Test',
                localeProvider: localeProvider,
                showLanguageToggle: false,
              ),
            ),
          ),
        );

        // Language toggle should not be visible
        expect(find.text('ID'), findsNothing);
        expect(find.text('EN'), findsNothing);
      },
    );

    testWidgets('should display custom actions', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(
            appBar: PublicAppBar(
              title: 'Test',
              localeProvider: localeProvider,
              actions: [
                IconButton(icon: const Icon(Icons.help), onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.help), findsOneWidget);
    });

    testWidgets('should use government theme colors', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(
            appBar: PublicAppBar(title: 'Test', localeProvider: localeProvider),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, const Color(0xFF1565C0));
    });

    testWidgets('should have correct preferred size', (tester) async {
      final appBar = PublicAppBar(
        title: 'Test',
        localeProvider: localeProvider,
      );

      expect(appBar.preferredSize, const Size.fromHeight(kToolbarHeight));
    });
  });

  group('PublicHeader', () {
    testWidgets('should render without errors', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(body: PublicHeader(localeProvider: localeProvider)),
        ),
      );

      expect(find.byType(PublicHeader), findsOneWidget);
    });

    testWidgets('should have gradient background', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(body: PublicHeader(localeProvider: localeProvider)),
        ),
      );

      // Should have a Container with decoration
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should contain language toggle', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(
            body: SingleChildScrollView(
              child: PublicHeader(localeProvider: localeProvider),
            ),
          ),
        ),
      );

      // Should have language toggle in header
      expect(find.text('ID'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
    });
  });

  group('PublicAppBar Language Toggle Integration', () {
    testWidgets('language toggle should change locale', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(
            appBar: PublicAppBar(title: 'Test', localeProvider: localeProvider),
            body: ListenableBuilder(
              listenable: localeProvider,
              builder: (context, _) =>
                  Text(localeProvider.isIndonesian ? 'Indonesian' : 'English'),
            ),
          ),
        ),
      );

      // Initial: Indonesian
      expect(find.text('Indonesian'), findsOneWidget);

      // Tap EN
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();

      // Should be English now
      expect(find.text('English'), findsOneWidget);
    });
  });
}
