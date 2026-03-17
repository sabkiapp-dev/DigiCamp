import 'package:formz/formz.dart';

class Mobile extends FormzInput<String?, String> {
  const Mobile.pure([super.value = '']) : super.pure();

  const Mobile.dirty([super.value = '']) : super.dirty();

  static final _mobileRegex = RegExp(r"^[0-9]{10}$");

  @override
  String? validator(String? value) {
    if (_mobileRegex.hasMatch(value ?? '')) {
      return null;
    }
    return 'Invalid mobile';
  }
}
