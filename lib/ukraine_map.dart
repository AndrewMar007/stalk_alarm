import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class UkraineAlarmStaticMap extends StatefulWidget {
  final String? highlightOblast; // "Черкаська"
  final bool showRaions;

  const UkraineAlarmStaticMap({
    super.key,
    this.highlightOblast,
    this.showRaions = true,
  });

  @override
  State<UkraineAlarmStaticMap> createState() => _UkraineAlarmStaticMapState();
}

class _UkraineAlarmStaticMapState extends State<UkraineAlarmStaticMap> {
  // ✅ base map image (png з прозорим фоном)
  late final ImageProvider _baseMap = const AssetImage('assets/map/ukraine_base.png');

  // ✅ маска (біла Україна на прозорому) — щоб не бачити прямокутник навіть при zoom
  ui.Image? _maskImage;

  // polygons
  List<_Ring> _oblastRings = [];
  List<_Ring> _raionRings = [];

  bool _loaded = false;

  // bounds (мають відповідати тим, під які готувався base png)
  final double _minLat = 44.0, _maxLat = 52.5;
  final double _minLon = 22.0, _maxLon = 40.5;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    // load mask
    try {
      final bytes = await rootBundle.load('assets/map/ukraine_mask.png');
      final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _maskImage = frame.image;
    } catch (_) {
      // маска опціональна: якщо немає — просто буде PNG base без кліпу
      _maskImage = null;
    }

    // load geojson polygons (для заливки)
    final oblastsStr =
        await rootBundle.loadString('assets/geo/ukr_adm1_oblasts.geojson');
    final oblastFeatures = _readFeatures(oblastsStr);
    _oblastRings = _featuresToRings(oblastFeatures);

    if (widget.showRaions) {
      final raionsStr =
          await rootBundle.loadString('assets/geo/ukr_adm2_raions.geojson');
      final raionFeatures = _readFeatures(raionsStr);
      _raionRings = _featuresToRings(raionFeatures);
    }

    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        // ✅ карта як у “Тривога”: фіксовані пропорції і центр
        const aspect = 1.45;

        double w = c.maxWidth;
        double h = w / aspect;
        if (h > c.maxHeight) {
          h = c.maxHeight;
          w = h * aspect;
        }

        final size = Size(w, h);

        // ✅ масштабуємо ОДИН стек: base png + overlay
        final scene = SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // base (статична картинка з назвами)
              Image(
                image: _baseMap,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),

