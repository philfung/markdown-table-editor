// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:table_editor/main.dart';

void main() {
  testWidgets('Table editor app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TableEditorApp());

    // Verify that the app title is displayed.
    expect(find.text('Markdown Table Editor'), findsOneWidget);

    // Verify that the three main sections are present.
    expect(find.text('Import'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
  });
}
