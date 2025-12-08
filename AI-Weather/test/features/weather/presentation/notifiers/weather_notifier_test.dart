import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  group('WeatherNotifier', () {
    test('should have initial state as AsyncValue.loading()', () {
      // Arrange & Act
      final container = ProviderContainer(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Assert
      final state = container.read(weatherNotifierProvider);
      expect(state.isLoading, isTrue);
    });

    test('should update state to success when fetchByCity succeeds', () async {
      // Arrange
      const tCityName = 'Seoul';
      final tWeatherEntity = WeatherEntity(
        cityName: tCityName,
        temperature: 22.5,
        description: 'Clear sky',
        humidity: 65,
        windSpeed: 3.5,
      );

      when(() => mockRepository.fetchByCity(tCityName))
          .thenAnswer((_) async => tWeatherEntity);

      final container = ProviderContainer(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      final notifier = container.read(weatherNotifierProvider.notifier);

      // Act
      await notifier.fetchByCity(tCityName);

      // Assert
      final state = container.read(weatherNotifierProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, equals(tWeatherEntity));
      verify(() => mockRepository.fetchByCity(tCityName)).called(1);
    });

    test('should update state to error when fetchByCity fails', () async {
      // Arrange
      const tCityName = 'Seoul';
      when(() => mockRepository.fetchByCity(tCityName))
          .thenThrow(NetworkFailure('Network error'));

      final container = ProviderContainer(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      final notifier = container.read(weatherNotifierProvider.notifier);

      // Act
      await notifier.fetchByCity(tCityName);

      // Assert
      final state = container.read(weatherNotifierProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<NetworkFailure>());
    });

    test('should update state to loading during fetch', () async {
      // Arrange
      const tCityName = 'Seoul';
      final tWeatherEntity = WeatherEntity(
        cityName: tCityName,
        temperature: 22.5,
        description: 'Clear sky',
        humidity: 65,
        windSpeed: 3.5,
      );

      // 지연을 추가하여 로딩 상태 확인
      when(() => mockRepository.fetchByCity(tCityName))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return tWeatherEntity;
      });

      final container = ProviderContainer(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      final notifier = container.read(weatherNotifierProvider.notifier);

      // Act
      final future = notifier.fetchByCity(tCityName);

      // Assert - 로딩 중 상태 확인
      final loadingState = container.read(weatherNotifierProvider);
      expect(loadingState.isLoading, isTrue);

      // 완료 대기
      await future;

      // 최종 상태 확인
      final finalState = container.read(weatherNotifierProvider);
      expect(finalState.hasValue, isTrue);
    });
  });
}

