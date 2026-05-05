import 'package:flutter_test/flutter_test.dart';
import 'package:lostlink_app/app.dart';
import 'package:provider/provider.dart';
import 'package:lostlink_app/services/auth_service.dart';
import 'package:lostlink_app/services/item_service.dart';
import 'package:lostlink_app/services/claim_service.dart';

void main() {
  testWidgets('LostLink app starts on login screen', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => ItemService()),
          ChangeNotifierProvider(create: (_) => ClaimService()),
        ],
        child: const LostLinkApp(),
      ),
    );

    expect(find.text('LostLink'), findsOneWidget);
  });
}
