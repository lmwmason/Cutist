import 'package:flutter_test/flutter_test.dart';

import 'package:cutist_app/main.dart';

void main() {
  testWidgets('App boots to the connect screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CutistApp());
    expect(find.text('Cutist'), findsOneWidget);
  });
}
