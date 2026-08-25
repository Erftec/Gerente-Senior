import 'package:flutter_test/flutter_test.dart';
import 'package:gerente_senior/senior_home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('SeniorHomeScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SeniorHomeScreen()));

    expect(find.text('Olá, Vovô!'), findsOneWidget);
  });
}
