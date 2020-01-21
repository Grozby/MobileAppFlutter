import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/overglow_less_scroll_behavior.dart';
import '../providers/explore/card_provider.dart';
import '../providers/user/user_data_provider.dart';
import '../widgets/general/loading_error.dart';
import '../widgets/general/refresh_content_widget.dart';
import '../widgets/phone/explore/explore_screen_widgets.dart' as phone;
import '../widgets/transition/loading_animated.dart';

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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return ScrollConfiguration(
              behavior: OverglowLessScrollBehavior(),
              child: RefreshWidget(
                builder: (refreshCompleted) {
                  return isSmartPhone
                      ? HomepageWidget(
                          infoWidget: phone.InfoBarWidget(),
                          exploreWidget: phone.ExploreBodyWidget(),
                          keyboardHeight: keyboardHeight,
                          maxHeight: constraints.maxHeight,
                          maxWidth: constraints.maxWidth,
                          refreshCompleted: refreshCompleted,
                        )
                      : HomepageWidget(
                          infoWidget: phone.InfoBarWidget(),
                          exploreWidget: phone.ExploreBodyWidget(),
                          keyboardHeight: keyboardHeight,
                          maxHeight: constraints.maxHeight,
                          maxWidth: constraints.maxWidth,
                          refreshCompleted: refreshCompleted,
                        );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class HomepageWidget extends StatefulWidget {
  final Widget infoWidget;
  final Widget exploreWidget;

  /// This keyboard height is needed as we are using a layout builder.
  /// Whenever the keyboard is shown, the layout builder will detect that the
  /// available size on the screen as reduce, therefore will try to size the
  /// widget accordingly. Unfortunately, we can't detect from the context of
  /// this widget. Therefore, we will obtain this information from the
  /// [MediaQuery.of(context).viewInsets.bottom] of the parent of this
  /// widget.
  final double keyboardHeight;
  final double maxHeight, maxWidth;

  final Function refreshCompleted;

  HomepageWidget({
    @required this.infoWidget,
    @required this.exploreWidget,
    @required this.keyboardHeight,
    @required this.maxHeight,
    @required this.maxWidth,
    @required this.refreshCompleted,
  })  : assert(infoWidget != null),
        assert(exploreWidget != null),
        assert(keyboardHeight != null);

  @override
  _HomepageWidgetState createState() => _HomepageWidgetState();
}

class _HomepageWidgetState extends State<HomepageWidget>
    with SingleTickerProviderStateMixin {
  /// This is the future used for loading the user information in the explore section.
  /// The real future we will use for the FutureBuilder is contained inside
  /// the [UserDataProvider].
  Future _loadExploreSection;
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

    loadExploreSection();
  }

  void loadExploreSection() {
    _loadExploreSection = Future.wait([
      //TODO may implement a reduced version
      Provider.of<UserDataProvider>(context, listen: false).loadUserData(),
      Provider.of<CardProvider>(context, listen: false).loadCardProvider(),
    ]);
  }

  @override
  void didUpdateWidget(HomepageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// Used to distinguish whether the RefreshWidget was the one to call the
    /// one to refresh the widget.
    if(oldWidget.refreshCompleted != this.widget.refreshCompleted){
      loadExploreSection();
    }
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
          widget.refreshCompleted();
          return LoadingError(
            exception: snapshot.error,
            retry: () => setState(() {
              loadExploreSection();
            }),
            buildContext: context,
          );
        }

        controller.forward();
        widget.refreshCompleted();

        return FadeTransition(
          opacity: animation,
          child: Container(
            width: widget.maxWidth,
            height: widget.maxHeight + widget.keyboardHeight,
            child: Column(
              children: <Widget>[
                Flexible(
                  fit: FlexFit.tight,
                  child: widget.infoWidget,
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 6,
                  child: widget.exploreWidget,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
