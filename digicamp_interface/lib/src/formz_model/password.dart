import 'package:formz/formz.dart';

/// Eg. gaurav1g
class Password extends FormzInput<String?, String> {
  const Password.pure() : super.pure('');

  const Password.dirty([super.value = '']) : super.dirty();

  // static final _passwordRegex =
  //     RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  @override
  String? validator(String? value) {
    return value != null && value.isNotEmpty ? null : "Invalid Password";
    // return _passwordRegex.hasMatch(value ?? '') ? null : "Invalid Password";
  }
}
