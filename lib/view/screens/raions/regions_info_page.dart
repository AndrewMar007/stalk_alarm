import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stalc_alarm/core/local_storage/raions_storage.dart';
import 'package:stalc_alarm/view/screens/raions/raions_list_page.dart';
import 'package:stalc_alarm/view/widgets/alarm_widget.dart';

import '../../../core/nav/app_tab_controller.dart';
import '../../../core/nav/selection_notifier.dart';
import '../../../core/values/lists.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/admin_units.dart';

class RaionsInfoPage extends StatefulWidget {
  final SavedAdminUnit unit;
  final bool isActiveAlarm;
  const RaionsInfoPage({
    super.key,
    required this.unit,
    required this.isActiveAlarm,
  });

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
  bool _isEnglish(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'en';

  String _pickTitle({
    required bool isEn,
    required String? uk,
    required String? en,
  }) {
    final ukT = (uk ?? '').trim();
    final enT = (en ?? '').trim();

    if (isEn)
      return enT.isNotEmpty ? enT : ukT; // якщо EN нема — fallback на UK
    return ukT.isNotEmpty ? ukT : enT; // якщо UK нема — fallback на EN
  }

  /// ✅ title для Oblast/Raion/Hromada залежно від мови
  String _titleOfUnit(BuildContext context, SavedAdminUnit u) {
    final isEn = _isEnglish(context);

    // 1) громада
    if ((u.hromadaTitle ?? '').trim().isNotEmpty ||
        (u.hromadaEngTitle ?? '').trim().isNotEmpty) {
      return _pickTitle(isEn: isEn, uk: u.hromadaTitle, en: u.hromadaEngTitle);
    }

    // 2) район
    if ((u.raionTitle ?? '').trim().isNotEmpty ||
        (u.raionEngTitle ?? '').trim().isNotEmpty) {
      return _pickTitle(isEn: isEn, uk: u.raionTitle, en: u.raionEngTitle);
    }

    // 3) область
    return _pickTitle(isEn: isEn, uk: u.oblastTitle, en: u.oblastEngTitle);
  }

  final storage = SavedAdminUnitsStorage();
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 23, 13, 2),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 13, 2),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 224, 125, 15)),
        actions: [
          IconButton(
            onPressed: () async {
              final pageContext = context; // ✅ контекст сторінки
              showDialog(
                context: pageContext,
                useRootNavigator: false,
                builder: (dialogContext) => AlertDialogWidget(
                  icon: Icons.location_off_rounded,
                  title: t.deleteRegion,
                  content: t.deleteRegioDescription,
                  acceptButtonText: t.approve,
                  titleTextStyle: TextStyle(color: Color.fromARGB(255, 247, 135, 50)),
                  contentTextStyle: TextStyle(
                    color: Color.fromARGB(200, 248, 137, 41),
                  ),
                  cancelButtonText: t.cancel,
                  onAcceptPressed: () async {
                    if (widget.unit.raionUid != null) {
                      await FirebaseMessaging.instance.unsubscribeFromTopic(
                        widget.unit.raionUid!,
                      );
                      debugPrint('❌ unsubscribed to ${widget.unit.raionUid}');
                      await storage.remove(widget.unit);
                    } else if (widget.unit.oblastUid != null) {
                      await FirebaseMessaging.instance.unsubscribeFromTopic(
                        widget.unit.oblastUid!,
                      );
                      debugPrint('❌ unsubscribed to ${widget.unit.oblastUid}');
                      await storage.remove(widget.unit);
                    } else if (widget.unit.hromadaUid != null) {
                      debugPrint('❌ unsubscribed to ${widget.unit.hromadaUid}');
                        await FirebaseMessaging.instance.unsubscribeFromTopic(
                        widget.unit.hromadaUid!,
                      );
                      await storage.remove(widget.unit);
                    }
                    Navigator.of(dialogContext).pop(); // ✅ закрили діалог
                    Navigator.of(
                      pageContext,
                    ).pop(true); // ✅ закрили сторінку і повернули "true"
                  },
                  onCancelPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
            icon: Icon(
              Icons.delete_outline,
              color: Color.fromARGB(255, 224, 125, 15),
            ),
          ),
        ],
        title: Text(
          t.information,
          style: TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
      ),
      body: Stack(
        alignment: AlignmentGeometry.center,
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
          Align(
            alignment: AlignmentGeometry.topCenter,
            child: SizedBox(
              height: 2, // товщина лінії
              width: double.infinity,
              child: const DecoratedBox(
                decoration: BoxDecoration(gradient: bottomGradient),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.03),
                  Text(
                    _titleOfUnit(context, widget.unit),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 247, 135, 50),
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),

                  Column(
                    children: [
                      Image(
                        image: AssetImage("assets/megaphone.png"),
                        color: widget.isActiveAlarm
                            ? Colors.red
                            : Color.fromARGB(255, 247, 135, 50),
                        height: constraints.maxHeight * 0.3,
                        fit: BoxFit.cover,
                        width: constraints.maxWidth * 0.6,
                      ),
                      SizedBox(height: constraints.maxHeight * 0.03),
                      Text(
                        widget.isActiveAlarm
                            ? t.infromationAlarmText1
                            : t.inforomationAlarmText3,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.isActiveAlarm
                              ? Colors.red
                              : Color.fromARGB(255, 247, 135, 50),
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.03),

                      Text(
                        widget.isActiveAlarm
                            ? t.inforomationAlarmText2
                            : t.inforomationAlarmText4,
                        style: TextStyle(
                          color: widget.isActiveAlarm
                              ? Colors.red
                              : Color.fromARGB(255, 247, 135, 50),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
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
