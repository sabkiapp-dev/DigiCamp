import 'package:formz/formz.dart';

class Email extends FormzInput<String?, String> {
  const Email.pure() : super.pure('');

  const Email.dirty([super.value = '']) : super.dirty();

  static final _emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  @override
  String? validator(String? value) {
    return _emailRegex.hasMatch(value ?? '') ? null : "Invalid username";
  }
}
