import 'package:ai_weather/features/weather/domain/entities/weather_entity.dart';
import 'package:ai_weather/core/error/failures.dart';

/// WeatherRepository - 도메인 레이어의 레포지토리 인터페이스
/// 
/// 데이터 소스(Remote/Local)와 도메인 레이어 사이의 계약을 정의합니다.
/// 실제 구현은 data 레이어에서 제공됩니다.
abstract class WeatherRepository {
  /// 도시 이름으로 현재 날씨 조회
  /// 
  /// [cityName] 조회할 도시 이름
  /// 
  /// Returns [WeatherEntity] 성공 시
  /// Throws [Failure] 실패 시
  Future<WeatherEntity> fetchByCity(String cityName);

  /// 위도/경도로 현재 날씨 조회
  /// 
  /// [latitude] 위도
  /// [longitude] 경도
  /// 
  /// Returns [WeatherEntity] 성공 시
  /// Throws [Failure] 실패 시
  Future<WeatherEntity> fetchByLocation(double latitude, double longitude);

  /// 도시 이름으로 7일 예보 조회
  /// 
  /// [cityName] 조회할 도시 이름
  /// 
  /// Returns [List<WeatherEntity>] 성공 시 (7일치 예보)
  /// Throws [Failure] 실패 시
  Future<List<WeatherEntity>> forecast(String cityName);

  /// 날씨 정보를 캐시에 저장
  /// 
  /// [weather] 저장할 날씨 정보
  /// 
  /// Returns [void] 성공 시
  /// Throws [Failure] 실패 시
  Future<void> cache(WeatherEntity weather);
}

