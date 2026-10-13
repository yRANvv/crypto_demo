import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void applyProxy(Dio dio, String proxy) {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final HttpClient client = HttpClient();
      client.findProxy = (Uri uri) => 'PROXY $proxy';
      return client;
    },
  );
}
