import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'app.dart';
import 'utils/config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Reduce VisibilityDetector update frequency for smoother scroll.
  VisibilityDetectorController.instance.updateInterval = const Duration(
    milliseconds: 200,
  );

  if (kDebugMode) {
    debugPrint(
      '🚀 FanPitch boot — API=${AppConfig.apiBase}  WS=${AppConfig.wsBase}',
    );
  }

  runApp(const ProviderScope(child: FanPitchApp()));
}
