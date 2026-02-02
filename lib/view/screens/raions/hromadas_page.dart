import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stalc_alarm/core/local_storage/raions_storage.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/agregator/agregator.dart';
import 'package:stalc_alarm/view/screens/raions/raions_list_page.dart';
import 'package:stalc_alarm/injection_container.dart' as di;

import '../../../core/nav/selection_notifier.dart';
import '../../../core/network/internet_guard.dart';
import '../../../core/network/tap_internet_guard.dart';
import '../../../core/values/lists.dart';
import '../../../injection_container.dart' as di;
import '../../../models/admin_units.dart';
import '../../widgets/empty_search_result.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late final InternetGuard _net;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _net = di.sl<InternetGuard>(); // ✅ беремо з DI
  }

  List<Raion> getRaionsByOblast(String oblastUid) {
    return ListsOfAdministrativeUnits.raions
        .where((raion) => raion.oblastUid == oblastUid)
        .toList();
  }

  List<Hromada> get _allHromadas {
    return RaionsAgregator.getHromadasByRaionUid(widget.raion.uid!);
  }

  List<Hromada> get _filteredHromadas {
    final all = _allHromadas;
    final q = _query.trim().toLowerCase();

    if (q.isEmpty) return all;

    return all.where((h) {
      final title = (h.title ?? '').toLowerCase();
      return title.contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredHromadas;

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // ✅ щоб layout не стискався при клавіатурі
      backgroundColor: const Color.fromARGB(255, 23, 13, 2),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 13, 2),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 224, 125, 15),
        ),
        title: const Text(
          "Оберіть громаду",
          style: TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: const Color.fromARGB(255, 224, 125, 15),
            onPressed: () {
              // ✅ Закриваємо весь "ланцюжок" до RaionsListPage
              Navigator.of(context).popUntil((route) {
                return route.isFirst;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // фон
          Positioned(
            left: -50,
            right: -50,
            top: -50,
            bottom: -50,
            child: Image(
              image: const AssetImage("assets/back.png"),
              color: const Color.fromARGB(32, 41, 41, 41),
            ),
          ),
          Positioned(
            left: -350,
            right: -350,
            bottom: -250,
            top: -100,
            child: Image(
              image: const AssetImage("assets/radiation.png"),
              color: const Color.fromARGB(17, 55, 27, 6),
            ),
          ),

          // контент + пошук
          Column(
            children: [
              // 🔥 ГРАДІЄНТ ПІД APPBAR
              SizedBox(
                height: 2,
                width: double.infinity,
                child: const DecoratedBox(
                  decoration: BoxDecoration(gradient: bottomGradient),
                ),
              ),

              // 🔎 Пошук
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 248, 137, 41),
                    fontSize: 15,
                  ),
                  cursorColor: const Color.fromARGB(255, 247, 135, 50),
                  decoration: InputDecoration(
                    hintText: 'Пошук громади...',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(130, 248, 137, 41),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 224, 125, 15),
                    ),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Color.fromARGB(255, 224, 125, 15),
                            ),
                          ),
                    filled: true,
                    fillColor: const Color.fromARGB(10, 249, 189, 25),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(60, 224, 125, 15),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(140, 224, 125, 15),
                      ),
                    ),
                  ),
                ),
              ),

              // ✅ Список / Порожній результат
              Expanded(
                child: items.isEmpty && _query.isNotEmpty
                    ? const EmptySearchResult()
                    : LayoutBuilder(
                        builder: (context, constrains) => ListView.separated(
                          // +1 бо перший елемент: "Обрати весь район"
                          itemCount: items.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return ListTile(
                                leading: SizedBox(
                                  height: constrains.maxHeight * 0.06,
                                  child: Image(
                                    image: const AssetImage(
                                      'assets/bullet.png',
                                    ),
                                    color: const Color.fromARGB(
                                      255,
                                      224,
                                      125,
                                      15,
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        "Обрати весь район",
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            248,
                                            137,
                                            41,
                                          ),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: constrains.maxWidth * 0.03),
                                  ],
                                ),
                                onTap: () async {
                                  await runIfOnline(
                                    context,
                                    net: _net,
                                    action: () async {
                                      await FirebaseMessaging.instance
                                          .subscribeToTopic(widget.raion.uid!);
                                      debugPrint(
                                        '✅ subscribed to ${widget.raion.uid}',
                                      );

                                      await SavedAdminUnitsStorage().add(
                                        Oblast(
                                          uid: widget.oblast.uid,
                                          title: widget.oblast.title,
                                          titleEng: widget.oblast.titleEng,
                                        ),
                                        Raion(
                                          uid: widget.raion.uid,
                                          oblastUid: widget.raion.oblastUid,
                                          title: widget.raion.title,
                                        ),
                                        Hromada(
                                          uid: null,
                                          raionUid: null,
                                          title: null,
                                        ),
                                      );
                                      Navigator.of(context).pop(true);
                                    },
                                  );
                                },
                              );
                            }

                            final unit = items[index - 1];

                            return ListTile(
                              leading: SizedBox(
                                height: constrains.maxHeight * 0.06,
                                child: Image(
                                  image: const AssetImage('assets/bullet.png'),
                                  color: const Color.fromARGB(
                                    255,
                                    224,
                                    125,
                                    15,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      unit.title ?? '',
                                      maxLines: 3,
                                      style: const TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          248,
                                          137,
                                          41,
                                        ),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: constrains.maxWidth * 0.03),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Color.fromARGB(255, 154, 83, 21),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                await runIfOnline(
                                  context,
                                  net: _net,
                                  action: () async {
                                    await FirebaseMessaging.instance
                                        .subscribeToTopic(
                                          'hromada_${unit.uid!}',
                                        );
                                    debugPrint(
                                      '✅ subscribed to hromada_${unit.uid!}',
                                    );
                                    await SavedAdminUnitsStorage().add(
                                      Oblast(
                                        uid: null,
                                        title: null,
                                        titleEng: null,
                                      ),
                                      Raion(
                                        uid: null,
                                        oblastUid: null,
                                        title: null,
                                      ),
                                      unit,
                                    );
                                    // Navigator.of(
                                    //   context,
                                    //   rootNavigator: true,
                                    // ).pushNamedAndRemoveUntil(
                                    //   '/raionsListScreen',
                                    //   (route) => false,
                                    // );
                                    Navigator.of(context).pop(true);
                                  },
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Container(
                              height: 2,
                              decoration: const BoxDecoration(
                                gradient: separatedGradient,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
