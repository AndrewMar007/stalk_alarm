import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stalc_alarm/core/local_storage/raions_storage.dart';
import 'package:stalc_alarm/view/screens/raions/raions_list_page.dart';

import '../../../core/values/lists.dart';
import '../../../models/admin_units.dart';

class RaionsInfoPage extends StatefulWidget {
  final SavedAdminUnit unit;
  const RaionsInfoPage({super.key, required this.unit});

  @override
  State<RaionsInfoPage> createState() => _RaionsInfoPageState();
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

class _RaionsInfoPageState extends State<RaionsInfoPage> {
  String _titleOfUnit(SavedAdminUnit u) {
    if (u.hromadaTitle != null) return u.hromadaTitle!;
    if (u.raionTitle != null) return u.raionTitle!;
    return u.oblastTitle;
  }

  final storage = SavedAdminUnitsStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 11, 2),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 20, 11, 2),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 255, 170, 105)),
        actions: [
          IconButton(
            onPressed: () async {
              if (widget.unit.raionUid != null) {
                await FirebaseMessaging.instance.unsubscribeFromTopic(
                  widget.unit.raionUid!,
                );
                debugPrint('❌ unsubscribed to ${widget.unit.raionUid}');
                await storage.remove(widget.unit);
              } else if (widget.unit.raionUid == null) {
                await FirebaseMessaging.instance.unsubscribeFromTopic(
                  widget.unit.oblastUid,
                );
                debugPrint('❌ unsubscribed to ${widget.unit.oblastUid}');
                await storage.remove(widget.unit);
              }

              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (_) => const RaionsListPage()),
                (route) => false, // ❌ очищає ВСЕ
              );
            },
            icon: Icon(
              Icons.delete_outline,
              color: Color.fromARGB(255, 255, 170, 105),
            ),
          ),
        ],
        title: Text(
          "Інформація",
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
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.03),
                    Text(
                      _titleOfUnit(widget.unit),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        
                        color: Color.fromARGB(255, 247, 135, 50),
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.03),

                    Column(
                      children: [
                        Icon(
                          Icons.task_alt_outlined,
                          color: Color.fromARGB(255, 247, 135, 50),
                          size: 120,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.03),
                        Text(
                          "Немає викиду",
                          style: TextStyle(
                            color: Color.fromARGB(255, 247, 135, 50),
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.03),

                        Text("Слідкуйте за подальшими оновленнями", style: TextStyle(color: Color.fromARGB(255, 247, 135, 50)),),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          // КОНТЕНТ
          // Expanded(
          //   child: LayoutBuilder(
          //     builder: (context, constrains) => ListView.separated(
          //       itemCount: getRaionsByOblast(widget.oblast.uid).length,
          //       itemBuilder: (context, index) {
          //         return ListTile(
          //           title: Row(
          //             children: [
          //               Text(
          //                 getRaionsByOblast(widget.oblast.uid)[index].title,
          //                 style: const TextStyle(
          //                   color: Color.fromARGB(255, 248, 165, 101),
          //                   fontSize: 16,
          //                 ),
          //               ),
          //               Spacer(),
          //               Icon(
          //                 Icons.arrow_forward,
          //                 color: Color.fromARGB(255, 255, 170, 105),
          //               ),
          //             ],
          //           ),
          //           onTap: () {
          //             Navigator.of(context, rootNavigator: false).push(
          //               CupertinoPageRoute(
          //                 builder: (_) => HromadasPage(
          //                   oblast: widget.oblast,
          //                   raion: getRaionsByOblast(widget.oblast.uid)[index],
          //                 ),
          //               ),
          //             );
          //             // TODO: логіка вибору області
          //             print(
          //               'Обрано: ${getRaionsByOblast(widget.oblast.uid)[index].title}',
          //             );
          //           },
          //         );
          //       },
          //       separatorBuilder: (context, index) {
          //         return Container(
          //           height: 2, // товщина divider
          //           //margin: const EdgeInsets.symmetric(horizontal: 12),
          //           decoration: const BoxDecoration(
          //             gradient: separatedGradient,
          //           ),
          //         );
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
