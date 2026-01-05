import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:path_drawing/path_drawing.dart';

class UkraineInteractiveMap extends StatefulWidget {
  const UkraineInteractiveMap({super.key, required this.assetPath});
  final String assetPath;

  @override
  State<UkraineInteractiveMap> createState() => _UkraineInteractiveMapState();
}

class _UkraineInteractiveMapState extends State<UkraineInteractiveMap> {
  Rect viewBox = const Rect.fromLTWH(0, 0, 1000, 1000);
  final Map<String, Path> allPaths = {};
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString(widget.assetPath);
      final doc = XmlDocument.parse(raw);
      final svgEl = doc.rootElement;

      // viewBox
      final vb = svgEl.getAttribute('viewBox');
      if (vb != null) {
        final parts = vb
            .split(RegExp(r'[\s,]+'))
            .where((e) => e.isNotEmpty)
            .toList();
        if (parts.length == 4) {
          final x = double.tryParse(parts[0]) ?? 0;
          final y = double.tryParse(parts[1]) ?? 0;
          final w = double.tryParse(parts[2]) ?? 1000;
          final h = double.tryParse(parts[3]) ?? 1000;
          viewBox = Rect.fromLTWH(x, y, w, h);
        }
      }

      int i = 0;

      // 🔥 ПРАВИЛЬНИЙ ПАРСИНГ ДЛЯ ns0:path / svg:path
      for (final el in doc.descendants.whereType<XmlElement>()) {
        if (el.name.local != 'path') continue;

        final d = el.getAttribute('d');
        if (d == null || d.trim().isEmpty) continue;

        final id = el.getAttribute('id') ?? 'path_$i';
        i++;

        final path = parseSvgPathData(d);
        allPaths[id] = path;
      }

      debugPrint('SVG loaded: ${widget.assetPath}');
      debugPrint('viewBox: $viewBox');
      debugPrint('paths found: ${allPaths.length}');

      setState(() {});
    } catch (e) {
      setState(() => error = e.toString());
      debugPrint('SVG LOAD ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Text(
          'SVG error:\n$error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (allPaths.isEmpty) {
      return const Center(
        child: Text(
          'NO PATHS FOUND\n(перевір що SVG містить <path d="...">)',
          textAlign: TextAlign.center,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, c.maxHeight);

        return InteractiveViewer(
          minScale: 1,
          maxScale: 10,
          boundaryMargin: const EdgeInsets.all(120),
          child: CustomPaint(
            size: size,
            painter: _AllPathsPainter(viewBox: viewBox, paths: allPaths),
          ),
        );
      },
    );
  }
}

class _AllPathsPainter extends CustomPainter {
  _AllPathsPainter({required this.viewBox, required this.paths});
  final Rect viewBox;
  final Map<String, Path> paths;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / viewBox.width;
    final sy = size.height / viewBox.height;

    canvas.save();
    canvas.translate(-viewBox.left * sx, -viewBox.top * sy);
    canvas.scale(sx, sy);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 1.2;

    for (final p in paths.values) {
      canvas.drawPath(p, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AllPathsPainter oldDelegate) => false;
}
