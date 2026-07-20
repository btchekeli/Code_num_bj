import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

void test() {
  // Test if SharePlus.instance.share exists
  final shareFn = SharePlus.instance.share;
  debugPrint('Share function: $shareFn');
}
