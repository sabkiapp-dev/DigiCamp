abstract class StorageKeys {
  StorageKeys._();

  /// [appLanguageCode] shared preference key will store the selected
  /// languageCode
  static const String appLanguageCode = "languageCode";

  /// [appLanguageCode] shared preference key will store the selected
  /// countryCode of selected [appLanguageCode]
  static const String appCountryCode = "countryCode";

  /// [enforcedVersion] is used to get latest version of app from
  /// [FirebaseRemoteConfig]
  static const String enforcedVersion = 'enforced_version';

  /// [shownOnBoardingScreen] is used to check weather the on boarding
  /// has shown or not
  static const String shownOnBoardingScreen = 'shown_on_boarding_screen';
}
