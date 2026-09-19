import 'package:flutter_test/flutter_test.dart';
import 'package:atlas_mobile_app/main.dart';

void main() {
  testWidgets('Atlas App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AtlasMobileApp());
  });
}
