import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/config/router.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/utils/palette.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsProvider,
    required this.authProvider,
  });
  final SettingsProvider settingsProvider;
  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => settingsProvider,
        ),
        ChangeNotifierProvider<NavbarProvider>(
          create: (_) => NavbarProvider(),
        ),
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(),
        ),
        ChangeNotifierProvider<HudProvider>(
          create: (_) => HudProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider,
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return Consumer<HudProvider>(
            builder: (context, hudProvider, child) {
              return MaterialApp.router(
                title: kAppName,
                theme: settingsProvider.lightTheme,
                darkTheme: settingsProvider.darkTheme,
                // themeMode: settingsProvider.themeMode,
                themeMode: ThemeMode.light,
                debugShowCheckedModeBanner: false,
                routerConfig: AppRouter.router,
                builder: (context, child) {
                  return Stack(
                    children: [
                      child!,
                      if (hudProvider.isLoading)
                        AbsorbPointer(
                          child: Align(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Palette.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Palette.shadowColor,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(
                                MediaQuery.of(context).size.height * 0.03,
                              ),
                              width: MediaQuery.of(context).size.height * 0.1,
                              height: MediaQuery.of(context).size.height * 0.1,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
