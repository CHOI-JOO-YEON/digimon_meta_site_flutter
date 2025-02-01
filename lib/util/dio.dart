import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

typedef AuthErrorCallback = Function();

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;

  AuthErrorCallback? _onAuthError;

  factory DioClient() => _instance;

  DioClient._internal() {
    _dio = Dio(BaseOptions(
      contentType: "application/json",
    ));

    if (kIsWeb) {
      _dio.httpClientAdapter = makeHttpClientAdapter();
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, handler) {
        if (error.response?.statusCode == 401) {
          _onAuthError?.call();
        }
        return handler.next(error);
      },
    ));
  }

  set onAuthError(AuthErrorCallback callback) {
    _onAuthError = callback;
  }

  Dio get dio => _dio;
}

HttpClientAdapter makeHttpClientAdapter() {
  final adapter = HttpClientAdapter() as BrowserHttpClientAdapter;
  adapter.withCredentials = true;
  return adapter;
}