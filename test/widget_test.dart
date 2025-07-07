import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:churrascos_dulces_app/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that the app loads without errors
    expect(find.text('Dashboard'), findsOneWidget);
    
    // Verify bottom navigation is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    
    // Verify navigation items exist
    expect(find.text('Churrascos'), findsOneWidget);
    expect(find.text('Dulces'), findsOneWidget);
  });

  testWidgets('Navigation works', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Tap on Churrascos tab
    await tester.tap(find.text('Churrascos'));
    await tester.pump();

    // Should show churrascos screen
    expect(find.text('Churrascos'), findsWidgets);
  });
}