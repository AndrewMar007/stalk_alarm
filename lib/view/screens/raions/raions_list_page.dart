import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stalc_alarm/view/widgets/gradient_outline_border_button.dart';

import '../../../core/local_storage/raions_storage.dart';
import '../../../core/ua_hromadas_dart_files/agregator/agregator.dart';
import '../../bloc/alarm_bloc/alarm_bloc.dart';
import '../../bloc/alarm_bloc/alarm_bloc_state.dart';
import '../raions/oblasts_page.dart';
import '../raions/raions_info_page.dart';

// ✅ ДОДАЙ СВІЙ АГРЕГАТОР (підправ шлях, якщо інший)

class RaionsListPage extends StatefulWidget {
  const RaionsListPage({super.key});

  @override
  State<RaionsListPage> createState() => _RaionsListPageState();
}

/* ================= GRADIENTS ================= */

const bottomButtonGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(169, 248, 138, 41),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(169, 248, 138, 41),
  ],
  stops: [0.02, 0.4, 0.9, 1.0],
);

const topButtonGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(169, 248, 138, 41),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(169, 248, 138, 41),
  ],
  stops: [0.02, 0.6, 0.8, 1.0],
);

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

/* ================= STATE ================= */

class _RaionsListPageState extends State<RaionsListPage> {
  final _storage = SavedAdminUnitsStorage();
  List<SavedAdminUnit> _listOfUnits = [];
  bool _loadingLocal = true;

  @override
  void initState() {
    super.initState();
    loadLocalData();
  }

  Future<void> loadLocalData() async {
    final data = await _storage.loadAll();
    if (!mounted) return;
    setState(() {
      _listOfUnits = data;
      _loadingLocal = false;
    });
  }

  /// "raion_150" -> "150"
  String _stripPrefix(String v) {
    final s = v.trim();
    if (s.contains('_')) return s.split('_').last;
    return s;
  }

  /// uid -> hromada_UID
  String _hromadaTopic(String uid) {
    final s = uid.trim();
    if (s.startsWith('hromada_')) return s;
    return 'hromada_$s';
  }

  /// ✅ "hromada_UA...." -> "UA...."
  String _stripHromadaPrefix(String v) {
    final s = v.trim();
    if (s.startsWith('hromada_')) return s.substring('hromada_'.length);
    return s;
  }

  /// ✅ ГОЛОВНЕ: якщо в SavedAdminUnit немає raionUid, знайдемо його через RaionsAgregator
  String? _resolveRaionUidForHromada(SavedAdminUnit unit) {
    // 1) якщо вже збережено — повертаємо
    final saved = unit.raionUid?.trim();
    if (saved != null && saved.isNotEmpty) return saved;

    // 2) знайти по hromadaUid у RaionsAgregator.allHromadas
    final hUid = unit.hromadaUid;
    if (hUid == null || hUid.trim().isEmpty) return null;

    final rawUid = _stripHromadaPrefix(hUid);

    // allHromadas: List<Hromada(uid: 'UA....', raionUid: 'raion_114', ... )>
    final found = RaionsAgregator.allHromadas.where((h) => h.uid == rawUid);
    if (found.isEmpty) return null;

    return found.first.raionUid; // очікуємо "raion_114"
  }

  /// ===== Визначення активності =====
  bool _isActiveByUnit(
    SavedAdminUnit unit,
    Set<String> activeRaionUids,
    Set<String> activeOblastTitles,
    Set<String> activeHromadaTopics,
  ) {
    // ✅ 1) ГРОМАДА
    final hromadaUid = unit.hromadaUid;
    if (hromadaUid != null && hromadaUid.isNotEmpty) {
      final topic = _hromadaTopic(hromadaUid);

      // 1.1) якщо push START вже був отриманий додатком
      if (activeHromadaTopics.contains(topic)) return true;

      // 1.2) fallback: якщо активний район цієї громади
      final raionUid = _resolveRaionUidForHromada(unit);
      if (raionUid != null && raionUid.isNotEmpty) {
        final normalizedRaion = _stripPrefix(raionUid);
        if (activeRaionUids.contains(normalizedRaion)) return true;
      }

      // 1.3) fallback: якщо активна область
      return activeOblastTitles.contains(unit.oblastTitle);
    }

    // ✅ 2) РАЙОН
    final raionUid = unit.raionUid;
    if (raionUid != null && raionUid.isNotEmpty) {
      final normalized = _stripPrefix(raionUid);
      return activeRaionUids.contains(normalized);
    }

    // ✅ 3) ОБЛАСТЬ
    return activeOblastTitles.contains(unit.oblastTitle);
  }

