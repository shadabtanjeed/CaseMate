import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<String> call(String refreshToken) {
    return repository.refreshToken(refreshToken);
  }
}