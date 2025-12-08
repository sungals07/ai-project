import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ai_weather/features/weather/presentation/pages/home_page.dart';
import 'package:ai_weather/features/weather/presentation/notifiers/weather_notifier.dart';
import 'package:ai_weather/features/weather/data/datasources/remote_datasource.dart';
import 'package:ai_weather/features/weather/data/datasources/local_datasource.dart';
import 'package:ai_weather/features/weather/data/repositories/weather_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드 (파일이 없어도 계속 진행)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // .env 파일이 없으면 무시 (개발 환경에서만)
    debugPrint('Warning: .env file not found. Please create .env file with OPENWEATHERMAP_API_KEY');
  }

  // SharedPreferences 초기화
  final sharedPreferences = await SharedPreferences.getInstance();

  // Dio 클라이언트 설정
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  // Interceptor 추가 (필요시)
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        // 에러 처리 로직
        return handler.next(error);
      },
    ),
  );

  // API 키 가져오기
  final apiKey = dotenv.env['OPENWEATHERMAP_API_KEY'] ?? '';
  if (apiKey.isEmpty || apiKey == 'your_api_key_here') {
    throw Exception(
      'OPENWEATHERMAP_API_KEY is not set in .env file.\n'
      'Please create .env file in the project root with:\n'
      'OPENWEATHERMAP_API_KEY=your_actual_api_key\n'
      'You can copy .env.example to .env and update it.'
    );
  }

  // 의존성 주입
  final remoteDatasource = RemoteDatasourceImpl(dio, apiKey: apiKey);
  final localDatasource = LocalDatasourceImpl(sharedPreferences);
  final weatherRepository = WeatherRepositoryImpl(
    remoteDatasource: remoteDatasource,
    localDatasource: localDatasource,
  );

  runApp(
    ProviderScope(
      overrides: [
        weatherRepositoryProvider.overrideWithValue(weatherRepository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

