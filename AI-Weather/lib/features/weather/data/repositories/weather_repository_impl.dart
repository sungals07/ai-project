import 'package:ai_weather/features/weather/domain/repositories/weather_repository.dart';
import 'package:ai_weather/features/weather/domain/entities/weather_entity.dart';
import 'package:ai_weather/features/weather/data/datasources/remote_datasource.dart';
import 'package:ai_weather/features/weather/data/datasources/local_datasource.dart';
import 'package:ai_weather/features/weather/data/models/weather_model.dart';
import 'package:ai_weather/core/error/failures.dart';

/// WeatherRepositoryImpl - WeatherRepository 구현체
/// 
/// RemoteDatasource와 LocalDatasource를 통합하여
/// 캐시 → 네트워크 순서로 데이터를 조회합니다.
class WeatherRepositoryImpl implements WeatherRepository {
  final RemoteDatasource remoteDatasource;
  final LocalDatasource localDatasource;

  WeatherRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<WeatherEntity> fetchByCity(String cityName) async {
    try {
      // 1. 캐시에서 먼저 조회
      final cachedWeather = await localDatasource.getCachedWeather(cityName);
      
      // 2. 네트워크에서 최신 데이터 가져오기 (비동기로 실행)
      Future<WeatherModel> fetchRemote() async {
        try {
          final remoteWeather = await remoteDatasource.fetchByCity(cityName);
          // 네트워크 성공 시 캐시 업데이트
          await localDatasource.cacheWeather(cityName, remoteWeather);
          return remoteWeather;
        } catch (e) {
          // 네트워크 실패는 무시 (캐시가 있으면 사용)
          rethrow;
        }
      }

      // 캐시가 있으면 즉시 반환하고, 백그라운드에서 네트워크 업데이트
      if (cachedWeather != null) {
        // 비동기로 네트워크 업데이트 시도 (에러 무시)
        fetchRemote().catchError((_) => cachedWeather);
        return cachedWeather.toEntity();
      }

      // 캐시가 없으면 네트워크에서 가져오기
      final remoteWeather = await fetchRemote();
      return remoteWeather.toEntity();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<WeatherEntity> fetchByLocation(double latitude, double longitude) async {
    try {
      // 위치 기반 조회는 네트워크 우선 (캐시 키가 복잡함)
      final remoteWeather = await remoteDatasource.fetchByLocation(latitude, longitude);
      
      // 성공 시 캐시 저장
      await localDatasource.cacheWeather(remoteWeather.cityName, remoteWeather);
      
      return remoteWeather.toEntity();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<List<WeatherEntity>> forecast(String cityName) async {
    try {
      // 예보는 항상 네트워크에서 가져오기 (캐시 불필요)
      final forecastList = await remoteDatasource.forecast(cityName);
      return forecastList.map((model) => model.toEntity()).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<void> cache(WeatherEntity weather) async {
    try {
      final weatherModel = WeatherModel(
        cityName: weather.cityName,
        temperature: weather.temperature,
        description: weather.description,
        humidity: weather.humidity,
        windSpeed: weather.windSpeed,
      );
      await localDatasource.cacheWeather(weather.cityName, weatherModel);
    } on Failure {
      rethrow;
    } catch (e) {
      throw CacheFailure('Failed to cache weather: $e');
    }
  }
}

