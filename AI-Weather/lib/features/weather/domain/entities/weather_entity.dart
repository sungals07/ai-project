import 'package:equatable/equatable.dart';

/// Weather Entity - 도메인 레이어의 순수한 비즈니스 모델
/// 
/// 이 엔티티는 비즈니스 로직에 필요한 날씨 정보를 담고 있습니다.
/// 데이터 소스나 프레젠테이션 레이어에 의존하지 않는 순수한 도메인 모델입니다.
class WeatherEntity extends Equatable {
  final String cityName;
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;

  const WeatherEntity({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
  });

  @override
  List<Object> get props => [
        cityName,
        temperature,
        description,
        humidity,
        windSpeed,
      ];
}

