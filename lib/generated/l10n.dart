// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escape_characters

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

import 'l10n/app_localizations.dart';

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {};

Future<dynamic> loadLibrary(String localeName) {
  return _deferredLibraries[localeName]?.call() ?? Future.value(null);
}

class S {
  S._();
  
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en', ''),
    Locale('ar', ''),
    Locale('he', ''),
  ];
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale('en', ''),
      Locale('ar', ''),
      Locale('he', ''),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale, supportedLocales, (_, __) => true);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;

  bool _isSupported(Locale locale, List<Locale> supportedLocales, bool Function(String?, String?) test) {
    for (final supportedLocale in supportedLocales) {
      if (test(locale.languageCode, supportedLocale.languageCode) &&
          test(locale.countryCode, supportedLocale.countryCode)) {
        return true;
      }
    }
    return false;
  }
} 