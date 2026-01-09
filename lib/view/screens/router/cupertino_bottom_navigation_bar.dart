import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tabBarHeight = size.height * 0.08;
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

    return Scaffold(
      //backgroundColor: Color.fromARGB(255, 20, 11, 2),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // ===============================
            // ОСНОВНИЙ CupertinoTabScaffold
            // ===============================
            CupertinoTabScaffold(
              // backgroundColor: Color.fromARGB(255, 20, 11, 2),
              resizeToAvoidBottomInset: false,
              tabBar: CupertinoTabBar(
                height: tabBarHeight,
                backgroundColor: const Color.fromARGB(255, 23, 13, 2),

                // ❌ вимикаємо стандартний бордер
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
                        return const MainScreen(); // тут може бути Material Scaffold — ок
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

            // ===============================
            // 🔥 TOP GRADIENT BORDER (над TabBar)
            // ===============================
            Positioned(
              left: 0,
              right: 0,
              bottom: tabBarHeight,
              height: borderWidth,
              child: const DecoratedBox(
                decoration: BoxDecoration(gradient: topGradient),
              ),
            ),

            // ===============================
            // 🔥 BOTTOM GRADIENT BORDER (під TabBar)
            // ===============================
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28),
        SizedBox(height: 5),
        Text(text, style: TextStyle(fontSize: 11)),
      ],
    );
  }
}
