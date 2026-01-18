import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:stalc_alarm/core/values/lists.dart';
import 'package:stalc_alarm/view/screens/oblast_details_page.dart';

import 'package:xml/xml.dart';
import 'package:path_drawing/path_drawing.dart';

import 'package:stalc_alarm/view/bloc/alarm_bloc.dart';
import 'package:stalc_alarm/view/bloc/alarm_bloc_state.dart';
import 'package:stalc_alarm/view/widgets/gradient_container.dart';
import 'package:stalc_alarm/view/widgets/gradient_horizontal_divider.dart';
import 'package:stalc_alarm/view/widgets/gradient_vertical_divider.dart';

import '../../models/alert_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/* ================== UI gradients ================== */

const topGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(72, 232, 136, 27),
    Color.fromARGB(255, 20, 11, 2),
    Color.fromARGB(255, 20, 11, 2),
    Color.fromARGB(66, 232, 136, 27),
  ],
  stops: [0.0, 0.6, 0.9, 1.0],
);

const bottomGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(72, 232, 136, 27),
    Color.fromARGB(255, 20, 11, 2),
    Color.fromARGB(255, 20, 11, 2),
    Color.fromARGB(66, 232, 136, 27),
  ],
  stops: [0.0, 0.5, 0.8, 1.0],
);

const dividerGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(72, 232, 136, 27),
    Color.fromARGB(255, 20, 11, 2),
    Color.fromARGB(255, 20, 11, 2),
    Color.fromARGB(66, 232, 136, 27),
  ],
  stops: [0.0, 0.15, 0.2, 1.0],
);

const verticalGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color.fromARGB(72, 232, 136, 27),
    Color.fromARGB(255, 20, 11, 2),
  ],
  stops: [0.0, 1.0],
);

class _MainScreenState extends State<MainScreen> {
  String? svgData;
  String? error;

  Timer? _timer;
  late final Stream<double> s1;
  late final Stream<double> s2;
  String _time = '';

  // щоб не перемальовувати SVG без потреби
  Set<int> _lastIds = {};

  // Для zoom/pan
  final TransformationController _tc = TransformationController();

  // viewBox із SVG
  Rect? _viewBox;

  // Карта id -> Path в SVG координатах (для hit-test)
  final Map<int, Path> _idToPath = {};

  // ✅ Дуже важливо для продуктивності:
  // спочатку фільтруємо по bounds (Rect), і лише потім робимо дорогий Path.contains()
  final Map<int, Rect> _idToBounds = {};

  /* ===================== Alerts -> SVG ===================== */

  Future<void> _updateSvgFromAlerts(List<AlertModel> alerts) async {
    final ids = alerts.map((e) => e.locationOblastUid).whereType<int>().toSet();

    if (setEquals(ids, _lastIds) &&
        svgData != null &&
        _viewBox != null &&
        _idToPath.isNotEmpty) {
      return;
    }

    _lastIds = ids;

    final v = await highlightRaionsSvgByIds(
      assetPath: 'assets/maps/ukraine_raions.svg',
      raionIds: ids.toList(),
      fillHex: '#AD1700',
      strokeWidth: 6,
    );

    // Парсимо viewBox і path-и для hit-test (робимо один раз на оновлення SVG)
    _parseSvgForHitTest(v);

    if (!mounted) return;
    setState(() {
      svgData = v;
      error = null;
    });
  }

  void _parseSvgForHitTest(String svgString) {
    _idToPath.clear();
    _idToBounds.clear();
    _viewBox = null;

    try {
      final doc = XmlDocument.parse(svgString);

      final svgEl = doc.findAllElements('svg').isNotEmpty
          ? doc.findAllElements('svg').first
          : null;

      if (svgEl != null) {
        final vb = svgEl.getAttribute('viewBox');
        if (vb != null) {
          final parts = vb.trim().split(RegExp(r'\s+'));
          if (parts.length == 4) {
            final x = double.tryParse(parts[0]) ?? 0;
            final y = double.tryParse(parts[1]) ?? 0;
            final w = double.tryParse(parts[2]) ?? 0;
            final h = double.tryParse(parts[3]) ?? 0;
            if (w > 0 && h > 0) _viewBox = Rect.fromLTWH(x, y, w, h);
          }
        }
      }

      // Беремо ВСІ path з id (числові)
      for (final p in doc.findAllElements('path')) {
        final idRaw = p.getAttribute('id');
        final d = p.getAttribute('d');
        if (idRaw == null || d == null) continue;

        final id = int.tryParse(idRaw.trim());
        if (id == null) continue;

        Path path = parseSvgPathData(d);

        // Якщо є transform на самому path — застосуємо
        final t = p.getAttribute('transform');
        if (t != null && t.trim().isNotEmpty) {
          final m = _parseSvgTransformToMatrix4(t.trim());
          if (m != null) {
            path = path.transform(m.storage);
          }
        }

        _idToPath[id] = path;
        _idToBounds[id] = path.getBounds();
      }

      debugPrint('✅ Parsed viewBox=$_viewBox, paths=${_idToPath.length}');
    } catch (e) {
      debugPrint('❌ SVG parse error: $e');
      _viewBox = null;
      _idToPath.clear();
      _idToBounds.clear();
    }
  }

