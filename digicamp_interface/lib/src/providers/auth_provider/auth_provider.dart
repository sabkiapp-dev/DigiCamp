import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:hive/hive.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/formz_model/formz_model.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

part 'auth_provider.g.dart';

@HiveType(typeId: 3)
class AuthProvider extends ChangeNotifier with HiveObjectMixin {
  /// Map key to get access of current object
  static const String _key = "authData";

  late final ApiClient _client;

  set client(ApiClient client) => _client = client;

  static Future<AuthProvider> instance() async {
    final settingsBox = await Hive.openBox<AuthProvider>(kAuthBox);
    final settingsData = settingsBox.get(_key);
    if (settingsData == null) {
      await settingsBox.put(_key, AuthProvider());
    }
    return settingsBox.get(_key)!;
  }

  Name _name = const Name.dirty();
  Mobile _mobile = const Mobile.dirty();
  Password _password = const Password.dirty();
  Password _confirmPassword = const Password.dirty();
  bool _isLoading = false;
  String? _message;
  bool _isUnauthenticated = false;

  Name get name => _name;
  Mobile get mobile => _mobile;
  Password get password => _password;
  Password get confirmPassword => _confirmPassword;
  String? get message => _message;
  bool get isLoading => _isLoading;

  @HiveField(0)
  String? _token;

  String? get token => _token;

  @HiveField(1)
  String? _superUserToken;

  String? get superUserToken => _superUserToken;

  @HiveField(2)
  bool _isSuperuser = false;

  @HiveField(3)
  String? _userName;

  bool get isSuperuser => _isSuperuser;
  bool get isAuthenticated => _token != null;
  bool get hasSuperuser => _superUserToken != null;
  String? get userName => _userName;
  bool get isUnauthenticated => _isUnauthenticated;

  Future<void> _saveToken({
    required String token,
    required bool isSuperuser,
  }) async {
    _token = token;
    _isSuperuser = isSuperuser;
    _isUnauthenticated = false;
    notifyListeners();
    await save();
  }

  void logout() {
    _token = null;
    _isSuperuser = false;
    notifyListeners();
    save();
  }

  /// Token provider for Request header
  Future<String?> tokenProvider() async {
    return _token;
  }

  Future<bool> loginUser(int userId) async {
    final response = await _client.getUserToken(userId: userId);
    if (response.isSuccess) {
      _superUserToken = _token;
      _token = response.data!.$1;
      _userName = response.data!.$2;
      _isSuperuser = false;
      _isUnauthenticated = false;
      notifyListeners();
      await save();
      return true;
    }
    return false;
  }

  Future<void> logoutUser() async {
    _token = _superUserToken;
    _superUserToken = null;
    _isSuperuser = true;
    _userName = null;
    notifyListeners();
    await save();
  }

  void unauthorizedAccess() {
    _isUnauthenticated = true;
    _token = null;
    _isSuperuser = false;
    notifyListeners();
    save();
  }

  void onNameChanged(String value) {
    final name = Name.dirty(value);
    if (name.isValid) {
      _name = name;
    } else {
      _name = Name.dirty(value);
    }
  }

  void onMobileChange(String value) {
    final mobile = Mobile.dirty(value);
    if (mobile.isValid) {
      _mobile = mobile;
    } else {
      _mobile = Mobile.dirty(value);
    }
  }

  void onPasswordChanged(String value) {
    final password = Password.dirty(value);
    if (password.isValid) {
      _password = password;
    } else {
      _password = Password.dirty(value);
    }
  }

  void onConfirmPasswordChanged(String value) {
    final password = Password.dirty(value);
    if (password.isValid) {
      _confirmPassword = password;
    } else {
      _confirmPassword = Password.dirty(value);
    }
  }

  Future<bool> signIn() async {
    _message = null;
    _isLoading = true;
    notifyListeners();
    final valid = Formz.validate([
      _mobile,
      _password,
    ]);
    if (!valid) {
      _isLoading = false;
      _message = "Enter valid Phone number and Password";
      notifyListeners();
      return false;
    }
    final response = await _client.signIn(
      mobileNumber: _mobile.value!,
      password: _password.value!,
    );
    _isLoading = false;
    notifyListeners();
    if (response.isSuccess) {
      _message = "Logged in successfully";
      await _saveToken(
        token: response.data!.accessToken!,
        isSuperuser: response.data!.isSuperuser!,
      );
      clearInputs();
      return true;
    } else {
      _message = response.message;
      return false;
    }
  }

  Future<bool> createUser() async {
    _message = null;
    _isLoading = true;
    notifyListeners();
    final valid = Formz.validate([
      _name,
      _mobile,
      _password,
      _confirmPassword,
    ]);
    if (!_name.isValid) {
      _isLoading = false;
      _message = "Enter valid name";
      notifyListeners();
      return false;
    }
    if (!_mobile.isValid) {
      _isLoading = false;
      _message = "Enter valid Phone number";
      notifyListeners();
      return false;
    }
    if (!_password.isValid) {
      _isLoading = false;
      _message = "Enter valid Password";
      notifyListeners();
      return false;
    }
    if (!_confirmPassword.isValid) {
      _isLoading = false;
      _message = "Enter valid Password";
      notifyListeners();
      return false;
    }

    if (!valid) {
      _isLoading = false;
      _message = "Enter valid inputs";
      notifyListeners();
      return false;
    }

    if (_password.value != _confirmPassword.value) {
      _isLoading = false;
      _message = "Password does not matched";
      notifyListeners();
      return false;
    }

    final response = await _client.createUser(
      name: _name.value!,
      mobileNumber: _mobile.value!,
      password: _password.value!,
    );
    notifyListeners();
    if (response.isSuccess) {
      _message = response.message;
      clearInputs();
      return true;
    } else {
      _message = response.message;
      return false;
    }
  }

  void clearInputs() {
    _name = const Name.dirty();
    _mobile = const Mobile.dirty();
    _password = const Password.dirty();
    _confirmPassword = const Password.dirty();
  }
}
