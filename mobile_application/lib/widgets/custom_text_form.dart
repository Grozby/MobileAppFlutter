import 'package:flutter/material.dart';

class CustomTextForm extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Color color;
  final Function validator;
  final String errorText;
  final FocusNode focusNode;
  final Function onFieldSubmitted;
  final TextInputAction inputAction;

  CustomTextForm({
    @required this.controller,
    @required this.labelText,
    @required this.color,
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
              borderSide: BorderSide(color: color),
              borderRadius: BorderRadius.circular(10),
            ),
            focusColor: color,
          ),
        ),
      ],
    );
  }
}
