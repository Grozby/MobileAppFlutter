import 'package:flutter/material.dart';
import 'package:mobile_application/widgets/custom_alert_dialog.dart';

import 'settings_screen.dart';

class HomepageScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Ryfy'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.routeName),
          ),
        ],
      ),
      body: FutureBuilder(
        //TODO update with correct future that fetches the data
        future: Future.delayed(Duration(seconds: 1)),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            Future.delayed(
              Duration.zero,
                  () => showErrorDialog(context, "Something went wrong..."),
            );
          }

          return HomepageWidget();
        },
      ),
    );
  }
}

class HomepageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return SingleChildScrollView(
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Column(
                children: <Widget>[
                  InfoBarWidget(),
                  ExploreBodyWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class ExploreBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        color: Colors.red,
        child: Center(
          child: Text("Card"),
        ),
      ),
      flex: 4,
    );
  }
}


class InfoBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      child: Column(
        children: <Widget>[
          Flexible(
            child: Container(),
            flex: 2,
          ),
          Flexible(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FractionallySizedBox(
                    widthFactor: 0.45,
                    child: Center(
                      child: Image.asset("assets/images/user.png"),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Explore",
                      style: Theme
                          .of(context)
                          .textTheme
                          .display1,
                    ),
                  ),
                  flex: 3,
                ),
                Expanded(
                  child: FractionallySizedBox(
                    widthFactor: 0.45,
                    child: Center(
                      child: Image.asset("assets/images/message.png"),
                    ),
                  ),
                ),
              ],
            ),
            flex: 2,
          ),
          Flexible(
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                "You have 3 tokens left.",
                style: Theme
                    .of(context)
                    .textTheme
                    .display2,
              ),
            ),
            flex: 3,
          ),
        ],
      ),
    );
  }
}
