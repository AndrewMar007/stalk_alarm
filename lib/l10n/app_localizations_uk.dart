// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Stalc Alarm';

  @override
  String get settings => 'Налаштування';

  @override
  String get language => 'Мова';

  @override
  String get ongoing => 'триває';

  @override
  String get alarm => 'Тривоги';

  @override
  String get map => 'Мапа';

  @override
  String get useful => 'Корисне';

  @override
  String get regions => 'Регіони';

  @override
  String get selectOblast => 'Область';

  @override
  String get selectRaion => 'Район';

  @override
  String get selectHromada => 'Громади';

  @override
  String get change => 'Змінити';

  @override
  String get psiRadiation => 'Псі-випромінювання';

  @override
  String get abnormalFrequency => 'Аномальна частота';

  @override
  String get units => 'Од';

  @override
  String get frequency => 'кГц';

  @override
  String get alarmVolume => 'Гучність сигналу тривоги';

  @override
  String get level => 'Рівень';

  @override
  String get alarmStart => 'Початок тривоги';

  @override
  String get alarmEnd => 'Кінець тривоги';

  @override
  String get alarmStop => 'Зупинити';

  @override
  String get notifications => 'Сповіщення';

  @override
  String get enabled => 'Увімкнені';

  @override
  String get disabled => 'Вимкнені';

  @override
  String get notificationFunc => 'Тест функцій сповіщень';

  @override
  String get information => 'Інформація';

  @override
  String get infromationAlarmText1 => 'Увага! У вашому регіоні викид!';

  @override
  String get inforomationAlarmText2 => 'Пройдіть в найближче укриття!';

  @override
  String get inforomationAlarmText3 => 'Викиду немає';

  @override
  String get inforomationAlarmText4 => 'Слідкуйте за подальшими оновленнями';

  @override
  String get deleteRegion => 'Видалення регіону';

  @override
  String get deleteRegioDescription =>
      'Ви точно впевнені, що хочете видалити регіон?';

  @override
  String get approve => 'Так';

  @override
  String get cancel => 'Ні';

  @override
  String get wifiTitleTrue => 'З\'єднання встановлене';

  @override
  String get wifiTitleFalse => 'Немає з\'єднання';

  @override
  String get wifiContentTrue => 'Ви можете закрити це вікно';

  @override
  String get wifiContentFalse =>
      'Немає інтернет зʼєднання,\nперевірте налаштування';

  @override
  String get close => 'Закрити';

  @override
  String get radiationLodearText => 'Завантаження даних';

  @override
  String get historyLimit => 'Ліміт історії';

  @override
  String get hitoryTry => 'Спробуйте через';

  @override
  String get seconds => 'с.';

  @override
  String get timerEndTitle => 'Таймер сплинув';

  @override
  String get timerEndDescription => 'Можете спробувати ще раз';

  @override
  String get retry => 'Повторити';

  @override
  String get alarmRunning => 'Active';

  @override
  String get dataState => 'Сьогодні';

  @override
  String get emission => 'Викид';

  @override
  String get minutes => 'хв';

  @override
  String get hour => 'год';
}
