import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exceptions/registration/registration_exception.dart';
import '../models/registration/registration_form.dart';
import '../models/users/user.dart';
import '../providers/authentication/authentication_provider.dart';
import 'button_styled.dart';

class SignUpForm extends StatefulWidget {
  final User userType;
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
  RegistrationForm registrationForm;
  FocusNode _focusNodeName = FocusNode();
  FocusNode _focusNodeSurname = FocusNode();
  FocusNode _focusNodeEmail = FocusNode();
  FocusNode _focusNodePassword = FocusNode();
  FocusNode _focusNodeCompany = FocusNode();

  Future<bool> _futureBuilder;

  @override
  void initState() {
    super.initState();
    registrationForm = RegistrationForm();

    _futureBuilder = Future<bool>.delayed(Duration.zero, () => false);
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
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          final exception = snapshot.error as RegistrationException;
          exception.updateRegistrationForm(registrationForm);
          widget.isSendingRequest = false;
          return buildForm();
        }

        //If true is returned, we have successfully registered.
        if (snapshot.data) {
          widget.isSendingRequest = false;

          return Center(
            child: Text('Successful!'),
          );
        } else {
          widget.isSendingRequest = false;
          return buildForm();
        }
      },
    );
  }

  Widget buildForm() {
    return Column(
      children: <Widget>[
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
                        controller: registrationForm.name,
                        focusNode: _focusNodeName,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                          context,
                          _focusNodeName,
                          _focusNodeSurname,
                        ),
                        userType: widget.userType,
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
                        userType: widget.userType,
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
                        userType: widget.userType,
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
                        userType: widget.userType,
                        labelText: 'Password',
                        validator: (currentPassword) {
                          if (currentPassword.length < 8) {
                            return 'The password must be at least 8 characters.';
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
                              userType: widget.userType,
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
                          : Container(),
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
            text: 'Sign Up',
            onPressFunction: validateFormAndSendRegistration,
            color: widget.userType.color,
          ),
        ),
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

class CustomTextForm extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final User userType;
  final Function validator;
  final String errorText;
  final FocusNode focusNode;
  final Function onFieldSubmitted;
  final TextInputAction inputAction;

  CustomTextForm({
    @required this.controller,
    @required this.labelText,
    @required this.userType,
    @required this.validator,
    @required this.focusNode,
    @required this.onFieldSubmitted,
    @required this.inputAction,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(8),
          child: Text(
            labelText,
            style: Theme.of(context)
                .textTheme
                .subhead
                .copyWith(color: Colors.grey.shade600),
          ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: labelText == 'Password',
          keyboardType: labelText == 'Email'
              ? TextInputType.emailAddress
              : TextInputType.text,
          textInputAction: inputAction,
          style: Theme.of(context).textTheme.subhead,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            errorText: errorText,
            contentPadding: EdgeInsets.all(10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: userType.color),
              borderRadius: BorderRadius.circular(10),
            ),
            focusColor: userType.color,
          ),
        ),
      ],
    );
  }
}
