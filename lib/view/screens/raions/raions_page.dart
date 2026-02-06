import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:stalc_alarm/router/router_args_models/hromadas_page_args_model.dart';
import 'package:stalc_alarm/injection_container.dart' as di;

import '../../../core/local_storage/raions_storage.dart';
import '../../../core/network/internet_guard.dart';
import '../../../core/network/tap_internet_guard.dart';
import '../../../core/values/lists.dart';
import '../../../models/admin_units.dart';
import '../../widgets/empty_search_result.dart';

class RaionsPage extends StatefulWidget {
  final Oblast oblast;
  const RaionsPage({super.key, required this.oblast});

  @override
  State<RaionsPage> createState() => _RaionsPageState();
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

class _RaionsPageState extends State<RaionsPage> {
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

  String _displayRaionTitle(BuildContext context, Raion r) {
    final en = (r.titleEng ?? '').trim();
    final uk = (r.title ?? '').trim();

    if (_isEnglish(context)) {
      return en.isNotEmpty ? en : uk;
    }
    return uk.isNotEmpty ? uk : en;
  }

  bool _matchesQuery(Raion r, String qLower) {
    final uk = (r.title ?? '').toLowerCase();
    final en = (r.titleEng ?? '').toLowerCase();
    return uk.contains(qLower) || en.contains(qLower);
  }

  List<Raion> getRaionsByOblast(String oblastUid) {
    return ListsOfAdministrativeUnits.raions
        .where((raion) => raion.oblastUid == oblastUid)
        .toList();
  }

  List<Raion> _filteredRaions(BuildContext context) {
    final all = getRaionsByOblast(widget.oblast.uid!);
    final q = _query.trim().toLowerCase();

    if (q.isEmpty) return all;

    return all.where((r) => _matchesQuery(r, q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredRaions(context);

    final isEn = _isEnglish(context);
    final titleText = isEn ? 'Choose district' : 'Оберіть район';
    final searchHint = isEn ? 'Search district...' : 'Пошук району...';
    final pickWholeOblastText =
        isEn ? 'Select whole oblast' : 'Обрати всю область';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 23, 13, 2),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 13, 2),
        centerTitle: true,
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
                            if (index == 0) {
                              // ✅ "Select whole oblast"
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
                                        pickWholeOblastText,
                                        maxLines: 2,
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 248, 137, 41),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                                onTap: () async {
                                  await runIfOnline(
                                    context,
                                    net: _net,
                                    action: () async {
                                      await FirebaseMessaging.instance
                                          .subscribeToTopic(widget.oblast.uid!);
                                      debugPrint('✅ subscribed to ${widget.oblast.uid}');

                                      await SavedAdminUnitsStorage().add(
                                        Oblast(
                                          uid: widget.oblast.uid,
                                          title: widget.oblast.title,
                                          titleEng: widget.oblast.titleEng,
                                        ),
                                        Raion(
                                          uid: null,
                                          oblastUid: null,
                                          title: null,
                                          titleEng: null,
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
                                },
                              );
                            }

                            final unit = items[index - 1];
                            final showTitle = _displayRaionTitle(context, unit);

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
                                final changed = await Navigator.of(context).pushNamed(
                                  '/hromadasScreen',
                                  arguments: HromadasPageArgs(
                                    oblast: widget.oblast,
                                    raion: unit,
                                  ),
                                );

                                if (changed == true && mounted) {
                                  Navigator.of(context).pop(true);
                                }

                                debugPrint('Обрано: ${unit.title} / ${unit.titleEng}');
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
