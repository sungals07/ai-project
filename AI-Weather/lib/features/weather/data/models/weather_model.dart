
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ai_weather/features/weather/domain/entities/weather_entity.dart';

part 'weather_model.freezed.dart';

/// WeatherModel - Data 레이어의 모델
/// 
/// Freezed를 사용하여 불변성을 보장하고, JSON 직렬화를 지원합니다.
/// WeatherEntity와 동일한 구조를 가지며, toEntity()로 변환 가능합니다.
@freezed
class WeatherModel with _$WeatherModel {
  const factory WeatherModel({
    required String cityName,
    required double temperature,
    required String description,
    required int humidity,
    required double windSpeed,
  }) = _WeatherModel;

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // 안전한 파싱을 위한 검증
    final cityName = json['name'] as String? ?? 'Unknown';
    
    final main = json['main'] as Map<String, dynamic>?;
    if (main == null) {
      throw FormatException('Missing "main" field in weather data');
    }
    final temperature = (main['temp'] as num?)?.toDouble() ?? 0.0;
    final humidity = (main['humidity'] as num?)?.toInt() ?? 0;
    
    final weatherList = json['weather'] as List<dynamic>?;
    if (weatherList == null || weatherList.isEmpty) {
      throw FormatException('Missing or empty "weather" array in weather data');
    }
    final weather = weatherList[0] as Map<String, dynamic>;
    final description = (weather['description'] as String?) ?? 'Unknown';
    
    final wind = json['wind'] as Map<String, dynamic>?;
    final windSpeed = (wind?['speed'] as num?)?.toDouble() ?? 0.0;
    
    return WeatherModel(
      cityName: cityName,
      temperature: temperature,
      description: description,
      humidity: humidity,
      windSpeed: windSpeed,
    );
  }

  const WeatherModel._();

  /// WeatherEntity로 변환
  WeatherEntity toEntity() {
    return WeatherEntity(
      cityName: cityName,
      temperature: temperature,
      description: description,
      humidity: humidity,
      windSpeed: windSpeed,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'main': {
        'temp': temperature,
        'humidity': humidity,
      },
      'weather': [
        {
          'description': description,
        }
      ],
      'wind': {
        'speed': windSpeed,
      },
    };
  }
}

