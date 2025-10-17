import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/auth_local_datasources.dart';
import '../../data/datasources/auth_remote_datasources.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../domain/usecases/request_password_reset_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_reset_pin_usecase.dart';

// Dependencies
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
      (ref) => AuthLocalDataSourceImpl(),
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
      (ref) => AuthRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
      (ref) => AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  ),
);

// Use cases
final loginUseCaseProvider = Provider<LoginUseCase>(
      (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final registerUseCaseProvider = Provider<RegisterUseCase>(
      (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
      (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>(
      (ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)),
);

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>(
      (ref) => RefreshTokenUseCase(ref.watch(authRepositoryProvider)),
);

final requestPasswordResetUseCaseProvider =
Provider<RequestPasswordResetUseCase>(
      (ref) => RequestPasswordResetUseCase(ref.watch(authRepositoryProvider)),
);

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>(
      (ref) => ResetPasswordUseCase(ref.watch(authRepositoryProvider)),
);

final verifyResetPinUseCaseProvider = Provider<VerifyResetPinUseCase>(
      (ref) => VerifyResetPinUseCase(ref.watch(authRepositoryProvider)),
);

// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth Provider
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final RequestPasswordResetUseCase requestPasswordResetUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final VerifyResetPinUseCase verifyResetPinUseCase;
  final AuthLocalDataSource localDataSource;
  
  Future<void> refreshCurrentUser() async {
  try {
    final user = await getCurrentUserUseCase(); // calls /auth/me
    if (user != null) {
      state = state.copyWith(user: user, isAuthenticated: true);
    }
  } catch (_) {
    // ignore for view-only; you already have error handling elsewhere
  }
}

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.refreshTokenUseCase,
    required this.requestPasswordResetUseCase,
    required this.resetPasswordUseCase,
    required this.verifyResetPinUseCase,
    required this.localDataSource,
  }) : super(AuthState());

  // Initialize auth state on app start
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final isLoggedIn = await localDataSource.isLoggedIn();

      if (isLoggedIn) {
        final user = await getCurrentUserUseCase();

        if (user != null) {
          state = AuthState(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
        } else {
          // Token might be expired, try to refresh
          await _tryRefreshToken();
        }
      } else {
        state = AuthState(isLoading: false);
      }
    } catch (e) {
      state = AuthState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _tryRefreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();

      if (refreshToken != null) {
        await refreshTokenUseCase(refreshToken);
        final user = await getCurrentUserUseCase();

        if (user != null) {
          state = AuthState(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
          return;
        }
      }
    } catch (e) {
      // Refresh failed, clear data
      await logoutUseCase();
    }

    state = AuthState(isLoading: false);
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await loginUseCase(email: email, password: password);
      final user = await getCurrentUserUseCase();

      state = AuthState(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Register
  Future<bool> register({
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
    double? consultationFee,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await registerUseCase(
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
        consultationFee: consultationFee,
      );
      // Do not auto-login after registration. Let UI navigate to Login screen.
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await logoutUseCase();
      state = AuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Request password reset
  Future<bool> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await requestPasswordResetUseCase(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Verify reset PIN
  Future<bool> verifyResetPin({
    required String email,
    required String pin,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await verifyResetPinUseCase(email: email, pin: pin);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await resetPasswordUseCase(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    refreshTokenUseCase: ref.watch(refreshTokenUseCaseProvider),
    requestPasswordResetUseCase: ref.watch(requestPasswordResetUseCaseProvider),
    resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
    verifyResetPinUseCase: ref.watch(verifyResetPinUseCaseProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});
