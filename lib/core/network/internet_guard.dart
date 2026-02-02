import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';

typedef BoolCallback = void Function(bool ok);

class InternetGuard {
  InternetGuard({
    InternetConnectionChecker? checker,
  }) : _checker = checker ?? InternetConnectionChecker();

  final InternetConnectionChecker _checker;

  StreamSubscription<InternetConnectionStatus>? _sub;
  bool _isStarted = false;
  bool _lastOk = true;

  bool get lastOk => _lastOk;

  // ✅ Можна підписуватися з різних сторінок
  final Set<BoolCallback> _listeners = {};

  void addListener(BoolCallback cb) => _listeners.add(cb);
  void removeListener(BoolCallback cb) => _listeners.remove(cb);

  Future<bool> checkNow() async {
    final ok = await _checker.hasConnection;
    _emit(ok);
    return ok;
  }

  void start() {
    if (_isStarted) return;
    _isStarted = true;

    _sub = _checker.onStatusChange.listen((status) {
      final ok = status == InternetConnectionStatus.connected;
      _emit(ok);
    });
  }

  void _emit(bool ok) {
    _lastOk = ok;
    for (final cb in _listeners) {
      cb(ok);
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _isStarted = false;
    _listeners.clear();
  }
}
