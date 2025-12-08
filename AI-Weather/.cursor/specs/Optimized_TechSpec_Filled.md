# Optimized TechSpec for Flutter Weather App

## 1. 프로젝트 개요
Flutter 기반의 날씨 앱을 Cursor AI의 TDD 기반 개발 워크플로우(GO Protocol)로 구현하기 위한 최적화된 TechSpec 문서입니다.  
API 기반 현재 날씨/7일 예보/즐겨찾기/캐시/오프라인 지원을 포함합니다.

## 2. 프로젝트 구조
(전체 구조 — 상세 내용은 이전 응답 내용 그대로 포함)
- features/weather (domain/data/presentation)
- core/utils
- services
- Riverpod 상태관리
- Dio 네트워크 레이어
- Freezed 모델 구조

## 3. 사용 기술
- Flutter 3.35.x
- Dart 3.9.x
- Riverpod 3.x
- Dio 5.x
- Freezed / json_serializable
- SharedPreferences 또는 Hive
- Testing: flutter_test, mocktail, integration_test

## 4. 도메인 모델 & 레포지토리 시그니처
- Weather Entity
- WeatherModel (freezed)
- RemoteDatasource / LocalDatasource
- WeatherRepository (fetchByCity, fetchByLocation, forecast, cache)

## 5. 테스트 전략
- Unit Test
- Widget Test
- Integration Test
- 모든 기능은 RED → GREEN → REFACTOR
- 테스트 이름 규칙 포함

## 6. UI/UX Requirements
- HomePage: 검색창 / 현재 날씨 / 즐겨찾기 / 예보 표시
- Error UI, Loading UI
- 오프라인 시 마지막 캐시 표시

## 7. 캐시 전략
- SharedPreferences 또는 Hive 사용
- timestamp 기반 신선도 판단
- 캐시 → 네트워크 순으로 UI 업데이트

## 8. 네트워크 전략
- Dio Interceptor
- Timeout / Retry(max 3)
- CancelToken

## 9. 파일 구조 규칙 / 명명 규칙
- snake_case
- Notifier 이름: XxxNotifier
- 모델 이름: XxxModel
- 기능별 디렉토리 강제

## 10. 코드 자동화 / CI
- GitHub Actions: analyze, test, build
