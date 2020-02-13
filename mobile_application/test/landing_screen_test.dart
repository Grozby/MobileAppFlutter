import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:ryfy/providers/authentication/authentication_provider.dart';
import 'package:ryfy/screens/landing_screen.dart';

class MockAuthenticationProvider extends Mock
    implements AuthenticationProvider {}

void main() {
  testWidgets('Landing Screen test', (WidgetTester tester) async {
    final mockedAuthenticationProvider = MockAuthenticationProvider();
    // Create the widget by telling the tester to build it.
    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(),
      child: MaterialApp(
        home: ChangeNotifierProvider<AuthenticationProvider>.value(
          value: MockAuthenticationProvider(),
          child: LandingScreen(),
        ),
      ),
    ));

    // Create the Finders.
    final loginButtonFinder = find.text('Login');
    final googleButtonFinder = find.text('Login with Google');

    // Use the `findsOneWidget` matcher provided by flutter_test to
    // verify that the Text widgets appear exactly once in the widget tree.
    expect(loginButtonFinder, findsOneWidget);
    expect(googleButtonFinder, findsOneWidget);
  });
}
