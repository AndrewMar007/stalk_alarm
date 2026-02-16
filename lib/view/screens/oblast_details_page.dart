import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stalc_alarm/core/exceptions/failures.dart';
import 'package:stalc_alarm/view/bloc/alarm_history_bloc/alarm_history_bloc.dart';
import 'package:stalc_alarm/view/bloc/alarm_history_bloc/alarm_history_bloc_state.dart';
import 'package:stalc_alarm/view/widgets/gradient_vertical_divider.dart';
import 'package:stalc_alarm/view/widgets/radiation_loader.dart';

import '../../core/helper/date_fromatter.dart';
import '../../core/helper/region_name_resolver.dart';
import '../../l10n/app_localizations.dart';
import '../bloc/alarm_history_bloc/alarm_history_bloc_event.dart';
import '../widgets/gradient_outline_border_button.dart';
import '../widgets/radiation_loader_text.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<AlarmHistoryBloc>().add(
          GetAlarmHistoryBlocEvent(
            oblastId: widget.id,
            days: 3,
          ),
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
          widget.title,
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
              final double btnPadX =
                  (constraints.maxWidth * 0.1).clamp(10, 10);
              final double btnPadY =
                  (constraints.maxHeight * 0.05).clamp(10, 10);
      
              return BlocBuilder<AlarmHistoryBloc, AlarmHistoryBlocState>(
                builder: (context, state) {
                  if (state is LoadingState) {
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
      
                  if (state is LoadedState) {
                    if (state.listOfModel.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isAlwaysAlarmRegion
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_outline,
                                color: const Color.fromARGB(255, 224, 125, 15),
                                size: 90,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _emptyHistoryText(context),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 224, 125, 15),
                                  fontSize: 16,
                                  height: 1.3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
      
                    return ListView.separated(
                      itemCount: state.listOfModel.length,
                      separatorBuilder: (_, __) => Container(
                        height: 0,
                        decoration: const BoxDecoration(gradient: bottomGradient),
                      ),
                      itemBuilder: (context, index) {
                        final model = state.listOfModel[index];
      
                        final localizedRegionTitle =
                            RegionNameResolver.localizeTitle(
                          isEnglish: isEn,
                          ukTitleFromServer: model.locationTitle,
                          level: model.locationType, // якщо є поле
                        );
      
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 2,
                              width: double.infinity,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(72, 232, 136, 27),
                                ),
                              ),
                            ),
                            Container(
                              color: const Color.fromARGB(4, 249, 189, 25),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: constraints.maxWidth * 0.02,
                                      top: constraints.maxHeight * 0.01,
                                      bottom: constraints.maxHeight * 0.01,
                                    ),
                                    child: Row(
                                      children: [
                                        Image(
                                          image: const AssetImage(
                                            "assets/megaphone.png",
                                          ),
                                          color: Colors.red,
                                          height: constraints.maxHeight * 0.05,
                                          fit: BoxFit.cover,
                                          width: constraints.maxWidth * 0.15,
                                        ),
                                        SizedBox(width: constraints.maxWidth * 0.02),
                                        Text(
                                          "${t.emission}\n$localizedRegionTitle",
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              247,
                                              135,
                                              50,
                                            ),
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2,
                                    width: double.infinity,
                                    child: const DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: bottomGradient,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: constraints.maxWidth * 0.48,
                                        child: Text(
                                          AlarmUiFormat.dateRangeLabel(
                                            model.startedAt,
                                            model.finishedAt,
                                            localeCode: localeCode,
                                          ),
                                          style: TextStyle(
                                            color: model.finishedAt == null
                                                ? Colors.red
                                                : const Color.fromARGB(
                                                    255,
                                                    247,
                                                    135,
                                                    50,
                                                  ),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      GradientVerticalDivider(
                                        gradient: verticalGradient,
                                        thickness: 1.5,
                                        height: constraints.maxHeight * 0.1,
                                      ),
                                      SizedBox(
                                        width: constraints.maxWidth * 0.48,
                                        child: Text(
                                          AlarmUiFormat.durationLabel(
                                            model.startedAt,
                                            model.finishedAt,
                                            localeCode: localeCode,
                                          ),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: model.finishedAt == null
                                                ? Colors.red
                                                : const Color.fromARGB(
                                                    255,
                                                    247,
                                                    135,
                                                    50,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.04),
                          ],
                        );
                      },
                    );
                  }
      
                  if (state is RateLimitedState) {
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
      
                  if (state is ErrorState) {
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
      
                  // fallback (timer end / etc.)
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
