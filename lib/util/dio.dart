import 'package:dio/dio.dart';
import 'dart:html' as html;
class DioClient {
  final Dio _dio = Dio();

  DioClient() {
    _dio.options.contentType = "application/json";
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // JWT 토큰을 요청 헤더에 추가
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 응답 처리
        return handler.next(response);
      },
      onError: (DioException dioException, handler) async {
        if (dioException.response?.statusCode == 401) {
          // 401 응답 처리

        }
        return handler.next(dioException);
      },
    ));
  }



  Dio get dio => _dio;
}
Future<String?> getToken() async {
  return html.window.localStorage['access-token'];
}

