import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stalc_alarm/models/admin_units.dart';
import 'package:stalc_alarm/view/screens/raions/raions_list_page.dart';
import 'package:stalc_alarm/view/screens/raions/raions_page.dart';

import '../../../core/local_storage/raions_storage.dart';
import '../../../core/values/lists.dart';

class OblastsPage extends StatefulWidget {
  const OblastsPage({super.key});

  @override
  State<OblastsPage> createState() => _OblastsPageState();
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

class _OblastsPageState extends State<OblastsPage> {
  // await FirebaseMessaging.instance
  //                          .subscribeToTopic('raion_150');
  //                      debugPrint('✅ subscribed to raion_150');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 23, 13, 2),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color.fromARGB(255, 224, 125, 15)),
      backgroundColor: const Color.fromARGB(255, 23, 13, 2),
        centerTitle: true,
        // actions: [  IconButton(
        //       onPressed: () {
        //         Navigator.of(context, rootNavigator: false).push(
        //           CupertinoPageRoute(builder: (_) => const OblastsPage()),
        //         );
        //       },
        //       icon: Icon(Icons.add, color: Color.fromARGB(255, 247, 135, 50)),
        //     ),],
        title: Text(
          "Оберіть область",
          style: TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
      ),
      body: Stack(
        children: [
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
          // 🔥 ГРАДІЄНТ ПІД APPBAR
          SizedBox(
            height: 2, // товщина лінії
            width: double.infinity,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: bottomGradient),
            ),
          ),

          // КОНТЕНТ
          LayoutBuilder(
            builder: (context, constrains) => ListView.separated(
              itemCount: ListsOfAdministrativeUnits.oblasts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  tileColor: Color.fromARGB(4, 249, 189, 25),
          
                  leading: SizedBox(
                    height: constrains.maxHeight * 0.06,
                    child: Image(
                      image: AssetImage('assets/bullet.png'),
                      color: Color.fromARGB(255, 224, 125, 15),
                    ),
                  ),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        ListsOfAdministrativeUnits.oblasts[index].title!,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 248, 137, 41),
                          fontSize: 16,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward,
                        color: Color.fromARGB(255, 154, 83, 21),
                      ),
                    ],
                  ),
                  onTap: () async {
                    // TODO: логіка вибору області
                    if (ListsOfAdministrativeUnits.oblasts[index].uid ==
                        "oblast_31") {
                      await FirebaseMessaging.instance.subscribeToTopic(
                        ListsOfAdministrativeUnits.oblasts[index].uid!,
                      );
                      debugPrint(
                        '✅ subscribed to ${ListsOfAdministrativeUnits.oblasts[index].uid}',
                      );
                      // Map<String, dynamic> data = {"": RaionsAgregator.getHromadasByRaionUid(widget.raionUid)[index]};
                      SavedAdminUnitsStorage().add(
                        Oblast(
                          uid: ListsOfAdministrativeUnits.oblasts[index].uid,
                          title:
                              ListsOfAdministrativeUnits.oblasts[index].title,
                        ),
                        Raion(uid: null, oblastUid: null, title: null),
                        Hromada(uid: null, raionUid: null, title: null),
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
                    } else {
                      Navigator.of(context, rootNavigator: false).push(
                        CupertinoPageRoute(
                          builder: (_) => RaionsPage(
                            oblast: ListsOfAdministrativeUnits.oblasts[index],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
              separatorBuilder: (context, index) {
                return Container(
                  height: 2, // товщина divider
                  //margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(
                    gradient: separatedGradient,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
