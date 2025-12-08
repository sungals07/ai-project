import 'package:flutter_test/flutter_test.dart';
import 'package:ai_weather/features/weather/data/models/weather_model.dart';
import 'package:ai_weather/features/weather/domain/entities/weather_entity.dart';

void main() {
  group('WeatherModel', () {
    const tWeatherModel = WeatherModel(
      cityName: 'Seoul',
      temperature: 22.5,
      description: 'Clear sky',
      humidity: 65,
      windSpeed: 3.5,
    );

    test('should have the same structure as WeatherEntity', () {
      // Act
      final entity = tWeatherModel.toEntity();
      
      // Assert
      expect(entity, isA<WeatherEntity>());
      expect(entity.cityName, equals(tWeatherModel.cityName));
      expect(entity.temperature, equals(tWeatherModel.temperature));
      expect(entity.description, equals(tWeatherModel.description));
      expect(entity.humidity, equals(tWeatherModel.humidity));
      expect(entity.windSpeed, equals(tWeatherModel.windSpeed));
    });

    test('should create a WeatherModel from JSON', () {
      // Arrange
      final jsonMap = {
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

      // Act
      final result = WeatherModel.fromJson(jsonMap);

      // Assert
      expect(result.cityName, equals('Seoul'));
      expect(result.temperature, equals(22.5));
      expect(result.description, equals('Clear sky'));
      expect(result.humidity, equals(65));
      expect(result.windSpeed, equals(3.5));
    });

    test('should convert WeatherModel to JSON', () {
      // Act
      final result = tWeatherModel.toJson();

      // Assert
      expect(result['name'], equals('Seoul'));
      expect(result['main']['temp'], equals(22.5));
      expect(result['main']['humidity'], equals(65));
      expect(result['weather'][0]['description'], equals('Clear sky'));
      expect(result['wind']['speed'], equals(3.5));
    });

    test('should convert WeatherModel to WeatherEntity', () {
      // Act
      final result = tWeatherModel.toEntity();

      // Assert
      expect(result, isA<WeatherEntity>());
      expect(result.cityName, equals('Seoul'));
      expect(result.temperature, equals(22.5));
      expect(result.description, equals('Clear sky'));
      expect(result.humidity, equals(65));
      expect(result.windSpeed, equals(3.5));
    });

    test('should support copyWith method', () {
      // Act
      final result = tWeatherModel.copyWith(temperature: 25.0);

      // Assert
      expect(result.temperature, equals(25.0));
      expect(result.cityName, equals('Seoul'));
      expect(result.description, equals('Clear sky'));
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      const weatherModel1 = WeatherModel(
        cityName: 'Seoul',
        temperature: 22.5,
        description: 'Clear sky',
        humidity: 65,
        windSpeed: 3.5,
      );

      const weatherModel2 = WeatherModel(
        cityName: 'Seoul',
        temperature: 22.5,
        description: 'Clear sky',
        humidity: 65,
        windSpeed: 3.5,
      );

      // Assert
      expect(weatherModel1, equals(weatherModel2));
      expect(weatherModel1.hashCode, equals(weatherModel2.hashCode));
    });
  });
}

