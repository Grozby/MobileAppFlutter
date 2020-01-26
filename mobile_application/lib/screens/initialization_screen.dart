import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exceptions/no_internet_exception.dart';
import '../providers/theming/theme_provider.dart';
import '../providers/user/user_data_provider.dart';
import '../widgets/general/button_styled.dart';
import '../widgets/general/custom_alert_dialog.dart';
import '../widgets/general/image_wrapper.dart';

class InitializationScreen extends StatefulWidget {
  static const routeName = '/initialize';

  @override
  _InitializationScreenState createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  bool _isSending = false;

  void sendSelectKindRequest(BuildContext context, UserKind userKind) async {
    setState(() => _isSending = true);
    try {
      await Provider.of<UserDataProvider>(context, listen: false)
          .selectUserKind(userKind);
      Navigator.of(context).pushReplacementNamed("/");
    } catch (e) {
      Future.delayed(
        Duration.zero,
        () => showErrorDialog(
          context,
          e is NoInternetException
              ? e.getMessage()
              : "Coudln't validate your request.",
        ),
      );
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: FractionallySizedBox(
                      heightFactor: 0.25,
                      child: ImageWrapper(
                        assetPath: AssetImages.logo,
                        boxFit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    "Welcome to RyFy!",
                    style: Theme.of(context).textTheme.display2,
                  ),
                  const SizedBox(height: 8),
                  const Text("Select how you want to register."),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ButtonStyled(
                    text: "Mentee",
                    color: ThemeProvider.menteeColor,
                    fractionalWidthDimension: 0.8,
                    onPressFunction: !_isSending
                        ? () => sendSelectKindRequest(context, UserKind.Mentee)
                        : () {},
                  ),
                ),
                Expanded(
                  child: ButtonStyled(
                    text: "Mentor",
                    color: ThemeProvider.mentorColor,
                    fractionalWidthDimension: 0.8,
                    onPressFunction: !_isSending
                        ? () => sendSelectKindRequest(context, UserKind.Mentor)
                        : () {},
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: _isSending ? CircularProgressIndicator() : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
