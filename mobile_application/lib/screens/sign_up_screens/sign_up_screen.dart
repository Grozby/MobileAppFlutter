import 'package:flutter/material.dart';

import '../../models/users/user.dart';
import '../../widgets/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  static const routeName = '/sign-up';

  @override
  Widget build(BuildContext context) {
    final userType = ModalRoute.of(context).settings.arguments as User;
    final mediaQuery = MediaQuery.of(context);
    final scrollController = ScrollController();
    final appBar = AppBar(
      backgroundColor: userType.color,
      centerTitle: true,
      title: const Text('Sign Up'),
    );
    final heightScreen = (mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top);
    final form = SignUpForm(
      userType: userType,
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
