// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Stalc Alarm';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get ongoing => 'ongoing';

  @override
  String get alarm => 'Alerts';

  @override
  String get map => 'Map';

  @override
  String get useful => 'Information';

  @override
  String get regions => 'Regions';

  @override
  String get selectOblast => 'Region';

  @override
  String get selectRaion => 'Raion';

  @override
  String get selectHromada => 'Hromada';

  @override
  String get change => 'Change';

  @override
  String get psiRadiation => 'Psi-radiation';

  @override
  String get abnormalFrequency => 'Abnormal frequency';

  @override
  String get units => 'u';

  @override
  String get frequency => 'kHz';

  @override
  String get alarmVolume => 'Alarm volume';

  @override
  String get level => 'Level';

  @override
  String get alarmStart => 'Alarm start';

  @override
  String get alarmEnd => 'Alarm end';

  @override
  String get alarmStop => 'Stop';

  @override
  String get notifications => 'Notifications';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get notificationFunc => 'Notification functionality test';

  @override
  String get information => 'Information';

  @override
  String get infromationAlarmText1 => 'Attention! There is an emission in your region!';

  @override
  String get inforomationAlarmText2 => 'Go to the nearest shelter!';

  @override
  String get inforomationAlarmText3 => 'No emission';

  @override
  String get inforomationAlarmText4 => 'Stay tuned for further updates';

  @override
  String get deleteRegion => 'Remove region';

  @override
  String get deleteRegioDescription => 'Are you sure you want to remove the region?';

  @override
  String get approve => 'Yes';

  @override
  String get cancel => 'No';

  @override
  String get wifiTitleTrue => 'Connection established';

  @override
  String get wifiTitleFalse => 'No connection';

  @override
  String get wifiContentTrue => 'You can close this window';

  @override
  String get wifiContentFalse => 'There is no internet connection.\n Please check your settings';

  @override
  String get close => 'Close';

  @override
  String get radiationLodearText => 'Loading data';

  @override
  String get historyLimit => 'History limit';

  @override
  String get hitoryTry => 'Try again in';

  @override
  String get seconds => 's.';

  @override
  String get timerEndTitle => 'Timer expired';

  @override
  String get timerEndDescription => 'You can try again';

  @override
  String get retry => 'Tap to retry';

  @override
  String get alarmRunning => 'Active';

  @override
  String get dataState => 'Today';

  @override
  String get emission => 'Emission';

  @override
  String get minutes => 'min';

  @override
  String get hour => 'h';

  @override
  String get error_server => 'Server is not responding\nWe are working to restore service';

  @override
  String get error_no_internet => 'No internet connection';

  @override
  String get error_rate_limit => 'Too many requests. Try again later';
}
