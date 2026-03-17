import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:digicamp_interface/app.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/adapters/adapters.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/utils/interceptors/interceptors.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

Future<void> main() async {
  // runZonedGuarded(() async {
  //   WidgetsFlutterBinding.ensureInitialized();

  //   await initHive();
  //   setPathUrlStrategy();

  //   final settingsProvider = await SettingsProvider.instance();
  //   final navbarProvider = await NavbarProvider.instance();
  //   runApp(MyApp(
  //     settingsProvider: settingsProvider,
  //     navbarProvider: navbarProvider,
  //   ));
  // }, (error, stack) {
  //   print("Error");
  //   print(error);
  //   print(stack);
  // });

  WidgetsFlutterBinding.ensureInitialized();

  await initHive();
  usePathUrlStrategy();

  final authProvider = await AuthProvider.instance();

  final client = InterceptedClient.build(
    interceptors: [
      AppInterceptor(
        unauthorizedAccess: authProvider.unauthorizedAccess,
      ),
    ],
    requestTimeout: const Duration(minutes: 10),
  );

  // Use localhost for local development, asterisk.sabkiapp.com for production
  final apiClient = ApiClient(
    baseUrl: const String.fromEnvironment('API_URL', defaultValue: "localhost:8090"),
    tokenProvider: authProvider.tokenProvider,
    httpClient: client,
  );

  authProvider.client = apiClient;

  final settingsProvider = await SettingsProvider.instance();

  initializeDependency(client: apiClient);

  runApp(MyApp(
    settingsProvider: settingsProvider,
    authProvider: authProvider,
  ));
}

/// Initialize hive and register hive adapters
Future<void> initHive() async {
  await Hive.initFlutter();

  Hive
    ..registerAdapter<SettingsProvider>(SettingsProviderAdapter())
    ..registerAdapter<AuthProvider>(AuthProviderAdapter())
    ..registerAdapter(LocaleAdapter())
    ..registerAdapter(ThemeModeAdapter());

  await Hive.openBox<SettingsProvider>(kSettingBox);
  await Hive.openBox<AuthProvider>(kAuthBox);
}
