import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:tuti/features/auth/models/user_profile_model.dart';

import '../../../common/custom_interceptor.dart';
import '../../../common/http_error_handler.dart';
import '../../../common/token_manager.dart';
import '../../../constants/string.dart';

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      final response = await _dio.post(
        '${StringConstants.baseUrl}/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      if (response.data['code'] == 200) {
        final accessToken = response.data['data']['accessToken'];
        if (kIsWeb) {
          await TokenManager.saveToken(accessToken);
        } else {
          const storage = FlutterSecureStorage();
          await storage.write(key: 'accessToken', value: accessToken);
        }
        if (context.mounted) {
          context.go('/tuti');
        }
      } else {
        if (context.mounted) {
          HttpErrorHandler(context, response.data).handleResponse();
        }
      }
    } catch (e) {
      Logger().e("login error : ${e.toString()}");
    }
  }

  // 회원가입
  Future<void> signUp(
      BuildContext context, UserProfileModel userProfileModel) async {
    try {
      final response = await _dio.post(
        '${StringConstants.baseUrl}/join/user',
        data: userProfileModel.toJson(),
      );
      if (response.data['code'] == 200) {
        if (context.mounted) {
          await login(
              context, userProfileModel.email, userProfileModel.password);
        }
      } else {
        if (context.mounted) {
          HttpErrorHandler(context, response.data).handleResponse();
        }
      }
    } catch (e) {
      Logger().e("signUp error : ${e.toString()}");
    }
  }
}

final authServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});
