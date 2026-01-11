import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stalc_alarm/view/screens/help.dart';
import 'package:stalc_alarm/view/screens/main_screen.dart';
import 'package:stalc_alarm/view/screens/raions/raions_list_page.dart';
import 'package:stalc_alarm/view/screens/settings_page.dart';

class CupertinoBottomBar extends StatefulWidget {
  const CupertinoBottomBar({super.key});

  @override
  State<CupertinoBottomBar> createState() => _CupertinoBottomBarState();
}

class _CupertinoBottomBarState extends State<CupertinoBottomBar> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black, // Android only
        statusBarIconBrightness: Brightness.light, // Android іконки
        statusBarBrightness: Brightness.dark, // iOS: light icons

        systemNavigationBarColor: Color.fromARGB(255, 23, 13, 2),
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }
  @override
Widget build(BuildContext context) {
  final media = MediaQuery.of(context);
  final safeBottom = media.padding.bottom; // iPhone home indicator / Android gesture
  final w = media.size.width;

  // Стабільна висота таббара (не від height екрана)
  final baseTabBarHeight = (kBottomNavigationBarHeight + (w < 360 ? 6 : 10))
      .clamp(52.0, 72.0);

  const borderWidth = 2.0;

  const topGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.fromARGB(72, 232, 136, 27),
      Color.fromARGB(255, 23, 13, 2),
      Color.fromARGB(255, 23, 13, 2),
      Color.fromARGB(66, 232, 136, 27),
    ],
    stops: [0.01, 0.35, 0.75, 1.0],
  );

  const bottomGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.fromARGB(72, 232, 136, 27),
      Color.fromARGB(255, 23, 13, 2),
      Color.fromARGB(255, 23, 13, 2),
      Color.fromARGB(66, 232, 136, 27),
    ],
    stops: [0.1, 0.45, 0.8, 1.0],
  );

  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color.fromARGB(255, 23, 13, 2),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Color.fromARGB(0, 0, 0, 0),
    ),
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CupertinoTabScaffold(
            resizeToAvoidBottomInset: false,
            tabBar: CupertinoTabBar(
              height: baseTabBarHeight,
              backgroundColor: const Color.fromARGB(255, 23, 13, 2),
              activeColor: const Color.fromARGB(255, 249, 162, 56),
              inactiveColor: const Color.fromARGB(255, 206, 113, 42),
              items: const [
                BottomNavigationBarItem(
                  icon: BottomBarItem(icon: Icons.map, text: "Мапа"),
                  activeIcon: BottomBarItem(icon: Icons.map, text: "Мапа"),
                ),
                BottomNavigationBarItem(
                  icon: BottomBarItem(
                    icon: Icons.crisis_alert_outlined,
                    text: "Тривоги",
                  ),
                  activeIcon: BottomBarItem(
                    icon: Icons.crisis_alert_outlined,
                    text: "Тривоги",
                  ),
                ),
                BottomNavigationBarItem(
                  icon: BottomBarItem(
                    icon: Icons.info_outline_rounded,
                    text: "Корисне",
                  ),
                  activeIcon: BottomBarItem(
                    icon: Icons.info_outline_rounded,
                    text: "Корисне",
                  ),
                ),
                BottomNavigationBarItem(
                  icon: BottomBarItem(
                    icon: Icons.settings_outlined,
                    text: "Налаштування",
                  ),
                  activeIcon: BottomBarItem(
                    icon: Icons.settings_outlined,
                    text: "Налаштування",
                  ),
                ),
              ],
            ),
            tabBuilder: (context, index) {
              return CupertinoTabView(
                builder: (context) {
                  switch (index) {
                    case 0:
                      return const MainScreen();
                    case 1:
                      return const RaionsListPage();
                    case 2:
                      return const HelpPage();
                    default:
                      return const SettingsPage();
                  }
                },
              );
            },
          ),

          // 🔥 верхній бордер: прямо над таббаром
          Positioned(
            left: 0,
            right: 0,
            bottom: safeBottom + baseTabBarHeight,
            height: borderWidth,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: topGradient),
            ),
          ),

          // 🔥 нижній бордер: по самому низу (над safe area)
          Positioned(
            left: 0,
            right: 0,
            bottom: safeBottom,
            height: borderWidth,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: bottomGradient),
            ),
          ),
        ],
      ),
    ),
  );
}

}

class BottomBarItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const BottomBarItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final iconSize = w < 360 ? 24.0 : 28.0;
    final fontSize = w < 360 ? 10.0 : 11.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize),
        const SizedBox(height: 4),
        // щоб текст не “виштовхував” верстку
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(text, style: TextStyle(fontSize: fontSize)),
        ),
      ],
    );
  }
}

