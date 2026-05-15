import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fanpitch/app.dart';

void main() {
  testWidgets('FanPitchApp builds without crashing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FanPitchApp()));
    await tester.pump();
    // It boots on the splash route while auth bootstraps.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
