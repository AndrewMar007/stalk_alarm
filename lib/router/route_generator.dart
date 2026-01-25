import 'package:flutter/material.dart';
import 'package:stalc_alarm/router/router_args_models/hromadas_page_args_model.dart';
import 'package:stalc_alarm/router/router_args_models/oblast_details_page_args_model.dart';
import 'package:stalc_alarm/router/router_args_models/region_info_args_model.dart';
import 'package:stalc_alarm/view/screens/help.dart';
import 'package:stalc_alarm/view/screens/oblast_details_page.dart';
import 'package:stalc_alarm/view/screens/raions/hromadas_page.dart';
import 'package:stalc_alarm/view/screens/raions/oblasts_page.dart';
import 'package:stalc_alarm/view/screens/raions/regions_info_page.dart';
import 'package:stalc_alarm/view/screens/raions/raions_list_page.dart';
import 'package:stalc_alarm/view/screens/raions/raions_page.dart';
import 'package:stalc_alarm/view/screens/settings_page.dart';

import '../models/admin_units.dart';
import '../view/screens/cupertino_bottom_navigation_bar.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      //On app start routes
      // case '/preLoader':
      //   return MaterialPageRoute(builder: (_) => const PreLoaderPage());
      // case '/internetPreLoader':
      //   return MaterialPageRoute(builder: (_) => const InternetPreLoader());
      //! Основні сторінки (main pages of app in CupertinoBottomBar)
      case '/mapScreen':
        return MaterialPageRoute(builder: (_) => const CupertinoBottomBar());
      case '/settingsScreen':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case '/aboutScreen':
        return MaterialPageRoute(builder: (_) => const HelpPage());
      case '/raionsListScreen':
        return MaterialPageRoute(builder: (_) => const RaionsListPage());
      //! Сторінки для вибору регіону (Pages to choose region)
      case '/oblastsScreen':
        return MaterialPageRoute(builder: (_) => const OblastsPage());
      case '/raionsScreen':
        if (args is Oblast) {
          return MaterialPageRoute(builder: (_) => RaionsPage(oblast: args));
        }
        return _errorRoute();
      case '/hromadasScreen':
        if (args is HromadasPageArgs) {
          return MaterialPageRoute(
            builder: (_) =>
                HromadasPage(raion: args.raion, oblast: args.oblast),
          );
        }
        return _errorRoute();
      case '/regionInfoScreen':
        if (args is RegionInfoArgs) {
          return MaterialPageRoute(
            builder: (_) => RaionsInfoPage(
              unit: args.unit,
              isActiveAlarm: args.isActiveAlarm,
            ),
          );
        }
        return _errorRoute();
      //? Сторінка для перегляду історії тривог (натискаємо на областях на мапі)
      //! Page for watch history of alerts by tapping on ragion of map
      case '/oblastDetailsScreen':
        if (args is OblastDetailsPageArgs) {
          return MaterialPageRoute(
            builder: (_) => OblastDetailsPage(id: args.id, title: args.title),
          );
        }
        return _errorRoute();

      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
    //return _errorRoute();
  }

  //! If we don't have route in a tree, show error page
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: Text('Error')),
          body: Center(child: Text('ERROR')),
        );
      },
    );
  }
}
