import 'package:stalc_alarm/core/local_storage/raions_storage.dart';

class RegionInfoArgs {
  final SavedAdminUnit unit;
  final bool isActiveAlarm;
  const RegionInfoArgs({required this.unit, required this.isActiveAlarm});
}
