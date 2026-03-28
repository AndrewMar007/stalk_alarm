import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stalc_alarm/view/widgets/gradient_outline_border_button.dart';

import '../../../core/local_storage/raions_storage.dart';
import '../../../core/ua_hromadas_dart_files/agregator/agregator.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/router_args_models/region_info_args_model.dart';
import '../../bloc/alarm_bloc/alarm_bloc.dart';
import '../../bloc/alarm_bloc/alarm_bloc_state.dart';

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

  bool _isEnglish(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'en';

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

  /// ✅ якщо в SavedAdminUnit немає raionUid, знайдемо його через агрегатор
  String? _resolveRaionUidForHromada(SavedAdminUnit unit) {
    final saved = unit.raionUid?.trim();
    if (saved != null && saved.isNotEmpty) return saved;

    final hUid = unit.hromadaUid;
    if (hUid == null || hUid.trim().isEmpty) return null;

    final rawUid = _stripHromadaPrefix(hUid);

    final found = RaionsAgregator.allHromadas.where((h) => h.uid == rawUid);
    if (found.isEmpty) return null;

    return found.first.raionUid;
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

      if (activeHromadaTopics.contains(topic)) return true;

      final raionUid = _resolveRaionUidForHromada(unit);
      if (raionUid != null && raionUid.isNotEmpty) {
        final normalizedRaion = _stripPrefix(raionUid);
        if (activeRaionUids.contains(normalizedRaion)) return true;
      }

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

  /// ✅ title для списку (UA/EN)
  String _titleOfUnit(BuildContext context, SavedAdminUnit u) {
    final isEn = _isEnglish(context);

    // якщо вибрана громада — показуємо її
    if (u.hromadaTitle != null && u.hromadaTitle!.trim().isNotEmpty) {
      final en = (u.hromadaEngTitle ?? '').trim();
      final uk = (u.hromadaTitle ?? '').trim();
      return isEn ? (en.isNotEmpty ? en : uk) : (uk.isNotEmpty ? uk : en);
    }

    // якщо вибраний район
    if (u.raionTitle != null && u.raionTitle!.trim().isNotEmpty) {
      final en = (u.raionEngTitle ?? '').trim();
      final uk = (u.raionTitle ?? '').trim();
      return isEn ? (en.isNotEmpty ? en : uk) : (uk.isNotEmpty ? uk : en);
    }

    // інакше область
    final en = (u.oblastEngTitle ?? '').trim();
    final uk = (u.oblastTitle ?? '').trim();
    return isEn ? (en.isNotEmpty ? en : uk) : (uk.isNotEmpty ? uk : en);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isEn = _isEnglish(context);

    // Empty state texts
    final regionTitle = isEn ? "Select a region" : "Оберіть регіон";
    final regionDescription = isEn
        ? "Select your region\nto receive future notifications"
        : "Оберіть ваш регіон і слідкуйте за\nмайбутніми повідомленнями";
    final regionButton = isEn ? "Add region" : "Додати регіон";

    // List item texts
    final activeText = isEn ? "Emission is active" : "Викид триває";
    final inactiveText = isEn ? "No emission" : "Немає викиду";
    final trackingText = isEn ? "Tracking" : "Відстежується";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 11, 2),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 11, 2),
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.regions,
          style: const TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final changed = await Navigator.of(context).pushNamed('/oblastsScreen');
              if (changed == true) {
                await loadLocalData();
              }
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
              color: Color.fromARGB(15, 54, 27, 6),
            ),
          ),
          SizedBox(
            height: 2,
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
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_location_rounded,
                        color: Color.fromARGB(255, 247, 135, 50),
                        size: 150,
                      ),
                      Text(
                        regionTitle,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 247, 135, 50),
                          fontSize: 25.0,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        regionDescription,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 247, 135, 50),
                        ),
                      ),
                      const SizedBox(height: 30),
                      GradientBorderButton(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth * 0.12,
                            vertical: constraints.maxHeight * 0.02,
                          ),
                          child: Text(
                            regionButton,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 247, 135, 50),
                            ),
                          ),
                        ),
                        onTap: () async {
                          final changed = await Navigator.of(context).pushNamed('/oblastsScreen');
                          if (changed == true) {
                            await loadLocalData();
                          }
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
                    activeHromadaTopics.addAll(state.activeHromadas.keys);

                    for (final a in state.alarmList) {
                      if (a.finishedAt != null) continue;

                      activeOblastTitles.add(a.locationOblast);

                      if (a.locationType == 'raion') {
                        activeRaionUids.add(_stripPrefix(a.locationUid.toString()));
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
                          image: const AssetImage('assets/bullet.png'),
                          color: const Color.fromARGB(255, 224, 125, 15),
                          width: constraints.maxWidth * 0.13,
                          height: constraints.maxHeight * 0.14,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _titleOfUnit(context, unit),
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 248, 137, 41),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward,
                              color: Color.fromARGB(255, 154, 83, 21),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            SizedBox(height: constraints.maxHeight * 0.05),
                            Text(
                              active ? activeText : inactiveText,
                              style: TextStyle(
                                color: active
                                    ? const Color.fromARGB(255, 255, 120, 80)
                                    : const Color.fromARGB(255, 154, 83, 21),
                                fontSize: 12,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              trackingText,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 154, 83, 21),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          final changed = await Navigator.of(context).pushNamed(
                            '/regionInfoScreen',
                            arguments: RegionInfoArgs(
                              unit: unit,
                              isActiveAlarm: active,
                            ),
                          );

                          if (changed == true) {
                            await loadLocalData();
                          }
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
