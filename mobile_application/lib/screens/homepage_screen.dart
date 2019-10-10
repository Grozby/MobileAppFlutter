import 'package:flutter/material.dart';
import 'package:mobile_application/models/exceptions/no_internet_exception.dart';
import 'package:mobile_application/providers/explore/card_provider.dart';
import 'package:mobile_application/providers/user/user_data_provider.dart';
import 'package:mobile_application/widgets/general/button_styled.dart';
import 'package:mobile_application/widgets/general/custom_alert_dialog.dart';
import 'package:mobile_application/widgets/general/no_internet_connection.dart';
import 'package:mobile_application/widgets/transition/loading_animated.dart';
import 'package:provider/provider.dart';

import '../widgets/phone/explore/explore_screen_widgets.dart' as phone;

class HomepageScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomepageScreen();

  @override
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var isSmartPhone = mediaQuery.size.shortestSide < 600;
    var keyboardHeight = mediaQuery.viewInsets.bottom;

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
      body: isSmartPhone
          ? HomepageWidget<phone.InfoBarWidget, phone.ExploreBodyWidget>(
              infoWidgetCreator: () => phone.InfoBarWidget(),
              exploreWidgetCreator: () => phone.ExploreBodyWidget(),
              keyboardHeight: keyboardHeight,
            )
          : HomepageWidget<phone.InfoBarWidget, phone.ExploreBodyWidget>(
              infoWidgetCreator: () => phone.InfoBarWidget(),
              exploreWidgetCreator: () => phone.ExploreBodyWidget(),
              keyboardHeight: keyboardHeight,
            ),
    );
  }
}

typedef S ItemCreator<S>();

class HomepageWidget<I extends Widget, E extends Widget>
    extends StatefulWidget {
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
  _HomepageWidgetState createState() => _HomepageWidgetState();
}

class _HomepageWidgetState extends State<HomepageWidget>
    with SingleTickerProviderStateMixin {
  /// This is the future used for loading the user information in the explore section.
  /// At first, we use a placeholder future, as the real future we will use for
  /// the FutureBuilder is contained inside the [UserDataProvider]. To do so,
  /// we initialize it inside the [initState] with a small gimmick.
  Future _loadExploreSection = Future.delayed(Duration(milliseconds: 1000));
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);

    ///Initialization of the future for [FutureBuilder]
    Future.delayed(Duration.zero, () {
      UserDataProvider userDataProvider = Provider.of<UserDataProvider>(
        context,
        listen: false,
      );
      CardProvider cardProvider = Provider.of<CardProvider>(
        context,
        listen: false,
      );

      setState(() {
        _loadExploreSection = Future.wait([
          userDataProvider.loadUserData(),
          cardProvider.loadCardProvider(),
        ]);
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadExploreSection,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: const LoadingAnimated(),
          );
        }

        if (snapshot.hasError) {
          if(snapshot.error is NoInternetException){
            Future.delayed(
              Duration.zero,
                  () => showErrorDialog(context, "Something went wrong..."),
            );
            return const NoInternetConnection();
          }

          Future.delayed(
            Duration.zero,
            () => showErrorDialog(context, "Something went wrong..."),
          );
          return const Center();
        }

        controller.forward();

        return SafeArea(
          child: FadeTransition(
            opacity: animation,
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                return SingleChildScrollView(
                  child: Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight + widget.keyboardHeight,
                    child: Column(
                      children: <Widget>[
                        Flexible(
                          fit: FlexFit.tight,
                          child: widget.infoWidgetCreator(),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 6,
                          child: widget.exploreWidgetCreator(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
