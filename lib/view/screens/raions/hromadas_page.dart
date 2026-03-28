import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:stalc_alarm/core/local_storage/raions_storage.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/agregator/agregator.dart';
import 'package:stalc_alarm/injection_container.dart' as di;

import '../../../core/network/internet_guard.dart';
import '../../../core/network/tap_internet_guard.dart';
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
    super.initState();
    _net = di.sl<InternetGuard>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isEnglish(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'en';

  List<Hromada> get _allHromadas {
    return RaionsAgregator.getHromadasByRaionUid(widget.raion.uid!);
  }

  String _displayHromadaTitle(BuildContext context, Hromada h) {
    final en = (h.titleEng ?? '').trim();
    final uk = (h.title ?? '').trim();

    if (_isEnglish(context)) return en.isNotEmpty ? en : uk;
    return uk.isNotEmpty ? uk : en;
  }

  bool _matchesQuery(Hromada h, String qLower) {
    final uk = (h.title ?? '').toLowerCase();
    final en = (h.titleEng ?? '').toLowerCase();
    return uk.contains(qLower) || en.contains(qLower);
  }

  List<Hromada> _filteredHromadas(BuildContext context) {
    final all = _allHromadas;
    final q = _query.trim().toLowerCase();

    if (q.isEmpty) return all;
    return all.where((h) => _matchesQuery(h, q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredHromadas(context);

    final isEn = _isEnglish(context);
    final titleText = isEn ? 'Choose community' : 'Оберіть громаду';
    final searchHint = isEn ? 'Search community...' : 'Пошук громади...';
    final pickWholeRaionText = isEn ? 'Select whole district' : 'Обрати весь район';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 23, 13, 2),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 13, 2),
        centerTitle: true,
          scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 224, 125, 15),
        ),
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
                          itemCount: items.length + 1,
                          itemBuilder: (context, index) {
                            // ✅ "обрати весь район" — зберігаємо oblast+raion, hromada=null
                            if (index == 0) {
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
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pickWholeRaionText,
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
                                  await runIfOnline(
                                    context,
                                    net: _net,
                                    action: () async {
                                      await FirebaseMessaging.instance
                                          .subscribeToTopic(widget.raion.uid!);

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
                                          titleEng: widget.raion.titleEng,
                                        ),
                                        Hromada(
                                          uid: null,
                                          raionUid: null,
                                          title: null,
                                          titleEng: null,
                                        ),
                                      );

                                      if (!mounted) return;
                                      Navigator.of(context).pop(true);
                                    },
                                  );
                                },
                              );
                            }

                            // ✅ конкретна громада — зберігаємо ЛИШЕ громаду
                            final unit = items[index - 1];
                            final showTitle = _displayHromadaTitle(context, unit);

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
                                children: [
                                  Expanded(
                                    child: Text(
                                      showTitle,
                                      maxLines: 3,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 248, 137, 41),
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
                                        .subscribeToTopic('hromada_${unit.uid!}');

                                    await SavedAdminUnitsStorage().add(
                                      // ❗️лише громада
                                      Oblast(uid: widget.oblast.uid, title: null, titleEng: null),
                                      Raion(
                                        uid: null,
                                        oblastUid: null,
                                        title: null,
                                        titleEng: null,
                                      ),
                                      Hromada(
                                        uid: unit.uid,
                                        raionUid: unit.raionUid,
                                        title: unit.title,
                                        titleEng: unit.titleEng,
                                      ),
                                    );

                                    if (!mounted) return;
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
