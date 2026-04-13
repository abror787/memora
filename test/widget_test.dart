import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_projects_ios/core/theme/app_theme.dart';
import 'package:android_projects_ios/core/components/components.dart';

void main() {
  group('AppTheme Tests', () {
    test('AppTheme.lightTheme returns valid ThemeData', () {
      final theme = AppTheme.lightTheme;
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
    });

    test('AppColors contains all required colors', () {
      expect(AppColors.primary, isA<Color>());
      expect(AppColors.secondary, isA<Color>());
      expect(AppColors.success, isA<Color>());
      expect(AppColors.error, isA<Color>());
      expect(AppColors.background, isA<Color>());
      expect(AppColors.surface, isA<Color>());
    });
  });

  group('AppCard Widget Tests', () {
    testWidgets('AppCard renders child correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('AppCard responds to tap when onTap provided', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: Text('Tappable Card'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tappable Card'));
      expect(tapped, isTrue);
    });
  });

  group('PrimaryButton Widget Tests', () {
    testWidgets('PrimaryButton displays text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('PrimaryButton shows loading indicator when isLoading',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Loading',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('PrimaryButton does not trigger onPressed when loading',
        (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Test',
              isLoading: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(pressed, isFalse);
    });

    testWidgets('PrimaryButton displays icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'With Icon',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('AppProgressBar Widget Tests', () {
    testWidgets('AppProgressBar renders with given progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppProgressBar(
              progress: 0.5,
            ),
          ),
        ),
      );

      expect(find.byType(AppProgressBar), findsOneWidget);
    });

    testWidgets('AppProgressBar handles 0 progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppProgressBar(
              progress: 0.0,
            ),
          ),
        ),
      );

      expect(find.byType(AppProgressBar), findsOneWidget);
    });

    testWidgets('AppProgressBar handles 100% progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppProgressBar(
              progress: 1.0,
            ),
          ),
        ),
      );

      expect(find.byType(AppProgressBar), findsOneWidget);
    });
  });

  group('StatTile Widget Tests', () {
    testWidgets('StatTile displays icon, value, and label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatTile(
              icon: Icons.star,
              value: '100',
              label: 'Points',
              color: Colors.amber,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('Points'), findsOneWidget);
    });
  });

  group('FlashcardWidget Tests', () {
    testWidgets('FlashcardWidget displays question', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              question: 'What is Flutter?',
            ),
          ),
        ),
      );

      expect(find.text('What is Flutter?'), findsOneWidget);
      expect(find.text('Вопрос'), findsOneWidget);
    });

    testWidgets('FlashcardWidget shows answer when showAnswer is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              question: 'What is Flutter?',
              answer: 'A UI toolkit',
              showAnswer: true,
            ),
          ),
        ),
      );

      expect(find.text('A UI toolkit'), findsOneWidget);
      expect(find.text('Ответ'), findsOneWidget);
    });

    testWidgets('FlashcardWidget shows button when not showing answer',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              question: 'What is Flutter?',
              onShowAnswer: () {},
            ),
          ),
        ),
      );

      expect(find.text('Показать ответ'), findsOneWidget);
    });

    testWidgets('FlashcardWidget calls onShowAnswer when button tapped',
        (tester) async {
      bool showedAnswer = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              question: 'What is Flutter?',
              onShowAnswer: () => showedAnswer = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Показать ответ'));
      expect(showedAnswer, isTrue);
    });
  });
}
