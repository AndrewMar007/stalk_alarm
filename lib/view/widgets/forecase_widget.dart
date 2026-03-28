import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/exceptions/failures.dart';
import '../../core/values/lists.dart';
import '../../l10n/app_localizations.dart';
import '../../models/admin_units.dart';
import '../../models/forecast_model.dart';
import '../bloc/alarm_forecast_bloc/alarm_forecast_bloc.dart';
import '../bloc/alarm_forecast_bloc/alarm_forecast_bloc_event.dart';
import '../bloc/alarm_forecast_bloc/alarm_forecast_bloc_state.dart';
import 'radiation_loader.dart';
import 'radiation_loader_text.dart';

class AlarmForecastPanel extends StatefulWidget {
  final int oblastId;

  const AlarmForecastPanel({
    super.key,
    required this.oblastId,
  });

  @override
  State<AlarmForecastPanel> createState() => _AlarmForecastPanelState();
}

class _AlarmForecastPanelState extends State<AlarmForecastPanel> {
  Timer? _retryTimer;
  int? _secondsLeft;
  int? _activeRetryFrom;

  bool _isEn(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'en';

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _stopRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _secondsLeft = null;
    _activeRetryFrom = null;
  }

  void _startRetryTimer(int seconds) {
    if (_activeRetryFrom == seconds &&
        _retryTimer != null &&
        _retryTimer!.isActive) {
      return;
    }

    _retryTimer?.cancel();

    setState(() {
      _secondsLeft = seconds;
      _activeRetryFrom = seconds;
    });

    _retryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final current = _secondsLeft ?? 0;

      if (current <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
        });

        context.read<AlarmForecastBloc>().add(
          AlarmGetForecastEvent(oblastId: widget.oblastId),
        );
        return;
      }

      setState(() {
        _secondsLeft = current - 1;
      });
    });
  }

  String _localizedOblastName(
    BuildContext context,
    OblastForecastResponse data,
  ) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    if (!isEn) return data.oblastName;

    final dynamic anyUid = (data as dynamic).oblastUid;
    if (anyUid is String && anyUid.startsWith('oblast_')) {
      final found = ListsOfAdministrativeUnits.oblasts.firstWhere(
        (o) => o.uid == anyUid,
        orElse: () => Oblast(
          uid: anyUid,
          title: data.oblastName,
          titleEng: data.oblastName,
        ),
      );
      if ((found.titleEng ?? '').trim().isNotEmpty) {
        return found.titleEng!;
      }
    }

    final uaName = data.oblastName.trim();
    final foundByUaTitle = ListsOfAdministrativeUnits.oblasts.firstWhere(
      (o) => (o.title ?? '').trim() == uaName,
      orElse: () => Oblast(uid: '', title: uaName, titleEng: uaName),
    );

    return (foundByUaTitle.titleEng ?? '').trim().isNotEmpty
        ? foundByUaTitle.titleEng!
        : uaName;
  }

  String _failureText(BuildContext context, Failure failure) {
    final t = AppLocalizations.of(context)!;

    switch (failure.key) {
      case 'error_no_internet':
        return t.error_no_internet;
      case 'error_rate_limit':
        return t.error_rate_limit;
      case 'error_server':
      default:
        return t.error_server;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmForecastBloc, AlarmForecastBlocState>(
      builder: (context, state) {
        if (state is AlarmForecastInitState ||
            state is AlarmForecastLoadingState) {
          _stopRetryTimer();
          return _loading(context);
        }

        if (state is AlarmForecastRateLimitedState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _startRetryTimer(state.retryAfterSec);
            }
          });

          return _rateLimited(context, _secondsLeft ?? state.retryAfterSec);
        }

        if (state is AlarmForecastErrorState) {
          _stopRetryTimer();
          return _error(context, _failureText(context, state.failure));
        }

        if (state is AlarmForecastLoadedState) {
          _stopRetryTimer();
          return _loaded(context, state.data);
        }

        _stopRetryTimer();
        return _empty();
      },
    );
  }

  Widget _empty() {
    return _panelContainer(
      centerChild: true,
      child: const SizedBox.shrink(),
    );
  }

  Widget _loading(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return _panelContainer(
      centerChild: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

  Widget _rateLimited(BuildContext context, int sec) {
    final isEn = _isEn(context);

    return _panelContainer(
      centerChild: true,
      child: Text(
        isEn
            ? "Forecast limit.\nTry again in ${sec}s."
            : "Ліміт прогнозу.\nСпробуй через ${sec}s.",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color.fromARGB(255, 224, 125, 15),
          fontSize: 14,
          height: 1.3,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _error(BuildContext context, String message) {
    return _panelContainer(
      centerChild: true,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color.fromARGB(255, 224, 125, 15),
          fontSize: 14,
          height: 1.3,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _loaded(BuildContext context, OblastForecastResponse data) {
    final isEn = _isEn(context);
    final periods = data.periods;
    final oblastName = _localizedOblastName(context, data);
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = (screenHeight * 0.34).clamp(260.0, 360.0);

    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      height: panelHeight,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(90, 247, 135, 50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isEn
                ? "Alarm start probability — $oblastName"
                : "Ймовірність початку тривоги\n$oblastName",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color.fromARGB(255, 247, 135, 50),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isEn
                ? "Updated: ${_formatKyivIso(data.updatedAt)} (Kyiv)"
                : "Оновлено: ${_formatKyivIso(data.updatedAt)} (Kyiv)",
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(180, 247, 135, 50),
            ),
          ),
          const SizedBox(height: 17),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: periods.length,
                itemBuilder: (context, i) => _periodRow(context, periods[i]),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodRow(BuildContext context, ForecastPeriod p) {
    final meta = _levelMeta(context, p.level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: meta.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: meta.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: meta.pillBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: meta.pillBorder),
            ),
            child: Text(
              meta.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: meta.text,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${_toKyivTime(p.from)}–${_toKyivTime(p.to)}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            "${p.percent}%",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: meta.text,
            ),
          ),
        ],
      ),
    );
  }

  _LevelMeta _levelMeta(BuildContext context, String level) {
    final isEn = _isEn(context);

    switch (level) {
      case "HIGH":
        return _LevelMeta(
          label: isEn ? "HIGH" : "ВИСОКА",
          text: Colors.redAccent,
          bg: Colors.redAccent.withOpacity(0.10),
          border: Colors.redAccent.withOpacity(0.25),
          pillBg: Colors.redAccent.withOpacity(0.12),
          pillBorder: Colors.redAccent.withOpacity(0.30),
        );
      case "MEDIUM":
        return _LevelMeta(
          label: isEn ? "MEDIUM" : "СЕРЕДНЯ",
          text: Colors.amber,
          bg: Colors.amber.withOpacity(0.10),
          border: Colors.amber.withOpacity(0.25),
          pillBg: Colors.amber.withOpacity(0.12),
          pillBorder: Colors.amber.withOpacity(0.30),
        );
      default:
        return _LevelMeta(
          label: isEn ? "LOW" : "НИЗЬКА",
          text: Colors.greenAccent,
          bg: Colors.greenAccent.withOpacity(0.10),
          border: Colors.greenAccent.withOpacity(0.25),
          pillBg: Colors.greenAccent.withOpacity(0.12),
          pillBorder: Colors.greenAccent.withOpacity(0.30),
        );
    }
  }

  Widget _panelContainer({
    required Widget child,
    bool centerChild = false,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = (screenHeight * 0.34).clamp(260.0, 360.0);

    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      height: panelHeight,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(90, 247, 135, 50),
        ),
      ),
      child: centerChild ? Center(child: child) : child,
    );
  }
}

