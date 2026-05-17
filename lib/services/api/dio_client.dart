import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();

  factory DioClient() => _instance;

  late final Dio dio;
  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://rukun_app_be.ridhosulistyo1302.workers.dev/api/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.httpClientAdapter = IOHttpClientAdapter()
      ..createHttpClient = () {
        final client = HttpClient();

        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

        return client;
      };

    dio.interceptors.add(
      LogInterceptor(request: true, responseBody: true, error: true),
    );
  }
}
