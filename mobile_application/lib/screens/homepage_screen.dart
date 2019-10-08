import 'package:flutter/material.dart';
import '../providers/explore/card_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_alert_dialog.dart';
import '../widgets/phone/explore/explore_screen_widgets.dart' as phone;

class HomepageScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  Future _loadExploreCards = Future.delayed(Duration(milliseconds: 1000));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      CardProvider cardProvider = Provider.of<CardProvider>(
        context,
        listen: false,
      );
      setState(() {
        _loadExploreCards = cardProvider.loadCardProvider();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var isSmartPhone = mediaQuery.size.shortestSide < 600;
    var keyboardHeight = mediaQuery.viewInsets.bottom;

    CardProvider cardProvider = Provider.of<CardProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      //TODO remove appbar!
//      appBar: AppBar(
//        centerTitle: true,
//        title: Text('Ryfy'),
//        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.settings),
//            onPressed: () =>
//                Navigator.of(context).pushNamed(SettingsScreen.routeName),
//          ),
//        ],
//      ),
      body: FutureBuilder(
        //TODO update with correct future that fetches the data for the explore
        future: _loadExploreCards,
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
                  keyboardHeight: keyboardHeight,
                )
              //Tablet case
              : HomepageWidget<phone.InfoBarWidget, phone.ExploreBodyWidget>(
                  infoWidgetCreator: () => phone.InfoBarWidget(),
                  exploreWidgetCreator: () => phone.ExploreBodyWidget(),
                  keyboardHeight: keyboardHeight,
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
  /// This keyboard height is needed as we are using a layout builder.
  /// Whenever the keyboard is shown, the layout builder will detect that the
  /// available size on the screen as reduce, therefore will try to size the
  /// widget accordly. Unfortunately, we can't detect from the context of
  /// this widget. Therefore, we will obtain this information from the
  /// [MediaQuery.of(context).viewInsets.bottom] of the parent of this
  /// widget.
  final double keyboardHeight;

  HomepageWidget({
    @required this.infoWidgetCreator,
    @required this.exploreWidgetCreator,
    @required this.keyboardHeight,
  })  : assert(infoWidgetCreator != null),
        assert(exploreWidgetCreator != null),
        assert(keyboardHeight != null);

  @override
  Widget build(BuildContext context) {
    print("height ${MediaQuery.of(context).viewInsets.bottom}");
    return SafeArea(
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return SingleChildScrollView(
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight + keyboardHeight,
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
