import 'package:flutter/material.dart';

import '../widgets/back_button_customized.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final form = LoginForm(
      scrollController: scrollController,
    );

    return WillPopScope(
      onWillPop: () async => !form.isSendingRequest,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: BackButtonCustomized(),
                          ),
                        ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
