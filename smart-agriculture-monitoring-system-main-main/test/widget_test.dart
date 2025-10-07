// This is a basic Flutter widget test for IoT Dashboard.
//
// It verifies that header and sensor cards are displayed correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soil_dashboard/main.dart';

void main() {
  testWidgets('IoT Dashboard loads header and sensor cards', (WidgetTester tester) async {
    // Build our IoT Dashboard app and trigger a frame.
    await tester.pumpWidget(const IoTDashboardApp());

    // Verify that header is displayed
    expect(find.text('IoT Sensor Dashboard'), findsOneWidget);
    expect(find.text('AI factory safety monitoring'), findsOneWidget);

    // Verify that connection error card is displayed
    expect(find.text('Connection Error'), findsOneWidget);
    expect(find.text('192.168.9.210'), findsOneWidget);
    expect(find.text('OFFLINE'), findsOneWidget);

    // Verify sensor cards are displayed
    expect(find.text('Temperature'), findsOneWidget);
    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('LPG Gas (MQ-6)'), findsOneWidget);
    expect(find.text('CO Level (MQ-7)'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Voltage'), findsOneWidget);

    // Optional: Tap on the refresh FAB and ensure it exists
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump(); // rebuild frame after tap
  });
}
