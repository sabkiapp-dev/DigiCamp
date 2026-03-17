import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

/// Extension for response
extension ResponseExtension on Response {
  /// Checks if the request was success or not
  bool get isSuccess =>
      statusCode == HttpStatus.ok || statusCode == HttpStatus.created;

  /// Decodes the response body and returns
  /// Map<String, dynamic>?
  dynamic get decode => json.decode(utf8.decode(bodyBytes));
}
