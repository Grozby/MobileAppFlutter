import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exceptions/no_internet_exception.dart';
import '../models/exceptions/registration/registration_exception.dart';
import '../models/registration/sign_up_form_model.dart';
import '../models/registration/user_registration.dart';
import '../providers/authentication/authentication_provider.dart';
import '../providers/theming/theme_provider.dart';
import '../screens/login_screen.dart';
import 'general/button_styled.dart';
import 'general/custom_alert_dialog.dart';
import 'general/custom_text_form.dart';

class SignUpForm extends StatefulWidget {
  final UserRegistration userType;
  final ScrollController scrollController;
  bool isSendingRequest = false;

  SignUpForm({
    this.userType,
    this.scrollController,
  });

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  SignUpFormModel registrationForm;
  final FocusNode _focusNodeName = FocusNode();
  final FocusNode _focusNodeSurname = FocusNode();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeCompany = FocusNode();

  Future<void> _futureBuilder;

  @override
  void initState() {
    super.initState();
    registrationForm = SignUpFormModel();

    _futureBuilder = null;
  }

  @override
  void dispose() {
    super.dispose();
    registrationForm.name.dispose();
    registrationForm.surname.dispose();
    registrationForm.email.dispose();
    registrationForm.password.dispose();
    registrationForm.company.dispose();

    _focusNodeName.dispose();
    _focusNodeSurname.dispose();
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _focusNodeCompany.dispose();
  }

  Future<void> validateFormAndSendRegistration() async {
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
      _futureBuilder = authenticationProvider.registration(
          widget.userType, registrationForm);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureBuilder,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState == ConnectionState.none) {
          widget.isSendingRequest = false;
          return buildForm();
        }

        //If some errors has been found, we display them.
        if (snapshot.hasError) {
          if (snapshot.error.runtimeType == NoInternetException) {
            Future.delayed(
              Duration.zero,
              () => showErrorDialog(
                context,
                (snapshot.error as NoInternetException).getMessage(),
              ),
            );
          } else {
            final exception = snapshot.error as RegistrationException;
            if (snapshot.error.runtimeType == RegistrationException) {
              Future.delayed(
                Duration.zero,
                () => setState(() {
                  _futureBuilder = null;
                }),
              );

              return Center();
            } else {
              exception.updateRegistrationForm(registrationForm);
            }
          }

          widget.isSendingRequest = false;
          return buildForm();
        }

        //Otherwise, everything went smoothly and the registration is
        //successful
        widget.isSendingRequest = false;

        return Column(
          children: <Widget>[
            const Expanded(
              flex: 3,
              child: Center(),
            ),
            Expanded(
              child: Container(
                child: Text(
                  'Your registration is successful!',
                  style: Theme.of(context).textTheme.title,
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Text(
                  'Proceed to login.',
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
            ),
            Expanded(
              child: ButtonStyled(
                fractionalWidthDimension: 0.833,
                text: 'Login',
                onPressFunction: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    LoginScreen.routeName,
                    ModalRoute.withName(Navigator.defaultRouteName),
                  );
                },
                color: ThemeProvider.loginButtonColor,
              ),
            ),
            const Expanded(flex: 3, child: Center())
          ],
        );
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
              'Sign up as a ${widget.userType.typeName}',
              style: Theme.of(context).textTheme.title,
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Row(
            children: <Widget>[
              const Expanded(child: Center()),
              Expanded(
                flex: 10,
                child: Form(
                  key: _form,
                  child: ListView(
                    children: <Widget>[
                      CustomTextForm(
                        controller: registrationForm.name,
                        focusNode: _focusNodeName,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                          context,
                          _focusNodeName,
                          _focusNodeSurname,
                        ),
                        color: widget.userType.color,
                        labelText: 'Name',
                        validator: (currentName) {
                          if (currentName.isEmpty) {
                            return 'Provide a valid name.';
                          }

                          return null;
                        },
                        errorText: registrationForm.errorName,
                        inputAction: TextInputAction.next,
                      ),
                      CustomTextForm(
                        controller: registrationForm.surname,
                        focusNode: _focusNodeSurname,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                          context,
                          _focusNodeSurname,
                          _focusNodeEmail,
                        ),
                        color: widget.userType.color,
                        labelText: 'Surname',
                        validator: (currentSurname) {
                          if (currentSurname.isEmpty) {
                            return 'Provide a valid surname.';
                          }

                          return null;
                        },
                        errorText: registrationForm.errorSurname,
                        inputAction: TextInputAction.next,
                      ),
                      CustomTextForm(
                        controller: registrationForm.email,
                        focusNode: _focusNodeEmail,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                          context,
                          _focusNodeEmail,
                          _focusNodePassword,
                        ),
                        color: widget.userType.color,
                        labelText: 'Email',
                        validator: (currentEmail) {
                          if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(currentEmail)) {
                            return 'Insert a valid email.';
                          }

                          return null;
                        },
                        errorText: registrationForm.errorEmail,
                        inputAction: TextInputAction.next,
                      ),
                      CustomTextForm(
                        controller: registrationForm.password,
                        focusNode: _focusNodePassword,
                        onFieldSubmitted: widget.userType.isMentor()
                            ? (_) => _fieldFocusChange(
                                  context,
                                  _focusNodePassword,
                                  _focusNodeCompany,
                                )
                            : (_) {
                                _focusNodePassword.unfocus();
                                validateFormAndSendRegistration();
                              },
                        color: widget.userType.color,
                        labelText: 'Password',
                        validator: (currentPassword) {
                          if (currentPassword.length < 8) {
                            return 'The password must be at least'
                                ' 8 characters.';
                          }

                          return null;
                        },
                        errorText: registrationForm.errorPassword,
                        inputAction: widget.userType.isMentor()
                            ? TextInputAction.next
                            : TextInputAction.done,
                      ),
                      widget.userType.isMentor()
                          ? CustomTextForm(
                              controller: registrationForm.company,
                              focusNode: _focusNodeCompany,
                              onFieldSubmitted: (_) {
                                _focusNodeCompany.unfocus();
                                validateFormAndSendRegistration();
                              },
                              color: widget.userType.color,
                              labelText: 'Company',
                              validator: (currentText) {
                                if (currentText.isEmpty) {
                                  return 'Provide a valid company.';
                                }

                                return null;
                              },
                              errorText: registrationForm.errorCompany,
                              inputAction: TextInputAction.done,
                            )
                          : const Center(),
                    ],
                  ),
                ),
              ),
              const Expanded(child: Center()),
            ],
          ),
        ),
        Expanded(
          child: ButtonStyled(
            fractionalWidthDimension: 0.833,
            text: 'Sign Up',
            onPressFunction: validateFormAndSendRegistration,
            color: widget.userType.color,
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
              child: const Text(
                'Already have an account? Log in',
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
