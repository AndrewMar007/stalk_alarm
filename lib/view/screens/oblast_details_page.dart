import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stalc_alarm/core/exceptions/failures.dart';
import 'package:stalc_alarm/view/bloc/alarm_history_bloc/alarm_history_bloc.dart';
import 'package:stalc_alarm/view/bloc/alarm_history_bloc/alarm_history_bloc_state.dart';
import 'package:stalc_alarm/view/widgets/radiation_loader.dart';

import '../../core/helper/region_name_resolver.dart';
import '../../core/values/lists.dart';
import '../../l10n/app_localizations.dart';
import '../bloc/alarm_history_bloc/alarm_history_bloc_event.dart';
import '../widgets/gradient_outline_border_button.dart';
import '../widgets/radiation_loader_text.dart';
import '../widgets/volt_meter.dart';

class OblastDetailsPage extends StatefulWidget {
  final int id;
  final String title;

  const OblastDetailsPage({super.key, required this.id, required this.title});

  @override
  State<OblastDetailsPage> createState() => _OblastDetailsPageState();
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

const verticalGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color.fromARGB(72, 232, 136, 27), Color.fromARGB(255, 20, 11, 2)],
  stops: [0.0, 1.0],
);

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

class _OblastDetailsPageState extends State<OblastDetailsPage> {
  bool get _isAlwaysAlarmRegion {
    const crimeaId = 29;
    const luhanskId = 16;
    return widget.id == crimeaId || widget.id == luhanskId;
  }

  double _resolveOblastRiskPercent(LoadedHistoryState state) {
    return (state.risk?.score ?? 0).toDouble().clamp(0, 100);
  }

  String _emptyHistoryText(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    if (_isAlwaysAlarmRegion) {
      return isEn
          ? "The alarm is still active.\nThis region is in constant danger."
          : "Тривога триває до сих пір.\nРегіон в стані постійної небезпеки.";
    }

    return isEn
        ? "No emissions were detected\nin the last 3 days"
        : "Викидів не спостерігалось\nв останні 3 дні";
  }

  String _localizedAppBarTitle(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final uid = 'oblast_${widget.id}';

    final oblast = ListsOfAdministrativeUnits.oblasts
        .cast<dynamic?>()
        .firstWhere((e) => e?.uid == uid, orElse: () => null);

    if (oblast != null) {
      final ukTitle = oblast.title as String? ?? widget.title;
      final enTitle = oblast.titleEng as String? ?? '';

      if (isEn && enTitle.isNotEmpty) {
        return enTitle;
      }
      return ukTitle;
    }

    return widget.title;
  }

  String _fmtTimeHHmm(DateTime dt, String locale) {
    return DateFormat('HH:mm', locale).format(dt.toLocal());
  }

  String _durationCompact(DateTime start, DateTime? end, String localeCode) {
    final e = (end ?? DateTime.now()).toLocal();
    final s = start.toLocal();
    final diff = e.difference(s);

    if (diff.inMinutes < 1) {
      return localeCode == 'en' ? '0m' : '0 хв';
    }

    final h = diff.inHours;
    final m = diff.inMinutes % 60;

    if (localeCode == 'en') {
      if (h <= 0) return '${diff.inMinutes}m';
      if (m == 0) return '${h}h';
      return '${h}h ${m}m';
    } else {
      if (h <= 0) return '${diff.inMinutes} хв';
      if (m == 0) return '${h} год';
      return '${h} год ${m} хв';
    }
  }

  DateTime _dateOnlyLocal(DateTime dt) {
    final d = dt.toLocal();
    return DateTime(d.year, d.month, d.day);
  }

  String _historyDayLabel(DateTime startedAt, String localeCode) {
    final s = _dateOnlyLocal(startedAt);
    final today = _dateOnlyLocal(DateTime.now());
    final diffDays = today.difference(s).inDays;

    if (diffDays == 0) {
      return localeCode == 'en' ? 'Today' : 'Сьогодні';
    }

    return localeCode == 'en'
        ? DateFormat('d MMMM', 'en').format(s)
        : DateFormat('d MMMM', 'uk').format(s);
  }

