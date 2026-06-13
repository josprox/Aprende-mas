import 'package:aprende_mas/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('renders the main app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Biblioteca'), findsWidgets);
    expect(find.text('Aprende'), findsOneWidget);
    expect(find.text('Tests'), findsOneWidget);
    expect(find.text('Notas'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
  });
}
