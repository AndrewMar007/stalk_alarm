import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../../core/values/lists.dart';

class AddNewRaionPage extends StatefulWidget {
  const AddNewRaionPage({super.key});

  @override
  State<AddNewRaionPage> createState() => _AddNewRaionPageState();
}

const bottomGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(72, 232, 136, 27),
    Color.fromARGB(255, 57, 33, 6),
    Color.fromARGB(255, 45, 26, 5),
    Color.fromARGB(66, 232, 136, 27),
  ],
  stops: [0.02, 0.25, 0.6, 1.0],
);

const separatedGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(72, 232, 136, 27),
    Color.fromARGB(255, 57, 33, 6),
    Color.fromARGB(255, 45, 26, 5),
    Color.fromARGB(66, 232, 136, 27),
  ],
  stops: [0.02, 0.5, 0.8, 1.0],
);


class _AddNewRaionPageState extends State<AddNewRaionPage> {

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 11, 2),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 20, 11, 2),
        centerTitle: true,
        actions: [TextButton(onPressed: () async {
            await FirebaseMessaging.instance
                                     .subscribeToTopic('raion_150');
                                 debugPrint('✅ subscribed to raion_150');
        }, child: Text("Tap"))],
        title: Text(
          "Тривоги",
          style: TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔥 ГРАДІЄНТ ПІД APPBAR
          SizedBox(
            height: 2, // товщина лінії
            width: double.infinity,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: bottomGradient),
            ),
          ),

          // КОНТЕНТ
          Expanded(
            child: LayoutBuilder(
              builder: (context, constrains) => ListView.separated(
                itemCount: ListsOfAdministrativeUnits.ukraineRegions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      ListsOfAdministrativeUnits.ukraineRegions[index],
                      style: const TextStyle(color: Color.fromARGB(255, 248, 165, 101), fontSize: 16),
                    ),
                    onTap: () {
                      // TODO: логіка вибору області
                      print(
                        'Обрано: ${ListsOfAdministrativeUnits.ukraineRegions[index]}',
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return Container(
                    height: 2, // товщина divider
                    //margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(gradient: separatedGradient),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}