  // Мінімальна підтримка transform="matrix(a b c d e f)" / translate(x,y) / scale(sx,sy)
  Matrix4? _parseSvgTransformToMatrix4(String t) {
    final m1 = RegExp(
        r'matrix\(\s*([-\d.]+)[,\s]+([-\d.]+)[,\s]+([-\d.]+)[,\s]+([-\d.]+)[,\s]+([-\d.]+)[,\s]+([-\d.]+)\s*\)');
    final mm = m1.firstMatch(t);
    if (mm != null) {
      final a = double.tryParse(mm.group(1)!) ?? 1;
      final b = double.tryParse(mm.group(2)!) ?? 0;
      final c = double.tryParse(mm.group(3)!) ?? 0;
      final d = double.tryParse(mm.group(4)!) ?? 1;
      final e = double.tryParse(mm.group(5)!) ?? 0;
      final f = double.tryParse(mm.group(6)!) ?? 0;

      // SVG matrix: [a c e; b d f; 0 0 1]
      return Matrix4(
        a, b, 0, 0,
        c, d, 0, 0,
        0, 0, 1, 0,
        e, f, 0, 1,
      );
    }

    final tr = RegExp(r'translate\(\s*([-\d.]+)(?:[,\s]+([-\d.]+))?\s*\)')
        .firstMatch(t);
    if (tr != null) {
      final x = double.tryParse(tr.group(1)!) ?? 0;
      final y = double.tryParse(tr.group(2) ?? '0') ?? 0;
      return Matrix4.identity()..translate(x, y);
    }

    final sc =
        RegExp(r'scale\(\s*([-\d.]+)(?:[,\s]+([-\d.]+))?\s*\)').firstMatch(t);
    if (sc != null) {
      final sx = double.tryParse(sc.group(1)!) ?? 1;
      final sy = double.tryParse(sc.group(2) ?? sc.group(1)!) ?? sx;
      return Matrix4.identity()..scale(sx, sy);
    }

    return null;
  }

  /* ===================== Random streams / time ===================== */

  Stream<double> rangedRandomStream({required double min, required double max}) {
    final random = Random();
    return Stream.periodic(const Duration(seconds: 3), (_) {
      final value = min + random.nextDouble() * (max - min);
      return double.parse(value.toStringAsFixed(2));
    });
  }

  @override
  void initState() {
    super.initState();
    s1 = rangedRandomStream(min: 0.0, max: 1.0);
    s2 = rangedRandomStream(min: 150.0, max: 450.0);
    _updateTime();
    _scheduleNextTick();
  }

  void _scheduleNextTick() {
    final now = DateTime.now();
    final secondsUntilNextMinute = 60 - now.second;

    _timer = Timer(Duration(seconds: secondsUntilNextMinute), () {
      _updateTime();
      _timer =
          Timer.periodic(const Duration(minutes: 1), (_) => _updateTime());
    });
  }

  void _updateTime() {
    setState(() => _time = DateFormat('HH:mm').format(DateTime.now()));
  }

  /* ===================== BottomSheet / title ===================== */

  String _oblastTitleById(int id) {
    final uid = "oblast_$id";
    final found = ListsOfAdministrativeUnits.oblasts
        .where((o) => o.uid == uid)
        .toList();
    if (found.isNotEmpty) return found.first.title;
    return "Невідомо ($uid)";
  }

