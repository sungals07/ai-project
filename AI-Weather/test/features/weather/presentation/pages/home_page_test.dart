import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_weather/features/weather/presentation/pages/home_page.dart';
import 'package:ai_weather/features/weather/presentation/notifiers/weather_notifier.dart';
import 'package:ai_weather/features/weather/domain/repositories/weather_repository.dart';
import 'package:ai_weather/features/weather/domain/entities/weather_entity.dart';
import 'package:ai_weather/core/error/failures.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late MockWeatherRepository mockRepository;

  setUp(() {
    mockRepository = MockWeatherRepository();
  });

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        weatherRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('HomePage', () {
    testWidgets('should display search field', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(const HomePage()));

      // Assert
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display loading indicator when loading', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(const HomePage()));

      // Act
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display weather data when loaded', (WidgetTester tester) async {
      // Arrange
      const tWeatherEntity = WeatherEntity(
        cityName: 'Seoul',
        temperature: 22.5,
        description: 'Clear sky',
        humidity: 65,
        windSpeed: 3.5,
      );

      when(() => mockRepository.fetchByCity(any())).thenAnswer((_) async => tWeatherEntity);

      await tester.pumpWidget(createTestWidget(const HomePage()));

      // Act
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Seoul');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.text('Seoul'), findsWidgets);
      expect(find.text('22.5°C'), findsOneWidget);
      expect(find.text('Clear sky'), findsOneWidget);
    });

    testWidgets('should display error message when fetch fails', (WidgetTester tester) async {
      // Arrange
      when(() => mockRepository.fetchByCity(any()))
          .thenThrow(NetworkFailure('Network error'));

      await tester.pumpWidget(createTestWidget(const HomePage()));

      // Act
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Seoul');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.textContaining('error'), findsWidgets);
    });
  });
}

