import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_weather/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:ai_weather/features/weather/domain/repositories/weather_repository.dart';
import 'package:ai_weather/features/weather/data/datasources/remote_datasource.dart';
import 'package:ai_weather/features/weather/data/datasources/local_datasource.dart';
import 'package:ai_weather/features/weather/data/models/weather_model.dart';
import 'package:ai_weather/features/weather/domain/entities/weather_entity.dart';
import 'package:ai_weather/core/error/failures.dart';

class MockRemoteDatasource extends Mock implements RemoteDatasource {}
class MockLocalDatasource extends Mock implements LocalDatasource {}

void main() {
  late WeatherRepository repository;
  late MockRemoteDatasource mockRemoteDatasource;
  late MockLocalDatasource mockLocalDatasource;

  setUpAll(() {
    registerFallbackValue(WeatherModel(
      cityName: '',
      temperature: 0.0,
      description: '',
      humidity: 0,
      windSpeed: 0.0,
    ));
  });

  setUp(() {
    mockRemoteDatasource = MockRemoteDatasource();
    mockLocalDatasource = MockLocalDatasource();
    repository = WeatherRepositoryImpl(
      remoteDatasource: mockRemoteDatasource,
      localDatasource: mockLocalDatasource,
    );
  });

  group('fetchByCity', () {
    const tCityName = 'Seoul';
    final tWeatherModel = WeatherModel(
      cityName: tCityName,
      temperature: 22.5,
      description: 'Clear sky',
      humidity: 65,
      windSpeed: 3.5,
    );
    final tWeatherEntity = tWeatherModel.toEntity();

    test('should return cached weather when cache exists', () async {
      // Arrange
      when(() => mockLocalDatasource.getCachedWeather(tCityName))
          .thenAnswer((_) async => tWeatherModel);
      when(() => mockRemoteDatasource.fetchByCity(tCityName))
          .thenAnswer((_) async => tWeatherModel);
      when(() => mockLocalDatasource.cacheWeather(tCityName, any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.fetchByCity(tCityName);

      // Assert
      expect(result, equals(tWeatherEntity));
      verify(() => mockLocalDatasource.getCachedWeather(tCityName)).called(1);
      // 네트워크 호출은 비동기로 실행되므로 약간의 대기 후 확인
      await Future.delayed(const Duration(milliseconds: 100));
      verify(() => mockRemoteDatasource.fetchByCity(tCityName)).called(1);
    });

    test('should return remote weather when cache does not exist', () async {
      // Arrange
      when(() => mockLocalDatasource.getCachedWeather(tCityName))
          .thenAnswer((_) async => null);
      when(() => mockRemoteDatasource.fetchByCity(tCityName))
          .thenAnswer((_) async => tWeatherModel);
      when(() => mockLocalDatasource.cacheWeather(tCityName, any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.fetchByCity(tCityName);

      // Assert
      expect(result, equals(tWeatherEntity));
      verify(() => mockLocalDatasource.getCachedWeather(tCityName)).called(1);
      verify(() => mockRemoteDatasource.fetchByCity(tCityName)).called(1);
      verify(() => mockLocalDatasource.cacheWeather(tCityName, any())).called(1);
    });

    test('should return cached weather when network fails', () async {
      // Arrange
      when(() => mockLocalDatasource.getCachedWeather(tCityName))
          .thenAnswer((_) async => tWeatherModel);
      when(() => mockRemoteDatasource.fetchByCity(tCityName))
          .thenThrow(NetworkFailure('Network error'));

      // Act
      final result = await repository.fetchByCity(tCityName);

      // Assert
      expect(result, equals(tWeatherEntity));
      verify(() => mockLocalDatasource.getCachedWeather(tCityName)).called(1);
      verify(() => mockRemoteDatasource.fetchByCity(tCityName)).called(1);
      verifyNever(() => mockLocalDatasource.cacheWeather(any(), any()));
    });

    test('should throw Failure when both cache and network fail', () async {
      // Arrange
      when(() => mockLocalDatasource.getCachedWeather(tCityName))
          .thenAnswer((_) async => null);
      when(() => mockRemoteDatasource.fetchByCity(tCityName))
          .thenThrow(NetworkFailure('Network error'));

      // Act & Assert
      expect(
        () async => await repository.fetchByCity(tCityName),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('fetchByLocation', () {
    const tLatitude = 37.5665;
    const tLongitude = 126.9780;
    final tWeatherModel = WeatherModel(
      cityName: 'Seoul',
      temperature: 22.5,
      description: 'Clear sky',
      humidity: 65,
      windSpeed: 3.5,
    );
    final tWeatherEntity = tWeatherModel.toEntity();

    test('should return remote weather when cache does not exist', () async {
      // Arrange
      // 위치 기반 조회는 캐시 키가 복잡하므로 네트워크 우선
      when(() => mockRemoteDatasource.fetchByLocation(tLatitude, tLongitude))
          .thenAnswer((_) async => tWeatherModel);
      when(() => mockLocalDatasource.cacheWeather(any(), any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.fetchByLocation(tLatitude, tLongitude);

      // Assert
      expect(result, equals(tWeatherEntity));
      verify(() => mockRemoteDatasource.fetchByLocation(tLatitude, tLongitude)).called(1);
      verify(() => mockLocalDatasource.cacheWeather(any(), any())).called(1);
    });
  });

  group('cache', () {
    final tWeatherEntity = WeatherEntity(
      cityName: 'Seoul',
      temperature: 22.5,
      description: 'Clear sky',
      humidity: 65,
      windSpeed: 3.5,
    );

    test('should cache weather entity', () async {
      // Arrange
      when(() => mockLocalDatasource.cacheWeather(any(), any()))
          .thenAnswer((_) async => {});

      // Act
      await repository.cache(tWeatherEntity);

      // Assert
      verify(() => mockLocalDatasource.cacheWeather(
        tWeatherEntity.cityName,
        any(that: predicate<WeatherModel>((m) => m.cityName == tWeatherEntity.cityName)),
      )).called(1);
    });
  });
}