  Widget _historyTileModern({
    required BuildContext context,
    required dynamic model,
    required String localizedRegionTitle,
    required String localeCode,
    required BoxConstraints constraints,
  }) {
    final startedAt = model.startedAt;
    final finishedAt = model.finishedAt;
    final active = finishedAt == null;

    final startHm = _fmtTimeHHmm(startedAt, localeCode);
    final endHm = active
        ? (localeCode == 'en' ? 'ongoing' : 'триває')
        : _fmtTimeHHmm(finishedAt, localeCode);

    final dayText = _historyDayLabel(startedAt, localeCode);
    final durationText = _durationCompact(startedAt, finishedAt, localeCode);

    final timeAndDurationText = '$startHm–$endHm • $durationText';

    final bgGradient = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color.fromARGB(10, 249, 189, 25),
        Color.fromARGB(4, 249, 189, 25),
        Color.fromARGB(10, 249, 189, 25),
      ],
    );

    final isNarrow = constraints.maxWidth < 500;

    const normalMainColor = Color.fromARGB(255, 248, 137, 41);
    const normalSubColor = Color.fromARGB(220, 154, 83, 21);

    const activeAccentColor = Color.fromARGB(255, 255, 120, 80);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: bgGradient,
        border: Border.all(
          color: const Color.fromARGB(40, 247, 135, 50),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 2,
            decoration: const BoxDecoration(gradient: bottomGradient),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/megaphone.png',
                  color: active ? activeAccentColor : normalMainColor,
                  width: isNarrow ? 40 : 45,
                  height: isNarrow ? 40 : 45,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              localizedRegionTitle.isEmpty
                                  ? (localeCode == 'en'
                                        ? 'Unknown location'
                                        : 'Невідома локація')
                                  : localizedRegionTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: normalMainColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            active
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline,
                            size: 20,
                            color: active ? activeAccentColor : normalMainColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            flex: 0,
                            child: Text(
                              dayText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: normalMainColor,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: normalMainColor,
                              fontSize: 11.8,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              timeAndDurationText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: active
                                    ? activeAccentColor
                                    : normalMainColor,
                                fontSize: 11.5,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<AlarmHistoryBloc>().add(
      GetAlarmHistoryBlocEvent(oblastId: widget.id, days: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 11, 2),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(23, 13, 2, 1),
        title: Text(
          _localizedAppBarTitle(context),
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: const Color.fromARGB(255, 247, 135, 50),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: 2,
            width: double.infinity,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: bottomGradient),
            ),
          ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final double btnPadX = (constraints.maxWidth * 0.1).clamp(10, 10);
              final double btnPadY = (constraints.maxHeight * 0.05).clamp(
                10,
                10,
              );

              return BlocBuilder<AlarmHistoryBloc, AlarmHistoryBlocState>(
                builder: (context, state) {
                  if (state is LoadingHistoryState) {
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const RadiationLoader(
                            color: Color.fromARGB(255, 247, 135, 50),
                          ),
                          RadiationLoaderText(
                            text: t.radiationLodearText,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 186, 102, 38),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is LoadedHistoryState) {
                    double riskValue = _resolveOblastRiskPercent(state);

                    // 👇 додаємо умову
                    if (widget.id == 29 || widget.id == 16) {
                      riskValue = 0;
                    }

                    String formatted = '-';

                    if (state.listOfModel.isNotEmpty) {
                      final updatedAtRaw =
                          state.historyUpdatedAt ?? state.updatedAt;

                      DateTime? date;
                      date = DateTime.tryParse(
                        updatedAtRaw.toString(),
                      )?.toLocal();

                      final locale = Localizations.localeOf(context);
                      final isEn = locale.languageCode == 'en';

                      if (date != null) {
                        formatted = isEn
                            ? DateFormat('MMM d, h:mm a', 'en').format(date)
                            : DateFormat('d MMMM, HH:mm', 'uk').format(date);
                      }
                    }

                    if (state.listOfModel.isEmpty) {
                      return SafeArea(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Center(
                                child: VoltmeterGauge(
                                  value: riskValue,
                                  size: constraints.maxWidth < 500 ? 180 : 240,
                                  label: state.risk?.localizedLabel(
                                    isEnglish: isEn,
                                    withEmoji: true,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isAlwaysAlarmRegion
                                          ? Icons.warning_amber_rounded
                                          : Icons.check_circle_outline,
                                      color: const Color.fromARGB(
                                        255,
                                        224,
                                        125,
                                        15,
                                      ),
                                      size: 90,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      _emptyHistoryText(context),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          224,
                                          125,
                                          15,
                                        ),
                                        fontSize: 16,
                                        height: 1.3,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Center(
                            child: VoltmeterGauge(
                              value: riskValue,
                              size: constraints.maxWidth < 500 ? 180 : 240,
                              label: state.risk?.localizedLabel(
                                isEnglish: isEn,
                                withEmoji: true,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          isEn
                              ? "Last updated: $formatted"
                              : "Останнє оновлення даних: $formatted",
                          style: const TextStyle(
                            color: Color.fromARGB(255, 247, 135, 50),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                              itemCount: state.listOfModel.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final model = state.listOfModel[index];

                                final localizedRegionTitle =
                                    RegionNameResolver.localizeTitle(
                                      isEnglish: isEn,
                                      ukTitleFromServer: model.locationTitle,
                                      level: model.locationType,
                                    );

                                return _historyTileModern(
                                  context: context,
                                  model: model,
                                  localizedRegionTitle: localizedRegionTitle,
                                  localeCode: localeCode,
                                  constraints: constraints,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (state is RateHistoryLimitedState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.timelapse_sharp,
                            color: Color.fromARGB(255, 224, 125, 15),
                            size: 80,
                          ),
                          const SizedBox(height: 30),
                          Text(
                            '${t.historyLimit}\n${t.hitoryTry} - ${state.secondsLeft} ${t.seconds}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 224, 125, 15),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ErrorHistoryState) {
                    if (state.failure is InternetFailure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.wifi_off_rounded,
                              size: 100,
                              color: Color.fromARGB(255, 224, 125, 15),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              t.wifiTitleFalse,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 224, 125, 15),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            GradientBorderButton(
                              topGradient: topButtonGradient,
                              bottomGradient: bottomButtonGradient,
                              radius: 30,
                              strokeWidth: 1,
                              onTap: () => Navigator.of(context).pop(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: btnPadX,
                                  vertical: btnPadY,
                                ),
                                child: Text(
                                  t.close,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 224, 125, 15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            color: Color.fromARGB(255, 224, 125, 15),
                            size: 90,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isEn
                                ? "Server is unavailable.\nTry again later."
                                : "Сервер недоступний.\nСпробуйте пізніше.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 224, 125, 15),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: Color.fromARGB(255, 224, 125, 15),
                          size: 80,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "${t.timerEndTitle}. \n${t.timerEndDescription}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 224, 125, 15),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GradientBorderButton(
                          topGradient: topButtonGradient,
                          bottomGradient: bottomButtonGradient,
                          radius: 30,
                          strokeWidth: 1,
                          onTap: () {
                            context.read<AlarmHistoryBloc>().add(
                              GetAlarmHistoryBlocEvent(
                                oblastId: widget.id,
                                days: 3,
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: btnPadX,
                              vertical: btnPadY,
                            ),
                            child: Text(
                              t.retry,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 224, 125, 15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
