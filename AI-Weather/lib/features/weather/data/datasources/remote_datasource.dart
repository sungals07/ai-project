import 'package:dio/dio.dart';
import 'package:ai_weather/features/weather/data/models/weather_model.dart';
import 'package:ai_weather/core/error/failures.dart';

/// RemoteDatasource - 원격 데이터 소스 인터페이스
/// 
/// API 통신을 담당하는 데이터 소스의 계약을 정의합니다.
abstract class RemoteDatasource {
  /// 도시 이름으로 현재 날씨 조회
  Future<WeatherModel> fetchByCity(String cityName);

  /// 위도/경도로 현재 날씨 조회
  Future<WeatherModel> fetchByLocation(double latitude, double longitude);

  /// 도시 이름으로 7일 예보 조회
  Future<List<WeatherModel>> forecast(String cityName);
}

/// RemoteDatasourceImpl - RemoteDatasource 구현체
/// 
/// Dio를 사용하여 실제 API 통신을 수행합니다.
class RemoteDatasourceImpl implements RemoteDatasource {
  final Dio dio;

  RemoteDatasourceImpl(this.dio);

  @override
  Future<WeatherModel> fetchByCity(String cityName) async {
    try {
      final response = await dio.get(
        '/weather',
        queryParameters: {'q': cityName},
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw ServerFailure('Failed to fetch weather: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkFailure('Network error: ${e.message}');
      } else {
        throw ServerFailure('Server error: ${e.message}');
      }
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<WeatherModel> fetchByLocation(double latitude, double longitude) async {
    try {
      final response = await dio.get(
        '/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
        },
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw ServerFailure('Failed to fetch weather: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkFailure('Network error: ${e.message}');
      } else {
        throw ServerFailure('Server error: ${e.message}');
      }
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<List<WeatherModel>> forecast(String cityName) async {
    try {
      final response = await dio.get(
        '/forecast',
        queryParameters: {'q': cityName},
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['list'] ?? [];
        return list.map((json) => WeatherModel.fromJson(json)).toList();
      } else {
        throw ServerFailure('Failed to fetch forecast: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkFailure('Network error: ${e.message}');
      } else {
        throw ServerFailure('Server error: ${e.message}');
      }
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }
}

