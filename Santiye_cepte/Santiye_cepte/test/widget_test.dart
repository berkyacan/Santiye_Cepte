import 'package:flutter_test/flutter_test.dart';

import 'package:santiye_cepte/main.dart';

void main() {
  testWidgets('Şantiye Cepte app starts', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SantiyeCepteApp());

    // Verify that our app shows the splash screen initially
    expect(find.text('Şantiye Cepte'), findsOneWidget);
  });
}
