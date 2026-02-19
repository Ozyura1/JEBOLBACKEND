import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jebol_mobile/core/hardening/empty_states.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('renders with title and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(title: 'No Data', icon: Icons.inbox),
          ),
        ),
      );

      expect(find.text('No Data'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('renders with subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No Data',
              subtitle: 'Please try again',
            ),
          ),
        ),
      );

      expect(find.text('No Data'), findsOneWidget);
      expect(find.text('Please try again'), findsOneWidget);
    });

    testWidgets('renders action button when provided', (tester) async {
      var buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No Data',
              actionLabel: 'Retry',
              onAction: () => buttonPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(buttonPressed, isTrue);
    });

    testWidgets('does not render action button when no callback', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No Data',
              actionLabel: 'Retry',
              // No onAction provided
            ),
          ),
        ),
      );

      // Button should not be present
      expect(find.widgetWithText(FilledButton, 'Retry'), findsNothing);
    });

    group('Factory constructors', () {
      testWidgets('noData factory', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: EmptyStateWidget.noData())),
        );

        expect(find.text('Tidak ada data'), findsOneWidget);
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      });

      testWidgets('noResults factory', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: EmptyStateWidget.noResults())),
        );

        expect(find.text('Tidak ditemukan'), findsOneWidget);
        expect(find.byIcon(Icons.search_off), findsOneWidget);
      });

      testWidgets('noConnection factory', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget.noConnection(onAction: () {}),
            ),
          ),
        );

        expect(find.text('Tidak ada koneksi'), findsOneWidget);
        expect(find.byIcon(Icons.wifi_off), findsOneWidget);
        expect(find.text('Coba Lagi'), findsOneWidget);
      });

      testWidgets('error factory', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: EmptyStateWidget.error())),
        );

        expect(find.text('Terjadi Kesalahan'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('noPermission factory', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: EmptyStateWidget.noPermission())),
        );

        expect(find.text('Akses Ditolak'), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      });

      testWidgets('comingSoon factory', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: EmptyStateWidget.comingSoon())),
        );

        expect(find.text('Segera Hadir'), findsOneWidget);
        expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
      });
    });
  });

  group('LoadingWidget', () {
    testWidgets('renders spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingWidget())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget(message: 'Loading...')),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('compact mode shows row layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(message: 'Loading...', compact: true),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });
  });

  group('ErrorWidget2', () {
    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorWidget2(message: 'Something went wrong')),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders retry button when callback provided', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorWidget2(message: 'Error', onRetry: () => retried = true),
          ),
        ),
      );

      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      expect(retried, isTrue);
    });

    testWidgets('renders details when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorWidget2(
              message: 'Error',
              details: 'Technical details here',
            ),
          ),
        ),
      );

      expect(find.text('Technical details here'), findsOneWidget);
    });
  });
}