  void _showRaionBottomSheet(int id) {
 // final title = _oblastTitleById(id);

final title = _oblastTitleById(id);

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => OblastDetailsPage(id: id, title: title),
    ),
  );
  // showModalBottomSheet(
  //   context: context,
  //   isScrollControlled: true, // ✅ дозволяє 100% висоти
  //   useSafeArea: true,
  //   enableDrag: false,
  //   isDismissible: false,
  //   backgroundColor: Colors.transparent,
  //   builder: (sheetContext) {
  //     final height = MediaQuery.of(sheetContext).size.height;
  //     return SizedBox(
  //       height: height, // ✅ ПОВНИЙ ЕКРАН
  //       child: Container(
  //         decoration: const BoxDecoration(
  //           color: Color.fromARGB(255, 20, 11, 2),
  //         ),
  //         child: Column(
  //           children: [
  //             // ===== Верхня панель =====
  //             Container(
  //               height: 56,
  //               padding: const EdgeInsets.symmetric(horizontal: 12),
  //               decoration: const BoxDecoration(
  //                 border: Border(
  //                   bottom: BorderSide(
  //                     color: Color.fromARGB(80, 247, 135, 50),
  //                     width: 1,
  //                   ),
  //                 ),
  //               ),
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     child: Text(
  //                       title,
  //                       style: const TextStyle(
  //                         color: Color.fromARGB(255, 247, 135, 50),
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                   IconButton(
  //                     icon: const Icon(Icons.close),
  //                     color: const Color.fromARGB(255, 247, 135, 50),
  //                     onPressed: () {
  //                       Navigator.of(sheetContext).pop();
  //                     },
  //                   ),
  //                 ],
  //               ),
  //             ),

  //             // ===== Контент =====
  //             Expanded(
  //               child: Padding(
  //                 padding: const EdgeInsets.all(20),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Ідентифікатор',
  //                       style: TextStyle(
  //                         color: Colors.grey.shade400,
  //                         fontSize: 12,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       'ID: $id\nuid: oblast_$id',
  //                       style: const TextStyle(
  //                         color: Color.fromARGB(255, 206, 113, 42),
  //                         fontSize: 14,
  //                       ),
  //                     ),

  //                     const SizedBox(height: 24),

  //                     // 👉 тут можеш далі додавати будь-який UI:
  //                     // статус тривоги, графіки, кнопки, списки тощо
  //                     Expanded(
  //                       child: Center(
  //                         child: Text(
  //                           'Контент області',
  //                           style: TextStyle(
  //                             color: Colors.grey.shade500,
  //                             fontSize: 14,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   },
  // );
}


  /* ===================== Tap handling ===================== */

  // Конвертація точки з "видимої картинки" (BoxFit.contain) у координати SVG viewBox
  Offset? _widgetPointToSvgPoint({
    required Offset pWidget, // точка в координатах child (після toScene)
    required Size widgetSize,
    required Rect viewBox,
  }) {
    final vbW = viewBox.width;
    final vbH = viewBox.height;
    if (vbW <= 0 || vbH <= 0) return null;

    final scale = min(widgetSize.width / vbW, widgetSize.height / vbH);
    final drawW = vbW * scale;
    final drawH = vbH * scale;

    final dx = (widgetSize.width - drawW) / 2;
    final dy = (widgetSize.height - drawH) / 2;

    if (pWidget.dx < dx || pWidget.dx > dx + drawW) return null;
    if (pWidget.dy < dy || pWidget.dy > dy + drawH) return null;

    final xSvg = (pWidget.dx - dx) / scale + viewBox.left;
    final ySvg = (pWidget.dy - dy) / scale + viewBox.top;
    return Offset(xSvg, ySvg);
  }

  int? _hitTestId({required Offset svgPoint}) {
    // ✅ Спочатку швидкий bounds-test, потім дорогий Path.contains
    for (final entry in _idToBounds.entries) {
      final id = entry.key;
      final bounds = entry.value;
      if (!bounds.contains(svgPoint)) continue;

      final path = _idToPath[id];
      if (path != null && path.contains(svgPoint)) return id;
    }
    return null;
  }

  /* ===================== Build ===================== */

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMMM y', 'uk_UA').format(now);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(23, 13, 2, 1),
        centerTitle: true,
        title: const Text(
          "Мапа",
          style: TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
      ),
      body: BlocListener<AlarmBloc, AlarmBlocState>(
        listener: (context, state) async {
          if (state is LoadedState) {
            await _updateSvgFromAlerts(state.alarmList);
          } else if (state is ErrorState) {
            if (!mounted) return;
            setState(() => error = state.failure.toString());
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 20, 11, 2),
              ),
              child: Stack(
                children: [
                  // Верхній HUD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RepaintBoundary(
                          child: GradientBorderTopBottom(
                            topGradient: topGradient,
                            bottomGradient: bottomGradient,
                            strokeWidth: 2,
                            radius: 0,
                            child: SizedBox(
                              height: constraints.maxHeight * 0.163,
                              width: constraints.maxWidth,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: constraints.maxHeight * 0.1,
                                        width: constraints.maxWidth * 0.49,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Псі-випромінювання",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 247, 135, 50),
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(
                                                height: constraints.maxHeight *
                                                    0.01),
                                            StreamBuilder(
                                              stream: s1,
                                              builder: (context, snap) {
                                                return Text(
                                                  "${(snap.data ?? 0).toStringAsFixed(2)} Од",
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 247, 135, 50),
                                                    fontSize: 15.0,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      GradientVerticalDivider(
                                        gradient: verticalGradient,
                                        thickness: 1.5,
                                        height: constraints.maxHeight * 0.1,
                                      ),
                                      SizedBox(
                                        height: constraints.maxHeight * 0.1,
                                        width: constraints.maxWidth * 0.488,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Аномальна частота",
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 247, 135, 50),
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(
                                                height: constraints.maxHeight *
                                                    0.01),
                                            StreamBuilder(
                                              stream: s2,
                                              builder: (context, snap) {
                                                return Text(
                                                  "${(snap.data ?? 150).toStringAsFixed(0)} кГц",
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 247, 135, 50),
                                                    fontSize: 15.0,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: constraints.maxHeight * 0.06,
                                    width: constraints.maxWidth,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            height: constraints.maxHeight *
                                                0.005),
                                        GradientDivider(
                                          gradient: dividerGradient,
                                          thickness: 2,
                                        ),
                                        SizedBox(
                                            height:
                                                constraints.maxHeight * 0.01),
                                        FittedBox(
                                          child: Text(
                                            "$formattedDate, $_time",
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 247, 135, 50),
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // фон
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

                  // Карта по центру
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 111,
                    bottom: 0,
                    child: Center(
                      child: svgData == null
                          ? const CircularProgressIndicator()
                          : LayoutBuilder(
                              builder: (context, mapConstraints) {
                                final mapSize = Size(mapConstraints.maxWidth,
                                    mapConstraints.maxHeight);

                                // ✅ Listener краще для сумісності з InteractiveViewer жестами
                                return Listener(
                                  behavior: HitTestBehavior.opaque,
                                  onPointerUp: (e) {
                                    if (_viewBox == null ||
                                        _idToPath.isEmpty) return;

                                    // переводимо точку в "scene" InteractiveViewer (з урахуванням zoom/pan)
                                    final scenePoint =
                                        _tc.toScene(e.localPosition);

                                    final svgPoint = _widgetPointToSvgPoint(
                                      pWidget: scenePoint,
                                      widgetSize: mapSize,
                                      viewBox: _viewBox!,
                                    );

                                    if (svgPoint == null) return;

                                    final id =
                                        _hitTestId(svgPoint: svgPoint);
                                    if (id != null) {
                                      _showRaionBottomSheet(id);
                                    }
                                  },
                                  child: RepaintBoundary(
                                    child: InteractiveViewer(
                                      transformationController: _tc,
                                      constrained: true,
                                      // ✅ часто дає плавніше на трансформаціях
                                      clipBehavior: Clip.none,
                                      minScale: 1,
                                      maxScale: 3.5,
                                      child: SizedBox(
                                        width: mapSize.width,
                                        height: mapSize.height,
                                        child: SvgPicture.string(
                                          svgData!,
                                          fit: BoxFit.contain,
                                          allowDrawingOutsideViewBox: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tc.dispose();
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
  svg =
      svg.replaceAll(RegExp(r'<metadata[\s\S]*?<\/metadata>', multiLine: true),
          '');
  svg = svg.replaceAll(RegExp(r'<style[\s\S]*?<\/style>', multiLine: true), '');

  svg = svg.replaceAll(
      RegExp(r'<defs\b[^>]*>[\s\S]*?<\/defs>', multiLine: true), '');
  svg = svg.replaceAll(RegExp(r'<defs\b[^>]*/\s*>', multiLine: true), '');
  svg = svg.replaceAll(
      RegExp(r'<\w+:defs\b[^>]*>[\s\S]*?<\/\w+:defs>', multiLine: true), '');
  svg =
      svg.replaceAll(RegExp(r'<\w+:defs\b[^>]*/\s*>', multiLine: true), '');

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
          '<g$attrs stroke="#F78732" stroke-width="4.8" '
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
