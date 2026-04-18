import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ideawellnessapp/app.dart';

void main() {
  testWidgets('Shows login screen by default', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: IdeaWellnessApp()));
    await tester.pumpAndSettle();

    expect(find.text('Idea Wellness'), findsOneWidget);
  });
}