class _LevelMeta {
  final String label;
  final Color text;
  final Color bg;
  final Color border;
  final Color pillBg;
  final Color pillBorder;

  _LevelMeta({
    required this.label,
    required this.text,
    required this.bg,
    required this.border,
    required this.pillBg,
    required this.pillBorder,
  });
}

String _toKyivTime(String iso) {
  try {
    final dt = DateTime.parse(iso).toUtc();

    final now = DateTime.now();
    final isDst = _isKyivDst(now);

    final kyivOffset = Duration(hours: isDst ? 3 : 2);
    final kyivTime = dt.add(kyivOffset);

    final h = kyivTime.hour.toString().padLeft(2, '0');
    final m = kyivTime.minute.toString().padLeft(2, '0');

    return "$h:$m";
  } catch (_) {
    return iso;
  }
}

bool _isKyivDst(DateTime date) {
  final year = date.year;

  final marchLastSunday = DateTime(
    year,
    3,
    31,
  ).subtract(Duration(days: DateTime(year, 3, 31).weekday % 7));

  final octoberLastSunday = DateTime(
    year,
    10,
    31,
  ).subtract(Duration(days: DateTime(year, 10, 31).weekday % 7));

  return date.isAfter(marchLastSunday) && date.isBefore(octoberLastSunday);
}

String _formatKyivIso(String iso) {
  try {
    final utc = DateTime.parse(iso).toUtc();

    final now = DateTime.now();
    final isDst = _isKyivDst(now);

    final kyivOffset = Duration(hours: isDst ? 3 : 2);
    final kyiv = utc.add(kyivOffset);

    final d =
        "${kyiv.year.toString().padLeft(4, '0')}-"
        "${kyiv.month.toString().padLeft(2, '0')}-"
        "${kyiv.day.toString().padLeft(2, '0')}";

    final t =
        "${kyiv.hour.toString().padLeft(2, '0')}:"
        "${kyiv.minute.toString().padLeft(2, '0')}";

    return "$d $t";
  } catch (_) {
    return iso;
  }
}