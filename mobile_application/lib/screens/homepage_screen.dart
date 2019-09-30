import 'package:flutter/material.dart';

import '../widgets/custom_alert_dialog.dart';
import '../widgets/phone/explore_screen_widgets.dart' as phone;
import 'settings_screen.dart';

class HomepageScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  @override
  Widget build(BuildContext context) {
    var isSmartPhone = MediaQuery.of(context).size.shortestSide < 600;

    return Scaffold(
      //TODO remove appbar!

      body: FutureBuilder(
        //TODO update with correct future that fetches the data for the explore
        future: Future.delayed(Duration(milliseconds: 50)),
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

          return isSmartPhone
              //SmartPhone case
              ? HomepageWidget<phone.InfoBarWidget, phone.ExploreBodyWidget>(
                  infoWidgetCreator: () => phone.InfoBarWidget(),
                  exploreWidgetCreator: () => phone.ExploreBodyWidget(),
                )
              //Tablet case
              : HomepageWidget<phone.InfoBarWidget, phone.ExploreBodyWidget>(
                  infoWidgetCreator: () => phone.InfoBarWidget(),
                  exploreWidgetCreator: () => phone.ExploreBodyWidget(),
                );
        },
      ),
    );
  }
}

typedef S ItemCreator<S>();

class HomepageWidget<I extends Widget, E extends Widget>
    extends StatelessWidget {
  final ItemCreator<I> infoWidgetCreator;
  final ItemCreator<E> exploreWidgetCreator;

  HomepageWidget({
    @required this.infoWidgetCreator,
    @required this.exploreWidgetCreator,
  })  : assert(infoWidgetCreator != null),
        assert(exploreWidgetCreator != null);

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
                  Flexible(
                    fit: FlexFit.tight,
                    child: infoWidgetCreator(),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 6,
                    child: exploreWidgetCreator(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
