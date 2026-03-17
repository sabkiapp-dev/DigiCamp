import 'package:formz/formz.dart';

class Name extends FormzInput<String?, String> {
  const Name.pure([super.value]) : super.pure();

  const Name.dirty([super.value]) : super.dirty();

  static final _nameRegex = RegExp(r'^[a-zA-Z\s]{3,35}$');

  @override
  String? validator(String? value) {
    return value != null && _nameRegex.hasMatch(value) ? null : "Invalid name";
  }
}
