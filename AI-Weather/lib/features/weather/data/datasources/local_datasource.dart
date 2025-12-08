import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_weather/features/weather/data/models/weather_model.dart';
import 'package:ai_weather/core/error/failures.dart';

/// LocalDatasource - 로컬 데이터 소스 인터페이스
/// 
/// 로컬 캐시(SharedPreferences)를 담당하는 데이터 소스의 계약을 정의합니다.
abstract class LocalDatasource {
  /// 날씨 정보를 캐시에 저장
  Future<void> cacheWeather(String cityName, WeatherModel weatherModel);

  /// 캐시된 날씨 정보 조회
  /// 
  /// 캐시가 존재하고 신선한 경우에만 반환합니다.
  /// Returns [WeatherModel] 캐시가 존재하고 신선한 경우
  /// Returns [null] 캐시가 없거나 오래된 경우
  Future<WeatherModel?> getCachedWeather(String cityName);
}

/// LocalDatasourceImpl - LocalDatasource 구현체
/// 
/// SharedPreferences를 사용하여 실제 로컬 캐시를 관리합니다.
class LocalDatasourceImpl implements LocalDatasource {
  final SharedPreferences sharedPreferences;
  static const String _cachePrefix = 'CACHED_WEATHER_';
  static const String _timestampPrefix = 'CACHED_TIMESTAMP_';
  static const int _cacheValidityMinutes = 30; // 30분간 유효

  LocalDatasourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheWeather(String cityName, WeatherModel weatherModel) async {
    try {
      final cacheKey = '$_cachePrefix$cityName';
      final timestampKey = '$_timestampPrefix$cityName';
      
      final jsonString = jsonEncode(weatherModel.toJson());
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final success = await sharedPreferences.setString(cacheKey, jsonString);
      if (!success) {
        throw CacheFailure('Failed to cache weather data');
      }

      final timestampSuccess = await sharedPreferences.setInt(timestampKey, timestamp);
      if (!timestampSuccess) {
        throw CacheFailure('Failed to cache timestamp');
      }
    } catch (e) {
      if (e is CacheFailure) {
        rethrow;
      }
      throw CacheFailure('Unexpected error while caching: $e');
    }
  }

  @override
  Future<WeatherModel?> getCachedWeather(String cityName) async {
    try {
      final cacheKey = '$_cachePrefix$cityName';
      final timestampKey = '$_timestampPrefix$cityName';

      final cachedJsonString = sharedPreferences.getString(cacheKey);
      if (cachedJsonString == null) {
        return null;
      }

      final cachedTimestamp = sharedPreferences.getInt(timestampKey);
      if (cachedTimestamp == null) {
        return null;
      }

      // 신선도 확인 (30분 이내)
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheAge = now - cachedTimestamp;
      final cacheValidityMs = _cacheValidityMinutes * 60 * 1000;

      if (cacheAge > cacheValidityMs) {
        // 캐시가 오래됨
        return null;
      }

      // JSON 파싱
      final jsonMap = jsonDecode(cachedJsonString) as Map<String, dynamic>;
      return WeatherModel.fromJson(jsonMap);
    } catch (e) {
      throw CacheFailure('Failed to get cached weather: $e');
    }
  }
}

