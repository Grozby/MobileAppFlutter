import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exceptions/login/login_exception.dart';
import '../models/login/login_form_model.dart';
import '../providers/authentication/authentication_provider.dart';
import '../screens/login_screen.dart';
import 'button_styled.dart';
import 'custom_alert_dialog.dart';
import 'custom_text_form.dart';

class LoginForm extends StatefulWidget {
  final ScrollController scrollController;
  bool isSendingRequest = false;

  LoginForm({
    this.scrollController,
  });

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  LoginFormModel loginForm;
  FocusNode _focusNodeEmail = FocusNode();
  FocusNode _focusNodePassword = FocusNode();

  Future<void> _futureBuilder;

  @override
  void initState() {
    super.initState();
    loginForm = LoginFormModel();

    _futureBuilder = null;
  }

  @override
  void dispose() {
    super.dispose();
    loginForm.email.dispose();
    loginForm.password.dispose();

    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
  }

  Future<void> validateFormAndLogin() async {
    widget.isSendingRequest = true;
    final authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: true);
    final isValid = _form.currentState.validate();
    if (!isValid) {
      widget.isSendingRequest = false;
      return;
    }

    _form.currentState.save();

    setState(() {
      _futureBuilder = authenticationProvider.authenticateWithCredentials(
        loginForm.email.text,
        loginForm.password.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureBuilder,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.connectionState == ConnectionState.none) {
          widget.isSendingRequest = false;
          return buildForm();
        }

        if (snapshot.hasError) {
          final exception = snapshot.error as LoginException;
          if (snapshot.error.runtimeType == LoginException) {
            Future.delayed(
              Duration.zero,
              () => showErrorDialog(context, exception.getMessage()),
            );
          } else {
            exception.updateLoginForm(loginForm);
          }
          widget.isSendingRequest = false;
          return buildForm();
        }

        //TODO
        widget.isSendingRequest = false;
        Future.delayed(
          Duration.zero,
              () => Navigator.of(context).pushNamedAndRemoveUntil(
                Navigator.defaultRouteName,
                ModalRoute.withName(""),
              )
          );
        return Container();
      },
    );
  }

  Widget buildForm() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Login',
              style: Theme.of(context).textTheme.title,
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Expanded(
                flex: 10,
                child: Form(
                  key: _form,
                  child: ListView(
                    children: <Widget>[
                      CustomTextForm(
                        controller: loginForm.email,
                        focusNode: _focusNodeEmail,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                          context,
                          _focusNodeEmail,
                          _focusNodePassword,
                        ),
                        color: Theme.of(context).primaryColor,
                        labelText: 'Email',
                        validator: (currentEmail) {
                          if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(currentEmail)) {
                            return 'Insert a valid email.';
                          }

                          return null;
                        },
                        errorText: loginForm.errorEmail,
                        inputAction: TextInputAction.next,
                      ),
                      CustomTextForm(
                        controller: loginForm.password,
                        focusNode: _focusNodePassword,
                        onFieldSubmitted: (_) {
                          _focusNodePassword.unfocus();
                          validateFormAndLogin();
                        },
                        color: Theme.of(context).primaryColor,
                        labelText: 'Password',
                        validator: (currentPassword) {
                          if (currentPassword.length < 8) {
                            return 'The password must be at least 8 characters.';
                          }

                          return null;
                        },
                        errorText: loginForm.errorPassword,
                        inputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ButtonStyled(
            dimensionButton: 10,
            text: 'Login',
            onPressFunction: validateFormAndLogin,
          ),
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Container(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  LoginScreen.routeName,
                  ModalRoute.withName(Navigator.defaultRouteName),
                );
              },
              child: Text(
                'Don\'t have an account? Register',
              ),
            ),
          ),
        )
      ],
    );
  }
}

void _fieldFocusChange(
  BuildContext context,
  FocusNode currentFocus,
  FocusNode nextFocus,
) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}
