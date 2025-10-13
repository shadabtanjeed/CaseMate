import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/storage_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();

  Future<void> clearAllData();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
      : secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await secureStorage.write(
      key: StorageConstants.accessToken,
      value: accessToken,
    );
    await secureStorage.write(
      key: StorageConstants.refreshToken,
      value: refreshToken,
    );
    await secureStorage.write(
      key: StorageConstants.isLoggedIn,
      value: 'true',
    );
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: StorageConstants.accessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: StorageConstants.refreshToken);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await secureStorage.write(
      key: StorageConstants.userData,
      value: userJson,
    );
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = await secureStorage.read(key: StorageConstants.userData);
    if (userJson == null) return null;

    final userMap = jsonDecode(userJson) as Map<String, dynamic>;
    return UserModel.fromJson(userMap);
  }

  @override
  Future<void> clearAllData() async {
    await secureStorage.deleteAll();
  }

  @override
  Future<bool> isLoggedIn() async {
    final isLoggedIn = await secureStorage.read(key: StorageConstants.isLoggedIn);
    return isLoggedIn == 'true';
  }
}