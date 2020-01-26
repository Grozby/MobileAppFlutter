import 'package:flutter/material.dart';

import '../../models/registration/user_registration.dart';
import '../../widgets/general/back_button_customized.dart';
import '../../widgets/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  static const routeName = '/sign-up';

  @override
  Widget build(BuildContext context) {
    final userType =
        ModalRoute.of(context).settings.arguments as UserRegistration;
    final scrollController = ScrollController();
    final form = SignUpForm(
      userType: userType,
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
                          child: const Align(
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
