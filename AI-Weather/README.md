# AI Weather App

Flutter 기반 날씨 앱 - TDD 기반 개발

## 프로젝트 구조

클린 아키텍처 기반의 기능 중심 구조:
- `lib/features/weather/domain` - 도메인 레이어
- `lib/features/weather/data` - 데이터 레이어
- `lib/features/weather/presentation` - 프레젠테이션 레이어
- `lib/core` - 공통 유틸리티

## 환경 설정

### 1. OpenWeatherMap API 키 설정

1. `.env.example` 파일을 `.env`로 복사:
```bash
cp .env.example .env
```

2. `.env` 파일을 열고 실제 API 키로 수정:
```
OPENWEATHERMAP_API_KEY=your_actual_api_key_here
```

3. OpenWeatherMap API 키 발급:
   - https://openweathermap.org/api 에서 회원가입
   - API Keys 섹션에서 키 발급

### 2. 의존성 설치

```bash
fvm flutter pub get
```

### 3. 코드 생성 (Freezed)

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

## 실행

```bash
fvm flutter run
```

## 테스트

```bash
fvm flutter test
```

## 기술 스택

- Flutter 3.35.x
- Dart 3.9.x
- Riverpod 3.x (상태 관리)
- Dio 5.x (네트워크)
- Freezed (불변 모델)
- SharedPreferences (로컬 캐시)
- flutter_dotenv (환경 변수)

## 개발 원칙

- TDD (Test-Driven Development)
- 클린 아키텍처
- GO Protocol 준수

