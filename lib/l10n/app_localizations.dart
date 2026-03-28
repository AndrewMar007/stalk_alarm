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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Stalc Alarm'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'ongoing'**
  String get ongoing;

  /// No description provided for @alarm.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alarm;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @useful.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get useful;

  /// No description provided for @regions.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get regions;

  /// No description provided for @selectOblast.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get selectOblast;

  /// No description provided for @selectRaion.
  ///
  /// In en, this message translates to:
  /// **'Raion'**
  String get selectRaion;

  /// No description provided for @selectHromada.
  ///
  /// In en, this message translates to:
  /// **'Hromada'**
  String get selectHromada;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @psiRadiation.
  ///
  /// In en, this message translates to:
  /// **'Psi-radiation'**
  String get psiRadiation;

  /// No description provided for @abnormalFrequency.
  ///
  /// In en, this message translates to:
  /// **'Abnormal frequency'**
  String get abnormalFrequency;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'u'**
  String get units;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'kHz'**
  String get frequency;

  /// No description provided for @alarmVolume.
  ///
  /// In en, this message translates to:
  /// **'Alarm volume'**
  String get alarmVolume;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @alarmStart.
  ///
  /// In en, this message translates to:
  /// **'Alarm start'**
  String get alarmStart;

  /// No description provided for @alarmEnd.
  ///
  /// In en, this message translates to:
  /// **'Alarm end'**
  String get alarmEnd;

  /// No description provided for @alarmStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get alarmStop;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @notificationFunc.
  ///
  /// In en, this message translates to:
  /// **'Notification functionality test'**
  String get notificationFunc;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @infromationAlarmText1.
  ///
  /// In en, this message translates to:
  /// **'Attention! There is an emission in your region!'**
  String get infromationAlarmText1;

  /// No description provided for @inforomationAlarmText2.
  ///
  /// In en, this message translates to:
  /// **'Go to the nearest shelter!'**
  String get inforomationAlarmText2;

  /// No description provided for @inforomationAlarmText3.
  ///
  /// In en, this message translates to:
  /// **'No emission'**
  String get inforomationAlarmText3;

  /// No description provided for @inforomationAlarmText4.
  ///
  /// In en, this message translates to:
  /// **'Stay tuned for further updates'**
  String get inforomationAlarmText4;

  /// No description provided for @deleteRegion.
  ///
  /// In en, this message translates to:
  /// **'Remove region'**
  String get deleteRegion;

  /// No description provided for @deleteRegioDescription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the region?'**
  String get deleteRegioDescription;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get approve;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get cancel;

  /// No description provided for @wifiTitleTrue.
  ///
  /// In en, this message translates to:
  /// **'Connection established'**
  String get wifiTitleTrue;

  /// No description provided for @wifiTitleFalse.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get wifiTitleFalse;

  /// No description provided for @wifiContentTrue.
  ///
  /// In en, this message translates to:
  /// **'You can close this window'**
  String get wifiContentTrue;

  /// No description provided for @wifiContentFalse.
  ///
  /// In en, this message translates to:
  /// **'There is no internet connection.\n Please check your settings'**
  String get wifiContentFalse;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @radiationLodearText.
  ///
  /// In en, this message translates to:
  /// **'Loading data'**
  String get radiationLodearText;

  /// No description provided for @historyLimit.
  ///
  /// In en, this message translates to:
  /// **'History limit'**
  String get historyLimit;

  /// No description provided for @hitoryTry.
  ///
  /// In en, this message translates to:
  /// **'Try again in'**
  String get hitoryTry;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'s.'**
  String get seconds;

  /// No description provided for @timerEndTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer expired'**
  String get timerEndTitle;

  /// No description provided for @timerEndDescription.
  ///
  /// In en, this message translates to:
  /// **'You can try again'**
  String get timerEndDescription;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get retry;

  /// No description provided for @alarmRunning.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get alarmRunning;

  /// No description provided for @dataState.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dataState;

  /// No description provided for @emission.
  ///
  /// In en, this message translates to:
  /// **'Emission'**
  String get emission;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hour;

  /// No description provided for @error_server.
  ///
  /// In en, this message translates to:
  /// **'Server is not responding\nWe are working to restore service'**
  String get error_server;

  /// No description provided for @error_no_internet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get error_no_internet;

  /// No description provided for @error_rate_limit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Try again later'**
  String get error_rate_limit;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'uk': return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
