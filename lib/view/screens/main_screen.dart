import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:stalc_alarm/view/bloc/alarm_bloc.dart';
import 'package:stalc_alarm/view/bloc/alarm_bloc_state.dart';

import '../../models/alert_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? svgData;
  String? error;

  // щоб не перемальовувати SVG без потреби
  Set<int> _lastIds = {};

  Future<void> _updateSvgFromAlerts(List<AlertModel> alerts) async {
    // ⚠️ Ти використовуєш locationOblastUid як id для path'ів — ок, лишаємо як є.
    final ids = alerts.map((e) => e.locationOblastUid).whereType<int>().toSet();

    // якщо нічого не змінилось — не перегенеровуємо SVG
    if (setEquals(ids, _lastIds) && svgData != null) return;

    _lastIds = ids;

    final v = await highlightRaionsSvgByIds(
      assetPath: 'assets/maps/ukraine_raions.svg',
      raionIds: ids.toList(),
      fillHex: '#AD1700',
      strokeWidth: 6,
    );

    if (!mounted) return;
    setState(() {
      svgData = v;
      error = null;
    });
  }

  @override
  void initState() {
    super.initState();
    // ❗️НЕ стартуємо polling тут.
    // Він має стартувати один раз в main.dart:
    // AlarmBloc(...)..add(StartAlarmPollingEvent(intervalMs: 15000))
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat.yMMMMd('en_US').format(now);

    return Scaffold(
      body: BlocListener<AlarmBloc, AlarmBlocState>(
        listener: (context, state) async {
          if (state is LoadedState) {
            await _updateSvgFromAlerts(state.alarmList);
          } else if (state is ErrorState) {
            if (!mounted) return;
            setState(() {
              error = state.failure.toString();
            });
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Container(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 20, 11, 2),
              ),
              child: Stack(
                children: [
                  // Верхній HUD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 18),

                        // const Text(
                        //   "Дата",
                        //   style: TextStyle(
                        //     color: Color.fromARGB(255, 247, 135, 50),
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.w800,
                        //     letterSpacing: 2,
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 5,
                        //   width: constraints.maxWidth / 8,
                        //   child: const Divider(
                        //     height: 2,
                        //     color: Color.fromARGB(74, 87, 87, 87),
                        //   ),
                        // ),
                        // const SizedBox(height: 5),
                        // Text(
                        //   formattedDate,
                        //   style: const TextStyle(
                        //     color: Color.fromARGB(255, 206, 113, 42),
                        //     fontSize: 14,
                        //     letterSpacing: 1.2,
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 5,
                        //   width: constraints.maxWidth / 2.7,
                        //   child: const Divider(
                        //     height: 2,
                        //     color: Color.fromARGB(74, 87, 87, 87),
                        //   ),
                        // ),

                        // const SizedBox(height: 5),
                        // const Text(
                        //   "Ваше місцезнаходження:",
                        //   style: TextStyle(
                        //     color: Color.fromARGB(255, 247, 135, 50),
                        //     fontSize: 15,
                        //     fontWeight: FontWeight.w800,
                        //     letterSpacing: 2,
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 5,
                        //   width: constraints.maxWidth / 1.7,
                        //   child: const Divider(
                        //     height: 2,
                        //     color: Color.fromARGB(74, 87, 87, 87),
                        //   ),
                        // ),

                        // const SizedBox(height: 5),
                        // const Text(
                        //   "Звенигородка",
                        //   style: TextStyle(
                        //     color: Color.fromARGB(255, 206, 113, 42),
                        //     fontSize: 14,
                        //     letterSpacing: 1.2,
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 5,
                        //   width: constraints.maxWidth / 3.6,
                        //   child: const Divider(
                        //     height: 2,
                        //     color: Color.fromARGB(74, 87, 87, 87),
                        //   ),
                        // ),

                        // if (error != null) ...[
                        //   const SizedBox(height: 8),
                        //   Text(
                        //     error!,
                        //     style: const TextStyle(
                        //       color: Color.fromARGB(255, 255, 120, 80),
                        //       fontSize: 12,
                        //     ),
                        //   ),
                        Container(
                          height: constraints.maxHeight * 0.25,
                          width: constraints.maxWidth * 0.92,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromARGB(255, 247, 135, 50),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: constraints.maxHeight * 0.15,
                                    width: constraints.maxWidth * 0.4573,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color.fromARGB(
                                          255,
                                          247,
                                          135,
                                          50,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Псі\nвипромінювання",
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              247,
                                              135,
                                              50,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: constraints.maxHeight * 0.02,
                                        ),
                                        Text(
                                          "0.09 Псі",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              247,
                                              135,
                                              50,
                                            ),
                                            fontSize: 17.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: constraints.maxHeight * 0.15,
                                    width: constraints.maxWidth * 0.4573,

                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color.fromARGB(
                                          255,
                                          247,
                                          135,
                                          50,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Аномальна\nактивність",
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              247,
                                              135,
                                              50,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: constraints.maxHeight * 0.02,
                                        ),

                                        Text(
                                          "0.09 Псі",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              247,
                                              135,
                                              50,
                                            ),
                                            fontSize: 17.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: constraints.maxHeight * 0.097,
                                width: constraints.maxWidth * 0.92,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 247, 135, 50),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: constraints.maxHeight * 0.01,
                                    ),
                                    Text(
                                      "Дата",
                                      style: TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          247,
                                          135,
                                          50,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: constraints.maxHeight * 0.01,
                                    ),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          247,
                                          135,
                                          50,
                                        ),
                                        fontSize: 17.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      color: const Color.fromARGB(17, 55, 27, 6),
                    ),
                  ),
                  // Карта по центру
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 160,
                    bottom: 80,
                    child: Center(
                      child: svgData == null
                          ? const CircularProgressIndicator()
                          : InteractiveViewer(
                              constrained: true,
                              clipBehavior: Clip.hardEdge,
                              minScale: 1,
                              maxScale: 3.5,
                              child: SvgPicture.string(
                                svgData!,
                                fit: BoxFit.contain,
                                allowDrawingOutsideViewBox: false,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ❗️dispose без StopPolling. Polling глобальний.
  @override
  void dispose() {
    super.dispose();
  }
}

/* ================= SVG helpers ================= */

String stripSvgNamespaces(String svg) {
  svg = svg.replaceAll(RegExp(r'\sxmlns:\w+="[^"]*"'), '');
  svg = svg.replaceAllMapped(
    RegExp(r'<(/?)(\w+):(\w+)([^>]*)>'),
    (m) => '<${m.group(1)}${m.group(3)}${m.group(4)}>',
  );
  return svg;
}

String sanitizeSvgForFlutter(String svg) {
  svg = svg.replaceAll(RegExp(r'<!DOCTYPE[\s\S]*?>', multiLine: true), '');
  svg = svg.replaceAll(
    RegExp(r'<metadata[\s\S]*?<\/metadata>', multiLine: true),
    '',
  );
  svg = svg.replaceAll(RegExp(r'<style[\s\S]*?<\/style>', multiLine: true), '');

  svg = svg.replaceAll(
    RegExp(r'<defs\b[^>]*>[\s\S]*?<\/defs>', multiLine: true),
    '',
  );
  svg = svg.replaceAll(RegExp(r'<defs\b[^>]*/\s*>', multiLine: true), '');
  svg = svg.replaceAll(
    RegExp(r'<\w+:defs\b[^>]*>[\s\S]*?<\/\w+:defs>', multiLine: true),
    '',
  );
  svg = svg.replaceAll(RegExp(r'<\w+:defs\b[^>]*/\s*>', multiLine: true), '');

  return svg;
}

String forceAllLabelGroupsOpaque(String svg) {
  svg = svg.replaceAllMapped(
    RegExp(r'<(\w+:)?g([^>]*\bfill-opacity="\.70196"[^>]*)>', multiLine: true),
    (m) {
      final prefix = m.group(1) ?? '';
      var attrs = m.group(2)!;

      attrs = attrs.replaceAll(RegExp(r'\sopacity="[^"]*"'), '');
      attrs = attrs.replaceAll(RegExp(r'\sfill-opacity="[^"]*"'), '');
      attrs = attrs.replaceAll(RegExp(r'\sstroke-opacity="[^"]*"'), '');

      if (attrs.contains(RegExp(r'\sfill="'))) {
        attrs = attrs.replaceAll(RegExp(r'fill="[^"]*"'), 'fill="#FFFFFF"');
      } else {
        attrs += ' fill="#FFFFFF"';
      }

      return '<${prefix}g$attrs opacity="1" fill-opacity="1" stroke-opacity="1">';
    },
  );

  svg = svg.replaceAllMapped(RegExp(r'style="([^"]*)"', multiLine: true), (sm) {
    var s = sm.group(1)!;
    s = s.replaceAll(RegExp(r'opacity\s*:\s*[^;]+;?'), '');
    s = s.replaceAll(RegExp(r'fill-opacity\s*:\s*[^;]+;?'), '');
    s = s.replaceAll(RegExp(r'stroke-opacity\s*:\s*[^;]+;?'), '');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s.isEmpty ? '' : 'style="$s"';
  });

  return svg;
}

String forceStrokesStaticish(String svg) {
  // === ОБЛАСТІ: подвійний контур ===
  svg = svg.replaceAllMapped(
    RegExp(r'<g([^>]*\bid="g310"\b[^>]*)>', multiLine: true),
    (m) {
      var attrs = m.group(1)!;

      attrs = attrs.replaceAll(RegExp(r'\sstroke="[^"]*"'), '');
      attrs = attrs.replaceAll(RegExp(r'\sstroke-width="[^"]*"'), '');
      attrs = attrs.replaceAll(RegExp(r'\sstroke-opacity="[^"]*"'), '');
      attrs = attrs.replaceAll(RegExp(r'\sstroke-linejoin="[^"]*"'), '');
      attrs = attrs.replaceAll(RegExp(r'\sstroke-linecap="[^"]*"'), '');

      final outer =
          '<g$attrs stroke="#FFFFFF" stroke-width="4.8" '
          'stroke-linejoin="round" stroke-linecap="round">';

      final inner =
          '</g><g$attrs stroke="#3A3A3A" stroke-width="2.4" '
          'stroke-linejoin="round" stroke-linecap="round">';

      return outer + inner;
    },
  );

  // === РАЙОНИ: тонкі, темно-сірі ===
  svg = svg.replaceAllMapped(
    RegExp(r'<g([^>]*\bid="a"\b[^>]*)>', multiLine: true),
    (m) {
      var attrs = m.group(1)!;

      attrs = attrs.replaceAll(RegExp(r'\sstroke="[^"]*"'), '');
      attrs = attrs.replaceAll(RegExp(r'\sstroke-width="[^"]*"'), '');
      attrs = attrs.replaceAll(RegExp(r'\sstroke-opacity="[^"]*"'), '');

      return '<g$attrs stroke="#1F1F1F" stroke-width="0.8" stroke-opacity="0.8" '
          'stroke-linejoin="round" stroke-linecap="round">';
    },
  );

  return svg;
}

Future<String> highlightRaionsSvgByIds({
  required String assetPath,
  required List<int> raionIds,
  String fillHex = '#FF5252',
  double strokeWidth = 6,
}) async {
  String svg = await rootBundle.loadString(assetPath);

  svg = stripSvgNamespaces(svg);
  svg = sanitizeSvgForFlutter(svg);
  svg = forceAllLabelGroupsOpaque(svg);
  svg = forceStrokesStaticish(svg);

  final ids = raionIds.map((e) => e.toString()).toSet();
  int painted = 0;

  svg = svg.replaceAllMapped(
    RegExp(
      r'<path\b[^>]*\bid="([^"]+)"[^>]*\/?>',
      multiLine: true,
      caseSensitive: false,
    ),
    (m) {
      final id = m.group(1);
      var tag = m.group(0)!;

      if (id == null || !ids.contains(id)) return tag;

      painted++;

      tag = tag.replaceAll(RegExp(r'\sstyle="[^"]*"'), '');
      tag = tag.replaceAll(RegExp(r'\sfill="[^"]*"'), '');
      tag = tag.replaceAll(RegExp(r'\sfill-opacity="[^"]*"'), '');
      tag = tag.replaceAll(RegExp(r'\sstroke="[^"]*"'), '');
      tag = tag.replaceAll(RegExp(r'\sstroke-width="[^"]*"'), '');
      tag = tag.replaceAll(RegExp(r'\sstroke-opacity="[^"]*"'), '');

      final inject =
          ' fill="$fillHex" fill-opacity="1" '
          'style="fill:$fillHex;fill-opacity:1;stroke-width:$strokeWidth;stroke-opacity:1;"';

      if (tag.trim().endsWith('/>')) {
        return tag.replaceFirst('/>', '$inject />');
      }
      return tag.replaceFirst('>', '$inject>');
    },
  );

  debugPrint('✅ Painted raions: $painted / ${ids.length}');
  if (painted == 0) {
    debugPrint('❌ No matching <path id="..."> found for ids: $ids');
  }

  return svg;
}
