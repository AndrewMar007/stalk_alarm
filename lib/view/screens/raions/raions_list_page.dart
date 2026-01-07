import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/local_storage/raions_storage.dart';
import '../../bloc/alarm_bloc.dart';
import '../../bloc/alarm_bloc_state.dart';
import '../raions/oblasts_page.dart';
import '../raions/raions_info_page.dart';

class RaionsListPage extends StatefulWidget {
  const RaionsListPage({super.key});

  @override
  State<RaionsListPage> createState() => _RaionsListPageState();
}

class _RaionsListPageState extends State<RaionsListPage> {
  final _storage = SavedAdminUnitsStorage();
  List<SavedAdminUnit> _listOfUnits = [];
  bool _loadingLocal = true;

  Future<void> loadLocalData() async {
    final data = await _storage.loadAll();
    if (!mounted) return;
    setState(() {
      _listOfUnits = data;
      _loadingLocal = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadLocalData();
  }

  /// Приводимо uid до чистого числа:
  /// "raion_150" -> "150", "150" -> "150", "oblast_24" -> "24"
  String _stripPrefix(String v) {
    final s = v.trim();
    if (s.contains('_')) return s.split('_').last;
    return s;
  }

  bool _isActiveByUnit(
    SavedAdminUnit unit,
    Set<String> activeRaionUids,      // "150"
    Set<String> activeOblastTitles,   // "Миколаївська область"
  ) {
    // якщо користувач вибрав район — перевіряй його
    final raionUid = unit.raionUid?.toString();
    if (raionUid != null && raionUid.isNotEmpty) {
      final normalized = _stripPrefix(raionUid);
      return activeRaionUids.contains(normalized);
    }

    // якщо тільки область — перевіряй по назві області
    // (бо у тебе `location_oblast_uid` в API може бути НЕ id області)
    return activeOblastTitles.contains(unit.oblastTitle);
  }

  String _titleOfUnit(SavedAdminUnit u) {
    if (u.hromadaTitle != null) return u.hromadaTitle!;
    if (u.raionTitle != null) return u.raionTitle!;
    return u.oblastTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 11, 2),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 11, 2),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context, rootNavigator: false).push(
                CupertinoPageRoute(builder: (_) => const OblastsPage()),
              );
              await loadLocalData();
            },
            icon: const Icon(
              Icons.add,
              color: Color.fromARGB(255, 247, 135, 50),
            ),
          ),
        ],
        title: const Text(
          "Регіони",
          style: TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 2, width: double.infinity),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constrains) {
                if (_loadingLocal) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_listOfUnits.isEmpty) {
                  return const Center(
                    child: Text(
                      "Нічого не вибрано",
                      style: TextStyle(color: Color.fromARGB(255, 248, 165, 101)),
                    ),
                  );
                }

                return BlocBuilder<AlarmBloc, AlarmBlocState>(
                  builder: (context, state) {
                    // ✅ активні райони (числові uid як строки)
                    final activeRaionUids = <String>{};

                    // ✅ активні області (по назві області)
                    final activeOblastTitles = <String>{};

                    if (state is LoadedState) {
                      for (final a in state.alarmList) {
                        // якщо finishedAt null => тривога активна
                        if (a.finishedAt != null) continue;

                        // ✅ область активна, якщо є ХОЧА Б ОДИН активний алерт в ній
                        // (raion / hromada / city / oblast — не важливо)
                        activeOblastTitles.add(a.locationOblast);

                        // ✅ район активний лише коли location_type == raion
                        if (a.locationType == 'raion') {
                          final uid = _stripPrefix(a.locationUid.toString());
                          activeRaionUids.add(uid);
                        }
                      }
                    }

                    return ListView.separated(
                      itemCount: _listOfUnits.length,
                      itemBuilder: (context, index) {
                        final unit = _listOfUnits[index];

                        final active = _isActiveByUnit(
                          unit,
                          activeRaionUids,
                          activeOblastTitles,
                        );

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
                                  _titleOfUnit(unit),
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
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: constrains.maxHeight * 0.015),
                            child: Row(
                              children: [
                                Text(
                                  active
                                      ? "В даному регіоні тривога є"
                                      : "В даному регіоні тривоги немає",
                                  style: TextStyle(
                                    color: active
                                        ? const Color.fromARGB(255, 255, 120, 80)
                                        : const Color.fromARGB(255, 154, 83, 21),
                                    fontSize: 12,
                                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  "Відстежується",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 154, 83, 21),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context, rootNavigator: false).push(
                              CupertinoPageRoute(
                                builder: (_) => RaionsInfoPage(unit: unit),
                              ),
                            );
                          },
                        );
                      },
                      separatorBuilder: (_, __) => Container(
                        height: 2,
                        color: const Color.fromARGB(30, 232, 136, 27),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
