import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In uk, this message translates to:
  /// **'Stalc Alarm'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In uk, this message translates to:
  /// **'Мова'**
  String get language;

  /// No description provided for @ongoing.
  ///
  /// In uk, this message translates to:
  /// **'триває'**
  String get ongoing;

  /// No description provided for @alarm.
  ///
  /// In uk, this message translates to:
  /// **'Тривоги'**
  String get alarm;

  /// No description provided for @map.
  ///
  /// In uk, this message translates to:
  /// **'Мапа'**
  String get map;

  /// No description provided for @useful.
  ///
  /// In uk, this message translates to:
  /// **'Корисне'**
  String get useful;

  /// No description provided for @regions.
  ///
  /// In uk, this message translates to:
  /// **'Регіони'**
  String get regions;

  /// No description provided for @selectOblast.
  ///
  /// In uk, this message translates to:
  /// **'Область'**
  String get selectOblast;

  /// No description provided for @selectRaion.
  ///
  /// In uk, this message translates to:
  /// **'Район'**
  String get selectRaion;

  /// No description provided for @selectHromada.
  ///
  /// In uk, this message translates to:
  /// **'Громади'**
  String get selectHromada;

  /// No description provided for @change.
  ///
  /// In uk, this message translates to:
  /// **'Змінити'**
  String get change;

  /// No description provided for @psiRadiation.
  ///
  /// In uk, this message translates to:
  /// **'Псі-випромінювання'**
  String get psiRadiation;

  /// No description provided for @abnormalFrequency.
  ///
  /// In uk, this message translates to:
  /// **'Аномальна частота'**
  String get abnormalFrequency;

  /// No description provided for @units.
  ///
  /// In uk, this message translates to:
  /// **'Од'**
  String get units;

  /// No description provided for @frequency.
  ///
  /// In uk, this message translates to:
  /// **'кГц'**
  String get frequency;

  /// No description provided for @alarmVolume.
  ///
  /// In uk, this message translates to:
  /// **'Гучність сигналу тривоги'**
  String get alarmVolume;

  /// No description provided for @level.
  ///
  /// In uk, this message translates to:
  /// **'Рівень'**
  String get level;

  /// No description provided for @alarmStart.
  ///
  /// In uk, this message translates to:
  /// **'Початок тривоги'**
  String get alarmStart;

  /// No description provided for @alarmEnd.
  ///
  /// In uk, this message translates to:
  /// **'Кінець тривоги'**
  String get alarmEnd;

  /// No description provided for @alarmStop.
  ///
  /// In uk, this message translates to:
  /// **'Зупинити'**
  String get alarmStop;

  /// No description provided for @notifications.
  ///
  /// In uk, this message translates to:
  /// **'Сповіщення'**
  String get notifications;

  /// No description provided for @enabled.
  ///
  /// In uk, this message translates to:
  /// **'Увімкнені'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In uk, this message translates to:
  /// **'Вимкнені'**
  String get disabled;

  /// No description provided for @notificationFunc.
  ///
  /// In uk, this message translates to:
  /// **'Тест функцій сповіщень'**
  String get notificationFunc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
