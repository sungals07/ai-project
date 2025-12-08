import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_weather/features/weather/domain/repositories/weather_repository.dart';
import 'package:ai_weather/features/weather/domain/entities/weather_entity.dart';

/// WeatherRepository Provider
/// 
/// WeatherRepository 인스턴스를 제공하는 Provider입니다.
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  throw UnimplementedError('weatherRepositoryProvider must be overridden');
});

/// WeatherNotifier - 날씨 상태 관리 Notifier
/// 
/// Riverpod을 사용하여 날씨 데이터의 상태를 관리합니다.
class WeatherNotifier extends Notifier<AsyncValue<WeatherEntity>> {
  WeatherRepository get repository => ref.read(weatherRepositoryProvider);

  @override
  AsyncValue<WeatherEntity> build() {
    return const AsyncValue.loading();
  }

  /// 도시 이름으로 날씨 조회
  Future<void> fetchByCity(String cityName) async {
    state = const AsyncValue.loading();
    try {
      final weather = await repository.fetchByCity(cityName);
      state = AsyncValue.data(weather);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 위도/경도로 날씨 조회
  Future<void> fetchByLocation(double latitude, double longitude) async {
    state = const AsyncValue.loading();
    try {
      final weather = await repository.fetchByLocation(latitude, longitude);
      state = AsyncValue.data(weather);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// WeatherNotifier Provider
/// 
/// WeatherNotifier 인스턴스를 제공하는 Provider입니다.
final weatherNotifierProvider =
    NotifierProvider<WeatherNotifier, AsyncValue<WeatherEntity>>(() {
  return WeatherNotifier();
});

