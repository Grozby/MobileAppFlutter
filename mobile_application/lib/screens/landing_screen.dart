import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../providers/authentication/authentication_provider.dart';
import '../providers/theming/theme_provider.dart';
import '../widgets/button_styled.dart';
import 'login_screen.dart';
import 'sign_up_screens/sign_up_choice_screen.dart';

class LandingScreen extends StatefulWidget {
  static const routeName = '/landing';

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  OverlayEntry _overlayEntry;
  AuthenticationProvider _authenticationProvider;
  Completer<WebViewController> _webViewController =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _authenticationProvider =
          Provider.of<AuthenticationProvider>(context, listen: true);
    });
  }

  OverlayEntry _createOverlay(String authenticationUrl) {
    return OverlayEntry(builder: (BuildContext ctx) {
      return SafeArea(
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                _webViewController = Completer<WebViewController>();
                _overlayEntry.remove();
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: Container(
                  color: Colors.grey.shade200.withOpacity(0.2),
                ),
              ),
            ),
            LayoutBuilder(
              builder: (BuildContext ctx, BoxConstraints constraints) {
                return Center(
                  child: Container(
                    height: constraints.maxHeight * 0.7,
                    width: constraints.maxWidth * 0.8,
                    child: WebView(
                      initialUrl: authenticationUrl,

                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController controller) {
                        _webViewController.complete(controller);
                      },
                    ),
//                    child: FutureBuilder(
//                      future: authenticationRequest,
//                      builder:
//                          (BuildContext context, AsyncSnapshot snapshot) {
//                            if (snapshot.connectionState == ConnectionState.waiting) {
//                              return Center(
//                                child: CircularProgressIndicator(),
//                              );
//                            }
//
//                            if (snapshot.hasError) {
//                              final exception = snapshot.error as LoginException;
//                              if (snapshot.error.runtimeType == LoginException) {
//                                Future.delayed(
//                                  Duration.zero,
//                                      () => showErrorDialog(context, exception.getMessage()),
//                                );
//                              }
//                              return Container();
////                              final exception = snapshot.error as LoginException;
////                              if (snapshot.error.runtimeType == LoginException) {
////                                Future.delayed(
////                                  Duration.zero,
////                                      () => showErrorDialog(context, exception.getMessage()),
////                                );
////                              } else {
////                                exception.updateLoginForm(loginForm);
////                              }
////                              widget.isSendingRequest = false;
////                              return buildForm();
//                            }
//
//                            //If we have successfully logged in, we go back to the homepage.
//                            return Container(child: Text(snapshot.data),);
//                          },
//                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ThemeProvider.primaryColor,
        title: const Text('Ryfy'),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Meet your friend at COMPANY',
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(),
              ),
              Expanded(
                child: ButtonStyled(
                  dimensionButton: 10,
                  text: 'Sign Up',
                  onPressFunction: () {
                    Navigator.of(context).pushNamed(
                      SignUpChoiceScreen.routeName,
                    );
                  },
                  color: ThemeProvider.primaryColor,
                ),
              ),
              Expanded(
                child: ButtonStyled(
                  dimensionButton: 10,
                  text: 'Login with Google',
                  onPressFunction: () {
                    _overlayEntry = _createOverlay(
                        _authenticationProvider.loginWithGoogleUrl());
                    Overlay.of(context).insert(_overlayEntry);
                  },
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: ButtonStyled(
                  dimensionButton: 10,
                  text: 'Login with LinkedIn',
                  onPressFunction: () {},
                  color: Colors.blueAccent,
                ),
              ),
              Expanded(
                child: ButtonStyled(
                  dimensionButton: 10,
                  text: 'Login',
                  onPressFunction: () {
                    Navigator.of(context).pushNamed(
                      LoginScreen.routeName,
                    );
                  },
                  color: ThemeProvider.loginButtonColor,
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
