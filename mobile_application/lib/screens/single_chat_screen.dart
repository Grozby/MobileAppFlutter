import 'package:flutter/material.dart';

class SingleChatArguments {
  final String id;

  SingleChatArguments(this.id);
}

class SingleChatScreen extends StatefulWidget {
  static const routeName = '/singlechat';

  final SingleChatArguments arguments;

  SingleChatScreen(this.arguments);

  @override
  _SingleChatScreenState createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
