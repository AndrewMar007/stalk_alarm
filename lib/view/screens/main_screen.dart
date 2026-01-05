import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:stalc_alarm/view/bloc/alarm_bloc.dart';
import 'package:stalc_alarm/view/bloc/alarm_bloc_event.dart';
import 'package:stalc_alarm/view/bloc/alarm_bloc_state.dart';

import '../../models/alert_model.dart';
import '../widgets/gradient_container.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? svgData;
  late List<AlertModel> listOfAlerts = [];
  bool loading = false;
  String? error;
  //  get() async {
  //   final data = await getData();
  //   listOfAlerts = data;
  // }

  // Future<void> _loadAlerts() async {
  //   setState(() {
  //     loading = true;
  //     error = null;
  //   });

  //   try {
  //     final data = await getData(); // List<AlertModel>

  //     if (!mounted) return;
  //     setState(() {
  //       listOfAlerts = data;
  //       loading = false;
  //     });

  //     // ✅ після того як дані є — будуємо SVG
  //     await _buildSvgFromAlerts(data);
  //   } catch (e) {
  //     if (!mounted) return;
  //     setState(() {
  //       error = e.toString();
  //       loading = false;
  //     });
  //   }
  // }

  Future<void> _buildSvgFromAlerts(List<AlertModel> alerts) async {
    final oblastUids = alerts.map((e) => e.locationOblastUid).toSet().toList();

    final v = await highlightRaionsSvgByIds(
      assetPath: 'assets/maps/ukraine_raions.svg',
      raionIds: oblastUids,
      fillHex: '#AD1700',
      strokeWidth: 6,
    );

    if (!mounted) return;
    setState(() => svgData = v);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlarmBloc>().add(
        StartPollingEvent(interval: const Duration(seconds: 15)),
      );
    });

    // _loadAlerts();
    //get();
    // final List<int> oblastUids = listOfAlerts.map((e) => e.locationOblastUid).toSet().toList();
    // // ✅ Тут список районів, де тривога (з API будеш підставляти реальні)
    // final alarmRaions = oblastUids;

    // highlightRaionsSvgByIds(
    //   assetPath: 'assets/maps/ukraine_raions.svg',
    //   raionIds: alarmRaions,
    //   fillHex: '#AD1700',
    //   //strokeHex: '#FF5252',
    //   strokeWidth: 6,
    // ).then((v) {
    //   if (!mounted) return;
    //   setState(() => svgData = v);
    // });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat.yMMMMd('en_US').format(now);
    const hudGreen = Color(0xFF7CFF7C);

    return Scaffold(
      body: BlocListener<AlarmBloc, AlarmBlocState>(
        listener: (context, state) async {
          if (state is LoadedState) {
            final alerts = state.alarmList;

            final oblastUids = alerts
                .map((e) => e.locationOblastUid)
                .toSet()
                .toList();
            final v = await highlightRaionsSvgByIds(
              assetPath: 'assets/maps/ukraine_raions.svg',
              raionIds: oblastUids,
              fillHex: '#AD1700',
              strokeWidth: 6,
            );
            if (!mounted) return;
            setState(() {
              listOfAlerts = alerts;
              svgData = v;
              error = null;
            });
          }
          if (state is ErrorState) {
            if (!mounted) return;
            setState(() => error = state.failure.toString());
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
                        Text(
                          "Дата",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 247, 135, 50),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                          width: constraints.maxWidth / 8,
                          child: Divider(
                            height: 2,
                            color: const Color.fromARGB(74, 87, 87, 87),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 206, 113, 42),
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                          width: constraints.maxWidth / 2.7,
                          child: Divider(
                            height: 2,
                            color: const Color.fromARGB(74, 87, 87, 87),
                          ),
                        ),

                        const SizedBox(height: 5),
                        Text(
                          "Ваше місцезнаходження:",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 247, 135, 50),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                          width: constraints.maxWidth / 1.7,
                          child: Divider(
                            height: 2,
                            color: const Color.fromARGB(74, 87, 87, 87),
                          ),
                        ),

                        const SizedBox(height: 5),
                        Text(
                          "Звенигородка",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 206, 113, 42),
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                          width: constraints.maxWidth / 3.6,
                          child: Divider(
                            height: 2,
                            color: const Color.fromARGB(74, 87, 87, 87),
                          ),
                        ),
                      ],
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

                  // Bottom bar
                  // Align(
                  //   alignment: Alignment.bottomCenter,
                  //   child: SizedBox(
                  //     height: 80,
                  //     child: GradientTopBottomBorder(
                  //       borderWidth: 2,
                  //       radius: 0,
                  //       topGradient: const LinearGradient(
                  //         begin: Alignment.centerLeft,
                  //         end: Alignment.centerRight,
                  //         colors: [
                  //           Color.fromARGB(72, 232, 136, 27),
                  //           Color.fromARGB(255, 43, 25, 5),
                  //           Color.fromARGB(255, 57, 33, 6),
                  //           Color.fromARGB(66, 232, 136, 27),
                  //         ],
                  //         stops: [0.01, 0.15, 0.8, 1.0],
                  //       ),
                  //       bottomGradient: const LinearGradient(
                  //         begin: Alignment.centerLeft,
                  //         end: Alignment.centerRight,
                  //         colors: [
                  //           Color.fromARGB(72, 232, 136, 27),
                  //           Color.fromARGB(255, 57, 33, 6),
                  //           Color.fromARGB(255, 45, 26, 5),
                  //           Color.fromARGB(66, 232, 136, 27),
                  //         ],
                  //         stops: [0.1, 0.45, 0.8, 1.0],
                  //       ),
                  //       sideColor: Colors.transparent,
                  //       child: Row(
                  //         crossAxisAlignment: CrossAxisAlignment.center,
                  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //         children: [
                  //           _BottomItem(
                  //             icon: Icons.crisis_alert_outlined,
                  //             label: "Тривоги",
                  //           ),
                  //           _BottomItem(icon: Icons.map, label: "Мапа"),
                  //           _BottomItem(
                  //             icon: Icons.info_outline_rounded,
                  //             label: "Корисне",
                  //           ),
                  //           GestureDetector(
                  //             onTap: () async {
                  //               await FirebaseMessaging.instance
                  //                   .subscribeToTopic('raion_150');
                  //               debugPrint('✅ subscribed to raion_150');
                  //             },
                  //             child: _BottomItem(
                  //               icon: Icons.settings_outlined,
                  //               label: "Налаштування",
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    context.read<AlarmBloc>().add(StopPollingEvent());
    super.dispose();
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BottomItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    const c = Color.fromARGB(255, 186, 103, 38);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: c),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: c)),
      ],
    );
  }
}

