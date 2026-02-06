import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:stalc_alarm/models/admin_units.dart';
import 'package:stalc_alarm/view/screens/raions/raions_list_page.dart';
import 'package:stalc_alarm/view/screens/raions/raions_page.dart';

import '../../../core/local_storage/raions_storage.dart';
import '../../../core/network/internet_guard.dart';
import '../../../core/network/tap_internet_guard.dart';
import '../../../core/values/lists.dart';
import '../../widgets/empty_search_result.dart';

import 'package:stalc_alarm/injection_container.dart' as di;

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
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late final InternetGuard _net;

  @override
  void initState() {
    super.initState();
    _net = di.sl<InternetGuard>(); // ✅ беремо з DI
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isEnglish(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'en';

  String _displayTitle(BuildContext context, Oblast o) {
    final en = (o.titleEng ?? '').trim();
    final uk = (o.title ?? '').trim();

    if (_isEnglish(context)) {
      // ✅ якщо en порожня — fallback на uk
      return en.isNotEmpty ? en : uk;
    }
    return uk.isNotEmpty ? uk : en;
  }

  /// Для пошуку: шукаємо і по uk, і по en (інакше в EN не знайде Kyiv, якщо query англійською)
  bool _matchesQuery(Oblast o, String qLower) {
    final uk = (o.title ?? '').toLowerCase();
    final en = (o.titleEng ?? '').toLowerCase();
    return uk.contains(qLower) || en.contains(qLower);
  }

  List<Oblast> get _allOblastsWithoutLast {
    final list = ListsOfAdministrativeUnits.oblasts;
    if (list.isEmpty) return <Oblast>[];
    // як і раніше: не показуємо останній елемент
    return list.take(list.length - 1).toList();
  }

  List<Oblast> _filteredOblasts(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final all = _allOblastsWithoutLast;

    if (q.isEmpty) return all;

    return all.where((o) => _matchesQuery(o, q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredOblasts(context);

    final isEn = _isEnglish(context);
    final titleText = isEn ? 'Choose oblast' : 'Оберіть область';
    final searchHint = isEn ? 'Search oblast...' : 'Пошук області...';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 23, 13, 2),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 224, 125, 15),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 13, 2),
        centerTitle: true,
        title: Text(
          titleText,
          style: const TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: const Color.fromARGB(255, 224, 125, 15),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
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
              color: Color.fromARGB(17, 55, 27, 6),
            ),
          ),

          Column(
            children: [
              SizedBox(
                height: 2,
                width: double.infinity,
                child: const DecoratedBox(
                  decoration: BoxDecoration(gradient: bottomGradient),
                ),
              ),

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
                    hintText: searchHint,
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

              Expanded(
                child: items.isEmpty && _query.isNotEmpty
                    ? const EmptySearchResult()
                    : LayoutBuilder(
                        builder: (context, constrains) => ListView.separated(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final oblast = items[index];
                            final showTitle = _displayTitle(context, oblast);

                            return ListTile(
                              tileColor: const Color.fromARGB(4, 249, 189, 25),
                              leading: SizedBox(
                                height: constrains.maxHeight * 0.06,
                                child: const Image(
                                  image: AssetImage('assets/bullet.png'),
                                  color: Color.fromARGB(255, 224, 125, 15),
                                ),
                              ),
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      showTitle,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 248, 137, 41),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Color.fromARGB(255, 154, 83, 21),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                if (oblast.uid == "oblast_31") {
                                  await runIfOnline(
                                    context,
                                    net: _net,
                                    action: () async {
                                      await FirebaseMessaging.instance
                                          .subscribeToTopic(oblast.uid!);
                                      debugPrint('✅ subscribed to ${oblast.uid}');

                                      await SavedAdminUnitsStorage().add(
                                        Oblast(
                                          uid: oblast.uid,
                                          title: oblast.title,
                                          titleEng: oblast.titleEng,
                                        ),
                                        Raion(
                                          uid: null,
                                          oblastUid: null,
                                          title: null,
                                          titleEng: null
                                        ),
                                        Hromada(
                                          uid: null,
                                          raionUid: null,
                                          title: null,
                                          titleEng: null
                                        ),
                                      );

                                      if (!mounted) return;
                                      Navigator.of(context).pop(true);
                                    },
                                  );
                                } else {
                                  final changed = await Navigator.of(context).pushNamed(
                                    '/raionsScreen',
                                    arguments: oblast,
                                  );

                                  if (changed == true && mounted) {
                                    Navigator.of(context).pop(true);
                                  }
                                }
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
