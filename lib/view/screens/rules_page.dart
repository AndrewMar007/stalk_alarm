import 'package:flutter/material.dart';

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

List<String> list = [
  "1. Ми не несемо відповідальність за швидкість і точність надання інформації по повітряних тривог, точність створених датчиків для прогнозування тривоги та т.п. Так як на це впливає доступність та робота сервера alerts.in.ua, а від його стабільності роботи напряму залежить наш сервер.",
  "2. Формули які використовуються для прогнозування тривог, створені власноруч і надають лише імовірність шансу початку тривогу відносно статистичних даних, які кожного дня збираються та аналізуються за останні 30 днів",
  "3. Датчики створені для збільшення інтерактивності додатку",
  "4. Безпека даних. Ми не збираємо ваші дані. Лише просимо надати доступ до нотифікацій аби ви могли отримати максимально зручний досвід використання нашого продукту",
  "5. Так як наш сервер напряму залежить від серверу alerts.in.ua, затримки до отримання сповіщень відносно початку тривоги можуть становити до 15 секунд через обмеження на надсилання запитів. Будьте обачні!",
  "6. Використовуючи наш додаток ви погоджуєтесь з усіма пунктами"
];

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 11, 2),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 11, 2),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 224, 125, 15),
        ),
        title: Text(
          "Угода користувача",
          style: const TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
      ),
      body: Stack(
        children: [
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
          SizedBox(
            height: 2,
            width: double.infinity,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: bottomGradient),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(list[index], style: TextStyle(color: Color.fromARGB(255, 202, 122, 61)),),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