              // overlay (заливка областей/районів)
              CustomPaint(
                painter: _OverlayPainter(
                  size: size,
                  mask: _maskImage,
                  bounds: _GeoBounds(
                    minLat: _minLat,
                    maxLat: _maxLat,
                    minLon: _minLon,
                    maxLon: _maxLon,
                  ),
                  oblastRings: _oblastRings,
                  raionRings: _raionRings,
                  highlightOblast: widget.highlightOblast,
                ),
              ),
            ],
          ),
        );

        return Center(
          child: InteractiveViewer(
            panEnabled: false, // ✅ як ти сказав: тільки zoom
            minScale: 1.0,
            maxScale: 3.0,
            boundaryMargin: const EdgeInsets.all(24),
            child: scene,
          ),
        );
      },
    );
  }

  // ---------- GeoJSON parsing ----------
  List<_Feature> _readFeatures(String geoJsonString) {
    final map = json.decode(geoJsonString) as Map<String, dynamic>;
    final features = (map['features'] as List).cast<Map<String, dynamic>>();
    final out = <_Feature>[];

    for (final f in features) {
      final props =
          (f['properties'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      final geom = f['geometry'] as Map<String, dynamic>?;
      if (geom == null) continue;

      final type = geom['type'] as String?;
      final coords = geom['coordinates'];

      if (type == 'Polygon') {
        final poly = (coords as List).map((ring) => (ring as List)).toList();
        out.add(_Feature(props, [poly]));
      } else if (type == 'MultiPolygon') {
        final mp = (coords as List)
            .map((polygon) =>
                (polygon as List).map((ring) => (ring as List)).toList())
            .toList();
        out.add(_Feature(props, mp));
      }
    }
    return out;
  }

  List<_Ring> _featuresToRings(List<_Feature> features) {
    final rings = <_Ring>[];
    for (final f in features) {
      final label = _oblastDisplayName(_extractName(f.props));
      for (final poly in f.multiPoly) {
        if (poly.isEmpty) continue;
        final outer = poly.first;
        if (outer.length < 3) continue;

        final pts = <LatLng>[];
        for (final p in outer) {
          final arr = (p as List);
          final lon = (arr[0] as num).toDouble();
          final lat = (arr[1] as num).toDouble();
          pts.add(LatLng(lat, lon));
        }
        rings.add(_Ring(points: pts, label: label));
      }
    }
    return rings;
  }

  String _extractName(Map<String, dynamic> props) {
    const keys = [
      'name_uk', 'name_ua', 'NAME_UK', 'NAME_UA', 'ADM1_UA', 'NAME_1', 'name', 'NAME',
    ];
    for (final k in keys) {
      final v = props[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return 'Unknown';
  }

  String _oblastDisplayName(String s) {
    final t = s.trim();
    final lower = t.toLowerCase();
    if (lower.contains('київ') && (lower.contains('м.') || lower.contains('місто'))) {
      return 'Київ';
    }
    return t.replaceAll(RegExp(r'\s*область\s*', caseSensitive: false), '').trim();
  }
}

// =============== Overlay Painter ===============

class _OverlayPainter extends CustomPainter {
  final Size size;
  final ui.Image? mask; // біла Україна на прозорому — кліп від прямокутника
  final _GeoBounds bounds;
  final List<_Ring> oblastRings;
  final List<_Ring> raionRings;
  final String? highlightOblast;

  _OverlayPainter({
    required this.size,
    required this.mask,
    required this.bounds,
    required this.oblastRings,
    required this.raionRings,
    required this.highlightOblast,
  });

  @override
  void paint(Canvas canvas, Size s) {
    // ✅ якщо є маска — вирізаємо форму України, щоб не було прямокутника
    if (mask != null) {
      final rect = Offset.zero & s;
      final paint = Paint();
      canvas.saveLayer(rect, paint);
      // малюємо все що буде кліпитись
      _paintOverlay(canvas, s);
      // застосовуємо маску
      paint
        ..blendMode = BlendMode.dstIn
        ..filterQuality = FilterQuality.high;
      canvas.drawImageRect(
        mask!,
        Rect.fromLTWH(0, 0, mask!.width.toDouble(), mask!.height.toDouble()),
        rect,
        paint,
      );
      canvas.restore();
    } else {
      _paintOverlay(canvas, s);
    }
  }

  void _paintOverlay(Canvas canvas, Size s) {
    final fillHit = Paint()
      ..isAntiAlias = true
      ..color = Colors.red.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    // ⚠️ У “Тривога” лінії часто вже на base PNG, тому тут можна не малювати border взагалі.
    // Але якщо хочеш — включи.
    // const green = Color(0xFF7CFF7C);
    // final border = Paint()
    //   ..isAntiAlias = true
    //   ..color = green.withOpacity(0.35)
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 1.0;

    for (final ring in oblastRings) {
      if (_isHitOblast(ring.label, highlightOblast)) {
        final p = _toPath(ring.points);
        canvas.drawPath(p, fillHit);
      }
    }
  }

  bool _isHitOblast(String label, String? key) {
    if (key == null || key.trim().isEmpty) return false;
    return _norm(label).contains(_norm(key));
  }

  String _norm(String s) => s
      .toLowerCase()
      .replaceAll('область', '')
      .replaceAll('обл.', '')
      .replaceAll(' ', '')
      .replaceAll('-', '')
      .trim();

  ui.Path _toPath(List<LatLng> pts) {
    final path = ui.Path();
    if (pts.isEmpty) return path;

    final p0 = _project(pts.first);
    path.moveTo(p0.dx, p0.dy);

    for (int i = 1; i < pts.length; i++) {
      final p = _project(pts[i]);
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  Offset _project(LatLng ll) {
    // 0..1 -> canvas (під base PNG)
    final x = (ll.longitude - bounds.minLon) / (bounds.maxLon - bounds.minLon);
    final y = (bounds.maxLat - ll.latitude) / (bounds.maxLat - bounds.minLat);

    // padding має відповідати тому, як “вписана” base png
    const pad = 14.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;

    return Offset(pad + x * w, pad + y * h);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) {
    return old.highlightOblast != highlightOblast ||
        old.mask != mask ||
        old.oblastRings.length != oblastRings.length;
  }
}

// =============== Models ===============

class _GeoBounds {
  final double minLat, maxLat, minLon, maxLon;
  const _GeoBounds({
    required this.minLat,
    required this.maxLat,
    required this.minLon,
    required this.maxLon,
  });
}

class _Ring {
  final List<LatLng> points;
  final String label;
  _Ring({required this.points, required this.label});
}

class _Feature {
  final Map<String, dynamic> props;
  final List<List<List<dynamic>>> multiPoly;
  _Feature(this.props, this.multiPoly);
}
