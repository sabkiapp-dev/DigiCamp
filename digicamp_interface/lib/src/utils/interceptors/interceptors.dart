import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';

/// Signature for the authentication token provider.
typedef UnauthorizedAccess = void Function();

class AppInterceptor implements InterceptorContract {
  AppInterceptor({
    required this.unauthorizedAccess,
  });

  final UnauthorizedAccess unauthorizedAccess;

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final method = request.method;
    final url = request.url.toString();
    final headers = request.headers;
    var curl = '';
    curl += 'curl';
    curl += ' -v';
    curl += ' -X $method';
    headers.forEach((k, v) {
      curl += " -H '$k: $v'";
    });
    if (request is Request) {
      final body = request.body;
      if (body.isNotEmpty) {
        curl += " -d '$body'";
      }
    }
    // this is fairly naive, but it should cover most cases

    curl += ' "$url"';

    debugPrint("\x1B[33m[Request] $curl\x1B[33m");

    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    if (response is Response) {
      debugPrint("\x1B[32m[Response] ${response.body}\x1B[32m");
    }
    if (response.statusCode == HttpStatus.unauthorized) {
      unauthorizedAccess();
    }
    return response;
  }

  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => true;
}
