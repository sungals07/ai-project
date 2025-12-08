import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_weather/features/weather/data/datasources/local_datasource.dart';
import 'package:ai_weather/features/weather/data/models/weather_model.dart';
import 'package:ai_weather/core/error/failures.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late LocalDatasource datasource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    datasource = LocalDatasourceImpl(mockSharedPreferences);
  });

  group('cacheWeather', () {
    const tCityName = 'Seoul';
    final tWeatherModel = WeatherModel(
      cityName: tCityName,
      temperature: 22.5,
      description: 'Clear sky',
      humidity: 65,
      windSpeed: 3.5,
    );

    test('should store WeatherModel in SharedPreferences', () async {
      // Arrange
      when(() => mockSharedPreferences.setString(any(), any())).thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any())).thenAnswer((_) async => true);

      // Act
      await datasource.cacheWeather(tCityName, tWeatherModel);

      // Assert
      verify(() => mockSharedPreferences.setString(any(), any())).called(1);
      verify(() => mockSharedPreferences.setInt(any(), any())).called(1);
    });

    test('should throw CacheFailure when storage fails', () async {
      // Arrange
      when(() => mockSharedPreferences.setString(any(), any())).thenAnswer((_) async => false);

      // Act & Assert
      expect(
        () async => await datasource.cacheWeather(tCityName, tWeatherModel),
        throwsA(isA<CacheFailure>()),
      );
    });
  });

  group('getCachedWeather', () {
    const tCityName = 'Seoul';
    final tWeatherJson = {
      'name': 'Seoul',
      'main': {
        'temp': 22.5,
        'humidity': 65,
      },
      'weather': [
        {
          'description': 'Clear sky',
        }
      ],
      'wind': {
        'speed': 3.5,
      },
    };
    final tWeatherModel = WeatherModel.fromJson(tWeatherJson);

    test('should return WeatherModel when cache exists and is fresh', () async {
      // Arrange
      final now = DateTime.now().millisecondsSinceEpoch;
      final jsonString = jsonEncode(tWeatherModel.toJson());
      when(() => mockSharedPreferences.getString(any())).thenReturn(jsonString);
      when(() => mockSharedPreferences.getInt(any())).thenReturn(now);

      // Act
      final result = await datasource.getCachedWeather(tCityName);

      // Assert
      expect(result, isNotNull);
      expect(result!.cityName, equals(tCityName));
    });

    test('should return null when cache does not exist', () async {
      // Arrange
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);

      // Act
      final result = await datasource.getCachedWeather(tCityName);

      // Assert
      expect(result, isNull);
    });

    test('should return null when cache is stale', () async {
      // Arrange
      // 1시간 이상 오래된 캐시 (기본 신선도 기준: 30분)
      final staleTimestamp = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
      final jsonString = jsonEncode(tWeatherModel.toJson());
      when(() => mockSharedPreferences.getString(any())).thenReturn(jsonString);
      when(() => mockSharedPreferences.getInt(any())).thenReturn(staleTimestamp);

      // Act
      final result = await datasource.getCachedWeather(tCityName);

      // Assert
      expect(result, isNull);
    });
  });
}

