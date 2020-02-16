import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ryfy/models/users/mentee.dart';
import 'package:ryfy/providers/notification/notification_provider.dart';

import '../helpers/overglow_less_scroll_behavior.dart';
import '../models/exceptions/no_internet_exception.dart';
import '../providers/authentication/authentication_provider.dart';
import '../providers/chat/chat_provider.dart';
import '../providers/explore/card_provider.dart';
import '../providers/user/user_data_provider.dart';
import '../widgets/general/loading_error.dart';
import '../widgets/general/refresh_content_widget.dart';
import '../widgets/phone/explore/explore_screen_widgets.dart' as phone;
import '../widgets/transition/loading_animated.dart';
import 'initialization_screen.dart';

class SearchProvider with ChangeNotifier {
  double height = 40;
  BehaviorSubject<bool> _initializedController = BehaviorSubject<bool>();
  BehaviorSubject<String> _selectedController = BehaviorSubject<String>();
  String _selected = 'All';
  List<String> selectable = [
    'All',
    'Software Engineer',
    'Full-Stack',
    'Front-End',
    'Back-End',
    'Machine Learning',
    'Python',
    'C++',
    'iOS',
    'Android',
    'Mobile Dev.'
  ];

  SearchProvider() {
    _selectedController.sink.add(_selected);
    _initializedController.sink.add(false);
  }

  Stream<bool> get initializedStream => _initializedController.stream;

  Stream<String> get selectedStream => _selectedController.stream;

  void isInitialized() {
    _initializedController.sink.add(true);
  }

  set changeSelected(String newSelected) {
    _selected = newSelected;
    _selectedController.sink.add(_selected);
  }

  int get length => selectable.length;

  String getElement(int index) {
    return selectable[index % length];
  }

  @override
  void dispose() {
    _initializedController.close();
    _selectedController.close();
    super.dispose();
  }
}

class HomepageScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomepageScreen();

  @override
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  SearchProvider searchProvider;

  @override
  void initState() {
    super.initState();
    searchProvider = SearchProvider();
  }

  @override
  void dispose() {
    searchProvider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var isSmartPhone = mediaQuery.size.shortestSide < 600;
    var keyboardHeight = mediaQuery.viewInsets.bottom;

    return ChangeNotifierProvider<SearchProvider>.value(
      value: searchProvider,
      child: Scaffold(
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
                            searchStream: searchProvider.selectedStream,
                          )
                        : HomepageWidget(
                            infoWidget: phone.InfoBarWidget(),
                            exploreWidget: phone.ExploreBodyWidget(),
                            keyboardHeight: keyboardHeight,
                            maxHeight: constraints.maxHeight,
                            maxWidth: constraints.maxWidth,
                            refreshCompleted: refreshCompleted,
                            searchStream: searchProvider.selectedStream,
                          );
                  },
                ),
              );
            },
          ),
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

  final Stream searchStream;

  final Function refreshCompleted;

  HomepageWidget({
    @required this.infoWidget,
    @required this.exploreWidget,
    @required this.keyboardHeight,
    @required this.maxHeight,
    @required this.maxWidth,
    @required this.refreshCompleted,
    @required this.searchStream,
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
  StreamSubscription updateOnSearch;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);

    updateOnSearch = widget.searchStream.listen((_) {
      setState(() {
        loadExploreSection();
      });
    });

    loadExploreSection();
  }

  void loadExploreSection() async {
    AuthenticationProvider auth =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _loadExploreSection = Future.wait([
      //TODO may implement a reduced version
      Provider.of<UserDataProvider>(context, listen: false).loadUserData(),
      Provider.of<CardProvider>(context, listen: false).loadCardProvider(
          Provider.of<SearchProvider>(context, listen: false)._selected),
      Provider.of<ChatProvider>(context, listen: false).initializeChatProvider(
        authToken: auth.token,
        pushNotificationStream:
            NotificationProvider.notificationController.stream,
      )
    ]).catchError((err) {
      /// There may two ways this future can fail. One is provoked by
      /// [loadCardProvider]. When the user is not finalized (as when logged
      /// from Google, for example), the /explore request will fail. Therefore,
      /// we need to initialize the profile. The second option is that
      /// incorrect data have been passed to the [loadUserData], or the
      /// internet connection is missing.
      var p = Provider.of<UserDataProvider>(context, listen: false);

      if (p.behavior != null && !p.behavior.isInitialized) {
        Navigator.of(context)
            .pushReplacementNamed(InitializationScreen.routeName);
      }

      if (err is NoInternetException) {
        throw err;
      }
    });
  }

  @override
  void didUpdateWidget(HomepageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// Used to distinguish whether the RefreshWidget was the one to call the
    /// one to refresh the widget.
    if (oldWidget.refreshCompleted != widget.refreshCompleted) {
      loadExploreSection();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    updateOnSearch.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadExploreSection,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingAnimated());
        }

        if (!snapshot.hasError) {
          Provider.of<SearchProvider>(context, listen: false).isInitialized();
        }

        widget.refreshCompleted();

        /// Normal app flow. The user is logged and no confirmation is needed.
        controller.forward();

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
                if(Provider.of<UserDataProvider>(context, listen: false).user.runtimeType == Mentee)
                  const SearchBar(),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 8,
                  child: snapshot.hasError
                      ? LoadingError(
                          exception: snapshot.error,
                          retry: () => setState(loadExploreSection),
                          buildContext: context,
                        )
                      : widget.exploreWidget,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar();

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  void showSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (ctx) => SearchBarModal(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    SearchProvider searchProvider = Provider.of<SearchProvider>(context);

    return Container(
      padding: const EdgeInsets.all(8),
      child: StreamBuilder<bool>(
          stream: searchProvider.initializedStream,
          builder: (context, snapshot) => snapshot.hasData && snapshot.data
              ? InkWell(
                  onTap: () => showSelection(),
                  child: Container(
                    height: searchProvider.height,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.search),
                        const SizedBox(width: 8),
                        StreamBuilder<String>(
                            stream: searchProvider.selectedStream,
                            builder: (context, snapshot) {
                              return AutoSizeText(
                                snapshot.hasData ? snapshot.data : "",
                                style: Theme.of(context).textTheme.display2,
                                textAlign: TextAlign.center,
                              );
                            }),
                      ],
                    ),
                  ),
                )
              : Container(height: searchProvider.height)),
    );
  }
}

class SearchBarModal extends StatefulWidget {
  final BuildContext context;

  SearchBarModal(this.context);

  @override
  _SearchBarModalState createState() => _SearchBarModalState();
}

class _SearchBarModalState extends State<SearchBarModal> {
  SearchProvider searchProvider;

  @override
  Widget build(BuildContext context) {
    searchProvider ??= Provider.of<SearchProvider>(
      widget.context,
      listen: false,
    );

    return InkWell(
      child: Container(
        height: MediaQuery.of(context).size.height / 3,
        padding: const EdgeInsets.all(8.0),
        child: ScrollConfiguration(
          behavior: OverglowLessScrollBehavior(),
          child: ListView.separated(
            itemCount: searchProvider.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (_, index) => InkWell(
              child: Container(
                alignment: Alignment.center,
                child: AutoSizeText(
                  searchProvider.getElement(index),
                  style: Theme.of(context).textTheme.display1.copyWith(
                    color: Theme.of(context).textTheme.body1.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              onTap: () => setState(() {
                searchProvider.changeSelected = searchProvider.getElement(index);
                Navigator.pop(widget.context);
              }),
            ),
          ),
        ),
      ),
    );
  }
}
