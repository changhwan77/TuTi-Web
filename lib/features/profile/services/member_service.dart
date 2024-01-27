import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../common/interceptor.dart';
import '../../../constants/color.dart';
import '../models/member_model.dart';

class MemberService {
  final Dio _dio;
  MemberService(this._dio) {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      baseUrl: baseUrl,
      contentType: 'application/json',
    );
  }

  static const String baseUrl = 'http://52.79.243.200:8080';

  Future<List<MemberModel>> getMembers(BuildContext context) async {
    try {
      final response = await _dio.get('$baseUrl/home');
      if (response.statusCode == 200) {
        final List<dynamic> result = response.data['data']['members'];
        final members = result.map((e) => MemberModel.fromJson(e)).toList();
        return members;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.data['message'].toString(),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: ColorConstants.primaryColor,
            ),
          );
        }
      }
    } catch (e) {
      Logger().e(e.toString());
    }
    return [];
  }
}

final memberServiceProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return MemberService(dio);
});
