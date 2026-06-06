import 'package:flutter_test/flutter_test.dart';

import 'package:aklatna/main.dart';

void main() {
  testWidgets('shows welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome to Aklatna'), findsOneWidget);
  });
}
