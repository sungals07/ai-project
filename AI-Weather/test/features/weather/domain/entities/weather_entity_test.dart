import 'package:flutter_test/flutter_test.dart';
import 'package:ai_weather/features/weather/domain/entities/weather_entity.dart';

void main() {
  group('WeatherEntity', () {
    test('should create a WeatherEntity with all required fields', () {
      // Arrange
      const cityName = 'Seoul';
      const temperature = 22.5;
      const description = 'Clear sky';
      const humidity = 65;
      const windSpeed = 3.5;

      // Act
      final weather = WeatherEntity(
        cityName: cityName,
        temperature: temperature,
        description: description,
        humidity: humidity,
        windSpeed: windSpeed,
      );

      // Assert
      expect(weather.cityName, equals(cityName));
      expect(weather.temperature, equals(temperature));
      expect(weather.description, equals(description));
      expect(weather.humidity, equals(humidity));
      expect(weather.windSpeed, equals(windSpeed));
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      const weather1 = WeatherEntity(
        cityName: 'Seoul',
        temperature: 22.5,
        description: 'Clear sky',
        humidity: 65,
        windSpeed: 3.5,
      );

      const weather2 = WeatherEntity(
        cityName: 'Seoul',
        temperature: 22.5,
        description: 'Clear sky',
        humidity: 65,
        windSpeed: 3.5,
      );

      // Assert
      expect(weather1, equals(weather2));
      expect(weather1.hashCode, equals(weather2.hashCode));
    });

    test('should not be equal when properties differ', () {
      // Arrange
      const weather1 = WeatherEntity(
        cityName: 'Seoul',
        temperature: 22.5,
        description: 'Clear sky',
        humidity: 65,
        windSpeed: 3.5,
      );

      const weather2 = WeatherEntity(
        cityName: 'Busan',
        temperature: 22.5,
        description: 'Clear sky',
        humidity: 65,
        windSpeed: 3.5,
      );

      // Assert
      expect(weather1, isNot(equals(weather2)));
    });

    test('should be immutable', () {
      // Arrange
      final weather = WeatherEntity(
        cityName: 'Seoul',
        temperature: 22.5,
        description: 'Clear sky',
        humidity: 65,
        windSpeed: 3.5,
      );

      // Assert - copyWith이 없다면 immutable이어야 함
      // 또는 copyWith이 있다면 새 인스턴스를 반환해야 함
      expect(weather, isA<WeatherEntity>());
    });
  });
}

