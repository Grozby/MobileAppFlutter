import 'package:flutter/material.dart';

import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final scrollController = ScrollController();
    final appBar = AppBar(
      centerTitle: true,
      title: const Text('Login'),
    );
    final heightScreen = (mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top);
    final form = LoginForm(
      scrollController: scrollController,
    );

    return WillPopScope(
      onWillPop: () async => !form.isSendingRequest,
      child: Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          controller: scrollController,
          child: Container(
            height: (heightScreen),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  flex: 10,
                  child: form,
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
