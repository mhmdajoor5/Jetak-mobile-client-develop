import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';

import 'generated/l10n.dart';
import 'route_generator.dart';
import 'src/helpers/app_config.dart' as config;
import 'src/helpers/custom_trace.dart';
import 'src/models/setting.dart';
import 'src/repository/settings_repository.dart' as settingRepo;
import 'src/repository/user_repository.dart' as userRepo;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("configurations");
  await Firebase.initializeApp();
  // print(CustomTrace(StackTrace.current, message: "base_url: ${GlobalConfiguration().getValue('base_url')}"));
  // print(CustomTrace(StackTrace.current, message: "api_base_url: ${GlobalConfiguration().getValue('api_base_url')}"));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    settingRepo.initSettings();
    settingRepo.getCurrentLocation();
    userRepo.getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: settingRepo.setting,
      builder: (context, Setting _setting, _) {
        return MaterialApp(
          navigatorKey: settingRepo.navigatorKey,
          title: _setting.appName,
          initialRoute: '/Splash',
          onGenerateRoute: RouteGenerator.generateRoute,
          debugShowCheckedModeBanner: false,
          // locale: _setting.mobileLanguage.value,
          locale: Locale("en"),
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          theme:
              _setting.brightness.value == Brightness.light
                  ? ThemeData(
                    useMaterial3: true,
                    fontFamily: 'Cairo',
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: config.Colors().mainColor(1),
                      brightness: Brightness.light,
                      primary: Colors.white,
                      secondary: config.Colors().accentColor(1),
                    ),
                    floatingActionButtonTheme:
                        const FloatingActionButtonThemeData(
                          elevation: 0,
                          foregroundColor: Colors.white,
                        ),
                    dividerTheme: DividerThemeData(
                      color: config.Colors().accentColor(0.1),
                    ),
                    focusColor: config.Colors().accentColor(
                      1,
                    ), // Optional, not in ThemeData anymore
                    hintColor: config.Colors().secondColor(
                      1,
                    ), // Consider using inputDecorationTheme instead
                    textTheme: const TextTheme(
                      // You had repeated headlineSmall; we keep one and rename appropriately
                      headlineSmall: TextStyle(
                        fontSize: 20.0,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                      headlineMedium: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      headlineLarge: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                      titleLarge: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                      ),
                      titleMedium: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                      bodySmall: TextStyle(fontSize: 12.0, height: 1.35),
                      bodyLarge: TextStyle(fontSize: 14.0, height: 1.35),
                      labelSmall: TextStyle(fontSize: 12.0, height: 1.35),
                    ).apply(
                      bodyColor: config.Colors().secondColor(1),
                      displayColor: config.Colors().secondColor(1),
                    ),
                  )
                  : ThemeData(
                    useMaterial3: true,
                    brightness: Brightness.dark,
                    fontFamily: 'Cairo',
                    scaffoldBackgroundColor: const Color(0xFF2C2C2C),

                    colorScheme: ColorScheme.fromSeed(
                      seedColor: config.Colors().mainDarkColor(1),
                      brightness: Brightness.dark,
                      primary: const Color(0xFF252525),
                      secondary: config.Colors().accentDarkColor(1),
                    ),

                    dividerTheme: DividerThemeData(
                      color: config.Colors().accentColor(0.1),
                    ),

                    textTheme: const TextTheme(
                      headlineSmall: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      headlineMedium: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      headlineLarge: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                      titleLarge: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                      ),
                      titleMedium: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                      titleSmall: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      bodySmall: TextStyle(fontSize: 12.0, height: 1.35),
                      bodyLarge: TextStyle(fontSize: 14.0, height: 1.35),
                      labelSmall: TextStyle(fontSize: 12.0, height: 1.35),
                    ).apply(
                      bodyColor: config.Colors().secondDarkColor(1),
                      displayColor: config.Colors().secondDarkColor(1),
                    ),

                    // Optional: you may move hintColor & focusColor into inputDecorationTheme or directly use them in widget styles.
                    hintColor: config.Colors().secondDarkColor(1),
                    focusColor: config.Colors().accentDarkColor(1),
                  ),
        );
      },
    );
  }
}
