import 'dart:async';
import 'dart:io';

import 'package:internet_connection_checker/internet_connection_checker.dart';

typedef BoolCallback = void Function(bool ok);

class InternetGuard {
  InternetGuard({
    InternetConnectionChecker? checker,

    /// ✅ якщо даси healthUrl (наприклад https://.../health),
    /// то "connected" буде підтверджуватись реальним HTTP-запитом.
    this.healthUrl,

    /// ✅ скільки часу ігнорувати фейкове "none" після resume
    this.resumeSuppress = const Duration(milliseconds: 900),

    /// ✅ debounce для "connected" (щоб дати мережі стабілізуватись)
    this.connectedDebounce = const Duration(milliseconds: 700),

    /// ✅ debounce для "disconnected" (можеш лишити 0, але 150–250мс зменшує флікер)
    this.disconnectedDebounce = const Duration(milliseconds: 150),

    /// ✅ мінімальний інтервал між еміссіями (анти-спам)
    this.minEmitInterval = const Duration(milliseconds: 250),

    /// ✅ чи емiтити тільки якщо стан реально змінився
    this.emitOnlyOnChange = true,
  }) : _checker = checker ?? InternetConnectionChecker();

  final InternetConnectionChecker _checker;

  final String? healthUrl;
  final Duration resumeSuppress;
  final Duration connectedDebounce;
  final Duration disconnectedDebounce;
  final Duration minEmitInterval;
  final bool emitOnlyOnChange;

  StreamSubscription<InternetConnectionStatus>? _sub;
  bool _isStarted = false;

  bool _lastOk = true;        // останній стан, який ми запам’ятали
  bool _lastEmittedOk = true; // останній стан, який ми реально віддали в UI
  DateTime _lastEmitAt = DateTime.fromMillisecondsSinceEpoch(0);

  Timer? _pendingTimer;

  DateTime? _suppressNoneUntil; // вікно після resume, де ігноруємо transient none

  bool get lastOk => _lastOk;

  // ✅ можна підписуватись з різних сторінок
  final Set<BoolCallback> _listeners = {};

  void addListener(BoolCallback cb) => _listeners.add(cb);
  void removeListener(BoolCallback cb) => _listeners.remove(cb);

  /// ✅ Викликай в didChangeAppLifecycleState(resumed)
  void markAppResumed() {
    _suppressNoneUntil = DateTime.now().add(resumeSuppress);
  }

  /// ✅ Примусова перевірка зараз
  Future<bool> checkNow() async {
    final ok = await _checkRealInternet();
    _scheduleEmit(ok, force: true);
    return ok;
  }

  void start() {
    if (_isStarted) return;
    _isStarted = true;

    _sub = _checker.onStatusChange.listen((status) {
      final ok = status == InternetConnectionStatus.connected;

      // Якщо прийшов none в suppress-вікні, НЕ панікуємо
      if (!ok && _shouldSuppressNone()) {
        return;
      }

      _scheduleEmit(ok);
    });

    // 🔥 одразу не емiтимо тут, щоб не було флікеру на старті
    // (перший реальний стан краще отримати через checkNow() з UI)
  }

  bool _shouldSuppressNone() {
    final until = _suppressNoneUntil;
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }

  void _scheduleEmit(bool ok, {bool force = false}) {
    _lastOk = ok;

    _pendingTimer?.cancel();

    final delay = ok ? connectedDebounce : disconnectedDebounce;

    _pendingTimer = Timer(delay, () async {
      bool finalOk = ok;

      // ✅ Якщо мережа "є" — підтвердимо реально (опційно)
      if (ok) {
        finalOk = await _checkRealInternet();
      }

      // ✅ Якщо ми в suppress-вікні і прийшов false — ігноруємо
      if (!finalOk && _shouldSuppressNone()) return;

      _emit(finalOk, force: force);
    });
  }

  Future<bool> _checkRealInternet() async {
    // 1) базова перевірка (пінги/сокети) від InternetConnectionChecker
    final hasConn = await _checker.hasConnection;
    if (!hasConn) return false;

    // 2) опційна перевірка твого сервера /health
    final url = healthUrl;
    if (url == null || url.isEmpty) return true;

    try {
      final uri = Uri.parse(url);

      final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
      final req = await client.getUrl(uri);
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final res = await req.close();

      // 200..399 вважаємо "ок"
      final ok = res.statusCode >= 200 && res.statusCode < 400;

      client.close(force: true);
      return ok;
    } catch (_) {
      return false;
    }
  }

  void _emit(bool ok, {bool force = false}) {
    final now = DateTime.now();

    // анти-спам по часу
    final tooSoon = now.difference(_lastEmitAt) < minEmitInterval;
    if (!force && tooSoon) return;

    // емiтимо тільки якщо зміна (за бажанням)
    if (!force && emitOnlyOnChange && ok == _lastEmittedOk) return;

    _lastEmitAt = now;
    _lastEmittedOk = ok;
    _lastOk = ok;

    for (final cb in _listeners) {
      cb(ok);
    }
  }

  void dispose() {
    _pendingTimer?.cancel();
    _pendingTimer = null;

    _sub?.cancel();
    _sub = null;

    _isStarted = false;
    _listeners.clear();
  }
}
