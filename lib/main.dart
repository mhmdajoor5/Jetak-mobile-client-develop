import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';

import 'generated/l10n.dart';
import 'route_generator.dart';
import 'src/helpers/app_config.dart' as config;
import 'src/helpers/address_helper.dart';
import 'src/models/setting.dart';
import 'src/repository/settings_repository.dart' as settingRepo;
import 'src/repository/user_repository.dart' as userRepo;

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
  
  // You can handle the background message here
  // For example, save it to local storage, update badge count, etc.
  
  // Don't try to update UI here as the app is in background
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("configurations");
  await Firebase.initializeApp();
  
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
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
    
    // تنظيف العناوين المعطوبة عند بدء التطبيق
    AddressHelper.cleanupSavedAddresses();
    
    super.initState();
  }

  String _getFontFamily(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'Titr';
      case 'he':
        return 'VarelaRound';
      default:
        return 'Nunito';
    }
  }

  List<String> _getFontFamilyFallback(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return ['Titr', 'Cairo', 'Nunito'];
      case 'he':
        return ['VarelaRound', 'Nunito'];
      default:
        return ['Nunito', 'Poppins'];
    }
  }

  TextDirection _getTextDirection(String languageCode) {
    return (languageCode == 'ar' || languageCode == 'he')
        ? TextDirection.rtl
        : TextDirection.ltr;
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
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            if (deviceLocale == null) return const Locale('he');
            for (var locale in supportedLocales) {
              if (locale.languageCode == deviceLocale.languageCode) {
                return deviceLocale;
              }
            }
            return const Locale('he');
          },
          theme: ThemeData(useMaterial3: true),
          builder: (context, child) {
            final langCode = Localizations.localeOf(context).languageCode;
            final fontFamily = _getFontFamily(langCode);
            final fontFamilyFallback = _getFontFamilyFallback(langCode);
            final textDirection = _getTextDirection(langCode);
            final isLight = _setting.brightness.value == Brightness.light;

            final baseTheme =
                isLight
                    ? ThemeData(
                      useMaterial3: true,
                      fontFamily: fontFamily,
                      fontFamilyFallback: fontFamilyFallback,
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: config.Colors().mainColor(1),
                        brightness: Brightness.light,
                        primary: Colors.white,
                        secondary: config.Colors().accentColor(1),
                      ),
                      appBarTheme: AppBarTheme(
                        elevation: 0,
                        centerTitle: true,
                        iconTheme: IconThemeData(
                          color: config.Colors().secondColor(1),
                        ),
                        titleTextStyle: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: config.Colors().secondColor(1),
                        ),
                      ),
                      floatingActionButtonTheme:
                          const FloatingActionButtonThemeData(
                            elevation: 0,
                            foregroundColor: Colors.white,
                          ),
                      dividerTheme: DividerThemeData(
                        color: config.Colors().accentColor(0.1),
                      ),
                      focusColor: config.Colors().accentColor(1),
                      hintColor: config.Colors().secondColor(1),
                      textTheme: TextTheme(
                        displayLarge: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        displayMedium: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        displaySmall: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        headlineLarge: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        headlineMedium: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback, fontSize: 18.0, fontWeight: FontWeight.w600, height: 1.35),
                        headlineSmall: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback, fontSize: 20.0, height: 1.35, fontWeight: FontWeight.w600),
                        titleLarge: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        titleMedium: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        titleSmall: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        bodyLarge: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback, fontSize: 14.0, fontWeight: FontWeight.w400, height: 1.5),
                        bodyMedium: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback, fontSize: 14.0, fontWeight: FontWeight.w400, height: 1.5),
                        bodySmall: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback, fontSize: 12.0, fontWeight: FontWeight.w400, height: 1.5),
                        labelLarge: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        labelMedium: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        labelSmall: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                      ).apply(
                        bodyColor: config.Colors().secondColor(1),
                        displayColor: config.Colors().secondColor(1),
                      ),
                    )
                    : ThemeData(
                      useMaterial3: true,
                      fontFamily: fontFamily,
                      fontFamilyFallback: fontFamilyFallback,
                      brightness: Brightness.dark,
                      scaffoldBackgroundColor: const Color(0xFF2C2C2C),
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: config.Colors().mainDarkColor(1),
                        brightness: Brightness.dark,
                        primary: const Color(0xFF252525),
                        secondary: config.Colors().accentDarkColor(1),
                      ),
                      appBarTheme: AppBarTheme(
                        elevation: 0,
                        centerTitle: true,
                        iconTheme: const IconThemeData(color: Colors.white),
                        titleTextStyle: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      dividerTheme: DividerThemeData(
                        color: config.Colors().accentColor(0.1),
                      ),
                      textTheme: TextTheme(
                        displayLarge: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        displayMedium: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        displaySmall: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        headlineLarge: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        headlineMedium: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback, fontSize: 18.0, fontWeight: FontWeight.w600, height: 1.35),
                        headlineSmall: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback, fontSize: 20.0, height: 1.35, fontWeight: FontWeight.w600),
                        titleLarge: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        titleMedium: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        titleSmall: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        bodyLarge: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback, fontSize: 14.0, fontWeight: FontWeight.w400, height: 1.5),
                        bodyMedium: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback, fontSize: 14.0, fontWeight: FontWeight.w400, height: 1.5),
                        bodySmall: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback, fontSize: 12.0, fontWeight: FontWeight.w400, height: 1.5),
                        labelLarge: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        labelMedium: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                        labelSmall: TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
                      ).apply(
                        bodyColor: config.Colors().secondDarkColor(1),
                        displayColor: config.Colors().secondDarkColor(1),
                      ),
                      hintColor: config.Colors().secondDarkColor(1),
                      focusColor: config.Colors().accentDarkColor(1),
                    );

            return Directionality(
              textDirection: textDirection,
              child: Theme(
                data: baseTheme,
                child: Material(
                  type: MaterialType.transparency,
                  child: child!,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

TextDirection _getTextDirection(String languageCode) {
  if (languageCode == 'ar' || languageCode == 'he') {
    return TextDirection.rtl;
  } else {
    return TextDirection.ltr;
  }
}
