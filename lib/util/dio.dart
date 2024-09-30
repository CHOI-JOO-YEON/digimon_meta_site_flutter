import 'package:dio/browser.dart';
import 'package:dio/dio.dart';



typedef AuthErrorCallback = Function();

class DioClient {
  static final DioClient _instance = DioClient._internal();
  Dio _dio = Dio();

  AuthErrorCallback? _onAuthError;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    _dio.options.contentType = "application/json";
    var adapter = BrowserHttpClientAdapter();
    adapter.withCredentials = true;
    _dio.httpClientAdapter = adapter;

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioError error, handler) {
        if (error.response?.statusCode == 401) {
          // 401 에러가 감지되었을 때 콜백 함수 호출
          _onAuthError?.call();

        }
        handler.next(error);
      },
    ));
    // 기타 필요한 Dio 설정
  }

  set onAuthError(AuthErrorCallback callback) {
    _onAuthError = callback;
  }

  Dio get dio => _dio;
}
