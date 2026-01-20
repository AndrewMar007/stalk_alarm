import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stalc_alarm/core/local_storage/raions_storage.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/agregator/agregator.dart';
import 'package:stalc_alarm/view/screens/raions/raions_list_page.dart';

import '../../../core/values/lists.dart';
import '../../../models/admin_units.dart';

class HromadasPage extends StatefulWidget {
  final Oblast oblast;
  final Raion raion;
  const HromadasPage({super.key, required this.raion, required this.oblast});

  @override
  State<HromadasPage> createState() => _HromadasPageState();
}

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

const separatedGradient = LinearGradient(
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

class _HromadasPageState extends State<HromadasPage> {
  List<Raion> getRaionsByOblast(String oblastUid) {
    return ListsOfAdministrativeUnits.raions
        .where((raion) => raion.oblastUid == oblastUid)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 23, 13, 2),
      appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 23, 13, 2),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 224, 125, 15)),

        title: Text(
          "Оберіть громаду",
          style: TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 🔥 ГРАДІЄНТ ПІД APPBAR
          SizedBox(
            height: 2, // товщина лінії
            width: double.infinity,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: bottomGradient),
            ),
          ),
        Positioned(
            left: -50,
            right: -50,
            top: -50,
            bottom: -50,
            child: Image(
              image: AssetImage("assets/back.png"),
              color: const Color.fromARGB(32, 41, 41, 41),
            ),
          ),
          Positioned(
            left: -350,
            right: -350,
            bottom: -250,
            top: -100,
            child: Image(
              image: AssetImage("assets/radiation.png"),
              color: const Color.fromARGB(17, 55, 27, 6),
            ),
          ),
          // КОНТЕНТ
          LayoutBuilder(
            builder: (context, constrains) => ListView.separated(
              itemCount:
                  RaionsAgregator.getHromadasByRaionUid(
                    widget.raion.uid!,
                  ).length +
                  1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    leading: SizedBox(
                      height: constrains.maxHeight * 0.06,
                      child: Image(
                        image: AssetImage('assets/bullet.png'),
                        color: Color.fromARGB(255, 224, 125, 15),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Обрати весь район",
                            maxLines: 2,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 248, 137, 41),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(width: constrains.maxWidth * 0.03),
                      ],
                    ),
                    onTap: () async {
                      await FirebaseMessaging.instance.subscribeToTopic(
                        widget.raion.uid!,
                      );
                      debugPrint('✅ subscribed to ${widget.raion.uid}');
                      SavedAdminUnitsStorage().add(
                        Oblast(
                          uid: widget.oblast.uid,
                          title: widget.oblast.title,
                        ),
                        Raion(
                          uid: widget.raion.uid,
                          oblastUid: widget.raion.oblastUid,
                          title: widget.raion.title,
                        ),
                        Hromada(uid: null, raionUid: null, title: null),
                      );
                      Navigator.of(context).pushAndRemoveUntil(
                        CupertinoPageRoute(
                          builder: (_) => const RaionsListPage(),
                        ),
                        (route) => false, // ❌ очищає ВСЕ
                      );
                    },
                  );
                }
                final unit = RaionsAgregator.getHromadasByRaionUid(
                  widget.raion.uid!,
                )[index - 1];
                return ListTile(
                  leading: SizedBox(
                    height: constrains.maxHeight * 0.06,
                    child: Image(
                      image: AssetImage('assets/bullet.png'),
                      color: Color.fromARGB(255, 224, 125, 15),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          unit.title!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 248, 137, 41),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: constrains.maxWidth * 0.03),
                      Icon(
                        Icons.arrow_forward,
                        color: Color.fromARGB(255, 154, 83, 21),
                      ),
                    ],
                  ),
                  onTap: () async {
                    await FirebaseMessaging.instance.subscribeToTopic(
                      'hromada_${unit.uid!}'
                    );
                    debugPrint('✅ subscribed to hromada_${unit.uid!}');
                    // Map<String, dynamic> data = {"": RaionsAgregator.getHromadasByRaionUid(widget.raionUid)[index]};
                    SavedAdminUnitsStorage().add(
                      Oblast(uid: null, title: null),
                      Raion(uid: null, oblastUid: null, title: null),
                      unit,
                    );
                    // TODO: логіка вибору області
                    Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (_) => const RaionsListPage(),
                      ),
                      (route) => false, // ❌ очищає ВСЕ
                    );
                    // print(
                    //   'Обрано: ${RaionsAgregator.getHromadasByRaionUid(widget.raion.uid)[index].title}',
                    // );
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
        ],
      ),
    );
  }
}
