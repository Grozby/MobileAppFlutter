import 'package:flutter/material.dart';

import '../widgets/general/back_button_customized.dart';
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
                      const Flexible(
                        fit: FlexFit.loose,
                        child: const Align(
                          alignment: Alignment.bottomLeft,
                          child: const BackButtonCustomized(),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        flex: 10,
                        child: form,
                      ),
                      const Flexible(
                        fit: FlexFit.loose,
                        child: const Center(),
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
