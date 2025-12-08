import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:ai_weather/features/weather/data/datasources/remote_datasource.dart';
import 'package:ai_weather/features/weather/data/models/weather_model.dart';
import 'package:ai_weather/core/error/failures.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late RemoteDatasource datasource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    datasource = RemoteDatasourceImpl(mockDio);
  });

  group('fetchByCity', () {
    const tCityName = 'Seoul';
    final tWeatherJson = {
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
    final tWeatherModel = WeatherModel.fromJson(tWeatherJson);

    test('should return WeatherModel when the call to remote source is successful', () async {
      // Arrange
      when(() => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer(
        (_) async => Response(
          data: tWeatherJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await datasource.fetchByCity(tCityName);

      // Assert
      expect(result, equals(tWeatherModel));
      verify(() => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).called(1);
    });

    test('should throw ServerFailure when the call to remote source is unsuccessful', () async {
      // Arrange
      when(() => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer(
        (_) async => Response(
          data: {'message': 'Not Found'},
          statusCode: 404,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act & Assert
      expect(
        () async => await datasource.fetchByCity(tCityName),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('should throw NetworkFailure when there is no internet connection', () async {
      // Arrange
      when(() => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      // Act & Assert
      expect(
        () async => await datasource.fetchByCity(tCityName),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('fetchByLocation', () {
    const tLatitude = 37.5665;
    const tLongitude = 126.9780;
    final tWeatherJson = {
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
    final tWeatherModel = WeatherModel.fromJson(tWeatherJson);

    test('should return WeatherModel when the call to remote source is successful', () async {
      // Arrange
      when(() => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer(
        (_) async => Response(
          data: tWeatherJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await datasource.fetchByLocation(tLatitude, tLongitude);

      // Assert
      expect(result, equals(tWeatherModel));
      verify(() => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).called(1);
    });

    test('should throw NetworkFailure when there is no internet connection', () async {
      // Arrange
      when(() => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      // Act & Assert
      expect(
        () async => await datasource.fetchByLocation(tLatitude, tLongitude),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}

