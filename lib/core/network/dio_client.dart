import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();

  late Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://rukun_app_be.ridhosulistyo1302.workers.dev/api/v1',
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}