  String _titleOfUnit(SavedAdminUnit u) {
    if (u.hromadaTitle != null) return u.hromadaTitle!;
    if (u.raionTitle != null) return u.raionTitle!;
    return u.oblastTitle!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 11, 2),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 11, 2),
        centerTitle: true,
        title: const Text(
          "Регіони",
          style: TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(CupertinoPageRoute(builder: (_) => const OblastsPage()));
            },
            icon: const Icon(
              Icons.add,
              color: Color.fromARGB(255, 247, 135, 50),
            ),
          ),
        ],
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
              color: Color.fromARGB(15, 54, 27, 6),
            ),
          ),
          SizedBox(
            height: 2, // товщина лінії
            width: double.infinity,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: bottomGradient),
            ),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              if (_loadingLocal) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_listOfUnits.isEmpty) {
                // return const Center(
                //   child: Text(
                //     "Нічого не вибрано",
                //     style: TextStyle(color: Color.fromARGB(255, 248, 165, 101)),
                //   ),
                // );
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_location_rounded,
                        color: Color.fromARGB(255, 247, 135, 50),
                        size: 150,
                      ),
                      Text(
                        "Оберіть ваш регіон",
                        style: TextStyle(
                          color: Color.fromARGB(255, 247, 135, 50),
                          fontSize: 25.0,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        "Оберіть ваш регіон і слідкуйте за\n майбутніми повідомленнями",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 247, 135, 50),
                        ),
                      ),
                      SizedBox(height: 30),
                      GradientBorderButton(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth * 0.12,
                            vertical: constraints.maxHeight * 0.02,
                          ),
                          child: Text(
                            "Додати регіон",
                            style: TextStyle(
                              color: Color.fromARGB(255, 247, 135, 50),
                            ),
                          ),
                        ),
                        onTap: () async {
                          await Navigator.of(
                            context,
                            rootNavigator: false,
                          ).push(
                            CupertinoPageRoute(
                              builder: (_) => const OblastsPage(),
                            ),
                          );
                        },
                        topGradient: topButtonGradient,
                        bottomGradient: bottomButtonGradient,
                        radius: 30.0,
                      ),
                    ],
                  ),
                );
              }

              return BlocBuilder<AlarmBloc, AlarmBlocState>(
                builder: (context, state) {
                  final activeRaionUids = <String>{};
                  final activeOblastTitles = <String>{};
                  final activeHromadaTopics = <String>{};

                  if (state is LoadedState) {
                    // ✅ громади з push
                    activeHromadaTopics.addAll(state.activeHromadas.keys);

                    // ✅ області/райони з API
                    for (final a in state.alarmList) {
                      if (a.finishedAt != null) continue;

                      // ⚠️ якщо ти фільтруєш тільки air_raid — додай тут:
                      // if (a.alertType != 'air_raid') continue;

                      activeOblastTitles.add(a.locationOblast);

                      if (a.locationType == 'raion') {
                        activeRaionUids.add(
                          _stripPrefix(a.locationUid.toString()),
                        );
                      }
                    }
                  }

                  return ListView.separated(
                    itemCount: _listOfUnits.length,
                    separatorBuilder: (_, __) => Container(
                      height: 2,
                      decoration: const BoxDecoration(gradient: bottomGradient),
                    ),
                    itemBuilder: (context, index) {
                      final unit = _listOfUnits[index];

                      final active = _isActiveByUnit(
                        unit,
                        activeRaionUids,
                        activeOblastTitles,
                        activeHromadaTopics,
                      );

                      return ListTile(
                        tileColor: const Color.fromARGB(4, 249, 189, 25),
                        leading: Image(
                          image: AssetImage('assets/bullet.png'),
                          color: Color.fromARGB(255, 224, 125, 15),
                          width: constraints.maxWidth *0.1,
                          height: constraints.maxHeight * 0.1,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _titleOfUnit(unit),
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 248, 137, 41),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              color: Color.fromARGB(255, 154, 83, 21),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              active
                                  ? "Викид триває"
                                  : "Немає викиду",
                              style: TextStyle(
                                color: active
                                    ? const Color.fromARGB(255, 255, 120, 80)
                                    : const Color.fromARGB(255, 154, 83, 21),
                                fontSize: 12,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w400,
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
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => RaionsInfoPage(
                                unit: unit,
                                isActiveAlarm: active,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
