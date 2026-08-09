import 'package:aprende_mas/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders the main app shell', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await dotenv.load(fileName: '.env', isOptional: true);

    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Aprende'), findsWidgets);
    expect(find.text('Tests'), findsOneWidget);
    expect(find.text('Notas'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
  });
}
