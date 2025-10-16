import '../repositories/auth_repository.dart';

class VerifyResetPinUseCase {
  final AuthRepository repository;

  VerifyResetPinUseCase(this.repository);

  Future<void> call({
    required String email,
    required String pin,
  }) {
    return repository.verifyResetPin(email: email, pin: pin);
  }
}