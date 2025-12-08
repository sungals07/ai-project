import 'package:equatable/equatable.dart';

/// Failure - 도메인 레이어의 에러 추상 클래스
/// 
/// 모든 도메인 에러는 이 클래스를 상속받아야 합니다.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// ServerFailure - 서버 에러
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// CacheFailure - 캐시 에러
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// NetworkFailure - 네트워크 에러
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

