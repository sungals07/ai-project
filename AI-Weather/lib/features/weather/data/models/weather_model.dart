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
    return WeatherModel(
      cityName: json['name'] as String,
      temperature: (json['main'] as Map<String, dynamic>)['temp'] as double,
      description: (json['weather'] as List<dynamic>)[0]['description'] as String,
      humidity: (json['main'] as Map<String, dynamic>)['humidity'] as int,
      windSpeed: (json['wind'] as Map<String, dynamic>)['speed'] as double,
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

