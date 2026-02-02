import 'package:flutter/foundation.dart';

final ValueNotifier<int> selectionVersion = ValueNotifier<int>(0);

void bumpSelectionVersion() {
  selectionVersion.value++;
}
