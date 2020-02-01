import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile_application/providers/chat/chat_provider.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/utility/available_sizes.dart';
import '../../../providers/explore/card_provider.dart';
import '../../../providers/user/user_data_provider.dart';
import '../../../screens/chat_screen.dart';
import '../../../screens/user_profile_screen.dart';
import '../../../widgets/general/image_wrapper.dart';
import 'circular_button.dart';
import 'explore_card.dart';

class InfoBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Provider.of<ThemeProvider>(context).getTheme();

    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(
          width: constraints.maxWidth * 0.85,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Consumer<UserDataProvider>(
                  builder: (context, userProvider, child) {
                    return CircularButton(
                      assetPath: AssetImages.user,
                      imageUrl: userProvider?.user?.pictureUrl ?? null,
                      alignment: Alignment.centerLeft,
                      width: 55,
                      height: 55,
                      onPressFunction: () => goToProfilePage(context),
                    );
                  },
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "Explore",
                    style: themeData.textTheme.display3,
                  ),
                ),
                flex: 2,
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.deferToChild,
                  child: Stack(
                    children: <Widget>[
                      CircularButton(
                        assetPath: AssetImages.message,
                        alignment: Alignment.centerRight,
                        width: 55,
                        height: 55,
                        onPressFunction: () => goToMessages(context),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: StreamBuilder<int>(
                            stream: Provider.of<ChatProvider>(context)
                                .numberUnreadMessagesStream,
                            builder: (context, snapshot) {
                              return snapshot.hasData && snapshot.data != 0
                                  ? Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: themeData.primaryColor,
                                      ),
                                      child: AutoSizeText(
                                        "${snapshot.data}",
                                        style: themeData.textTheme.title
                                            .copyWith(color: Colors.white),
                                        maxLines: 1,
                                      ),
                                    )
                                  : Center();
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void goToProfilePage(BuildContext context) {
    Navigator.of(context).pushNamed(UserProfileScreen.routeName);
  }

  void goToMessages(BuildContext context) {
    Navigator.of(context).pushNamed(ChatListScreen.routeName);
  }
}

///
/// Widget that shows all the available user cards. It animates the swipe
/// in and out between each card.
///
class ExploreBodyWidget extends StatefulWidget {
  @override
  _ExploreBodyWidgetState createState() => _ExploreBodyWidgetState();
}

class _ExploreBodyWidgetState extends State<ExploreBodyWidget>
    with SingleTickerProviderStateMixin {
  double heightFraction = 0.9;
  int currentIndex = 0;
  bool _isForward = false;
  PageController pageController = PageController(viewportFraction: 0.9);
  Animation<double> animation;
  AnimationController controllerAnimation;

  @override
  void initState() {
    super.initState();

    /// Animation stuff
    pageController.addListener(updatePage);
    controllerAnimation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    animation = Tween<double>(
      begin: heightFraction,
      end: 1,
    ).animate(controllerAnimation);
  }

  @override
  void dispose() {
    pageController.removeListener(updatePage);
    pageController.dispose();
    controllerAnimation.dispose();
    super.dispose();
  }

  ///Animation methods
  void updatePage() {
    int nextIndex = pageController.page.round();
    if (currentIndex != nextIndex) {
      setState(() {
        currentIndex = nextIndex;
      });
      callAnimatorController();
    }
  }

  void callAnimatorController() {
    if (_isForward) {
      controllerAnimation.reverse();
    } else {
      controllerAnimation.forward();
    }
    _isForward = !_isForward;
  }

  double get animationValue {
    if (_isForward) {
      return animation.value;
    } else {
      return 1 + heightFraction - animation.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      CardProvider cardProvider = Provider.of<CardProvider>(context);

      return Container(
        constraints: BoxConstraints(
          maxHeight: constraints.minHeight,
          maxWidth: constraints.maxWidth,
        ),
        child: PageView.builder(
          physics: const BouncingScrollPhysics(),
          controller: pageController,
          scrollDirection: Axis.horizontal,
          itemCount: cardProvider.numberAvailableUsers,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: controllerAnimation,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: constraints.minHeight,
                ),
                child: SingleChildScrollView(
                  primary: false,
                  physics: const ScrollPhysics(),
                  child: ScopedModel<AvailableSizes>(
                    model: AvailableSizes(height: constraints.minHeight),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ExploreCard(indexUser: index),
                    ),
                  ),
                ),
              ),
              builder: (_, child) {
                return Transform.scale(
                  alignment: index > currentIndex
                      ? Alignment.centerLeft
                      : (index < currentIndex
                          ? Alignment.centerRight
                          : Alignment.center),
                  scale: index == currentIndex
                      ? (controllerAnimation.isAnimating ? animationValue : 1)
                      : (controllerAnimation.isAnimating
                          ? 1 + heightFraction - animationValue
                          : heightFraction),
                  child: child,
                );
              },
            );
          },
        ),
      );
    });
  }
}
