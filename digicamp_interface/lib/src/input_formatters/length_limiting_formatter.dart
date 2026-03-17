import 'package:flutter/services.dart';

class LengthLimitingFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length <= 320) {
      return newValue;
    } else {
      return oldValue;
    }
  }
}
