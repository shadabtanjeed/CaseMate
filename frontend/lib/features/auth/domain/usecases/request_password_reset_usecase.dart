import '../repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  final AuthRepository repository;

  RequestPasswordResetUseCase(this.repository);

  Future<void> call(String email) {
    return repository.requestPasswordReset(email);
  }
}