/// ====== SVG helpers ======

String stripSvgNamespaces(String svg) {
  svg = svg.replaceAll(RegExp(r'\sxmlns:\w+="[^"]*"'), '');
  svg = svg.replaceAllMapped(
    RegExp(r'<(/?)(\w+):(\w+)([^>]*)>'),
    (m) => '<${m.group(1)}${m.group(3)}${m.group(4)}>',
  );
  return svg;
}

/// ✅ прибираємо те, що flutter_svg часто не підтримує / ламає
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

/// ✅ робимо непрозорими ВСІ групи, де є fill-opacity=".70196"
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

/// ✅ ПІДСВІТКА БАГАТЬОХ РАЙОНІВ по числових id (150,152,...)
Future<String> highlightRaionsSvgByIds({
  required String assetPath,
  required List<int> raionIds,
  String fillHex = '#FF5252',
  //String strokeHex = '#FF5252',
  double strokeWidth = 6,
}) async {
  String svg = await rootBundle.loadString(assetPath);

  svg = stripSvgNamespaces(svg);
  svg = sanitizeSvgForFlutter(svg);
  svg = forceAllLabelGroupsOpaque(svg);
  svg = forceStrokesStaticish(svg);

  final ids = raionIds.map((e) => e.toString()).toSet();

  int painted = 0;

  // ✅ Проходимось по всіх <path ...> і фарбуємо тільки ті, де id в ids
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

      // чистимо, щоб нічого не перебивало (fill="none", style, stroke...)
      tag = tag.replaceAll(RegExp(r'\sstyle="[^"]*"'), '');
      tag = tag.replaceAll(RegExp(r'\sfill="[^"]*"'), '');
      tag = tag.replaceAll(RegExp(r'\sfill-opacity="[^"]*"'), '');
      tag = tag.replaceAll(RegExp(r'\sstroke="[^"]*"'), '');
      tag = tag.replaceAll(RegExp(r'\sstroke-width="[^"]*"'), '');
      tag = tag.replaceAll(RegExp(r'\sstroke-opacity="[^"]*"'), '');

      // ✅ додаємо і fill і style (щоб точно взялося у flutter_svg)
      final inject =
          ' fill="$fillHex" fill-opacity="1" '
          // 'stroke="$strokeHex" stroke-opacity="1" stroke-width="$strokeWidth" '
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
