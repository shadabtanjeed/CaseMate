import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    String? location,
    String? education,
    String? achievements,
    String? licenseId,
    String? specialization,
    int? yearsOfExperience,
    String? bio,
  }) {
    return repository.register(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      phone: phone,
      location: location,
      education: education,
      achievements: achievements,
      licenseId: licenseId,
      specialization: specialization,
      yearsOfExperience: yearsOfExperience,
      bio: bio,
    );
  }
}