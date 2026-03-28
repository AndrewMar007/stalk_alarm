import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stalc_alarm/view/screens/rules_page.dart';

const bottomGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(72, 232, 136, 27),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(66, 232, 136, 27),
  ],
  stops: [0.02, 0.4, 0.8, 1.0],
);

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 11, 2),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 11, 2),
        centerTitle: true,

        title: Text(
          "Інформація",
          style: const TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: 2,
            width: double.infinity,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: bottomGradient),
            ),
          ),
          const Positioned(
            left: -50,
            right: -50,
            top: -50,
            bottom: -50,
            child: Image(
              image: AssetImage("assets/back.png"),
              color: Color.fromARGB(32, 41, 41, 41),
            ),
          ),
          const Positioned(
            left: -350,
            right: -350,
            bottom: -250,
            top: -100,
            child: Image(
              image: AssetImage("assets/radiation.png"),
              color: Color.fromARGB(15, 54, 27, 6),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              double mW = constraints.maxWidth * 0.13;
              double mH = constraints.maxHeight * 0.14;
              return Column(
                children: [
                  InformationTile(
                    height: mH,
                    width: mW,
                    title: "Угода користувача",
                    onTap: () async {
                      await Navigator.of(
                        context,
                      ).pushNamed('/rulesScreen', arguments: RulesPage());
                    },
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 2,
                    width: double.infinity,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(gradient: bottomGradient),
                    ),
                  ),
                  InformationTile(
                    height: mH,
                    width: mW,
                    title: "Підтримати проект",
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 2,
                    width: double.infinity,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(gradient: bottomGradient),
                    ),
                  ),
                  InformationTile(height: mH, width: mW, title: "Web версія"),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 2,
                    width: double.infinity,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(gradient: bottomGradient),
                    ),
                  ),
                  InformationTile(
                    height: mH,
                    width: mW,
                    title: "Наші модифікації для S.T.A.L.K.E.R. 2",
                  ),
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 150),
              child: Text(
                "За підтримки",
                style: TextStyle(
                  color: Color.fromARGB(255, 247, 135, 50),
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/alerts_api.png',
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'alerts.in.ua API',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SvgPicture.asset(
                        'assets/stfalcon_logo.svg',
                        height: 40,
                        colorFilter: const ColorFilter.mode(
                          Color.fromARGB(255, 180, 180, 180),
                          BlendMode.srcIn,
                        ),
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InformationTile extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final Function()? onTap;
  const InformationTile({
    super.key,
    required this.height,
    required this.width,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: const Color.fromRGBO(249, 189, 25, 0.016),
      title: Row(
        children: [
          SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color.fromARGB(255, 248, 137, 41),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.arrow_forward,
            color: Color.fromARGB(255, 154, 83, 21),
          ),
        ],
      ),

      onTap: onTap,
    );
  }
}
