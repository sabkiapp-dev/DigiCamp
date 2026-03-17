import 'package:formz/formz.dart';

class Url extends FormzInput<String?, String> {
  const Url.pure([super.value]) : super.pure();

  const Url.dirty([super.value]) : super.dirty();

  static final _urlRegex = RegExp(r'^(https?|ftp):\/\/[^\s\/$.?#].[^\s]*$');

  @override
  String? validator(String? value) {
    return value != null && _urlRegex.hasMatch(value) ? null : "Invalid url";
  }
}
