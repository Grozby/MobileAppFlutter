import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:ryfy/providers/authentication/authentication_provider.dart';
import 'package:ryfy/screens/landing_screen.dart';

class MockAuthenticationProvider extends Mock
    implements AuthenticationProvider {}

void main() {
  testWidgets('Landing Screen', (WidgetTester tester) async {
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
    final signUpButtonFinder = find.text('Sign up');
    final loginButtonFinder = find.text('Login');
    final googleButtonFinder = find.text('Login with Google');
    final animationWidgetFinder = find.byType(AnimatedCompanyNames);


    expect(signUpButtonFinder, findsOneWidget);
    expect(loginButtonFinder, findsOneWidget);
    expect(googleButtonFinder, findsOneWidget);
    expect(animationWidgetFinder, findsOneWidget);
  });
}
