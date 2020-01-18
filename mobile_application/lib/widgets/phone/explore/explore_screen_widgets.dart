import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/utility/available_sizes.dart';
import '../../../providers/explore/card_provider.dart';
import '../../../providers/user/user_data_provider.dart';
import '../../../screens/messages_screen.dart';
import '../../../screens/user_profile_screen.dart';
import '../../../widgets/general/image_wrapper.dart';
import 'circular_button.dart';
import 'explore_card.dart';

class InfoBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(
          width: constraints.maxWidth * 0.85,
          child: Column(
            children: <Widget>[
              const Flexible(
                flex: 2,
                child: const Center(),
              ),
              Flexible(
                flex: 3,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Consumer<UserDataProvider>(
                        builder: (context, userProvider, child) {
                          return CircularButton(
                            assetPath: AssetImages.USER,
                            imageUrl: userProvider.user.pictureUrl,
                            alignment: Alignment.centerLeft,
                            onPressFunction: () => goToProfilePage(context),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Explore",
                          style: Theme.of(context).textTheme.display3,
                        ),
                      ),
                      flex: 2,
                    ),
                    Expanded(
                      child: CircularButton(
                        assetPath: AssetImages.MESSAGE,
                        alignment: Alignment.centerRight,
                        onPressFunction: () => goToMessages(context),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Consumer<UserDataProvider>(
                    builder: (context, userData, child) {
                      return Text(
                        userData.behavior.remainingTokensString,
                        style: Theme.of(context).textTheme.display1.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                      );
                    },
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
    Navigator.of(context).pushNamed(MessagesScreen.routeName);
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
          controller: pageController,
          scrollDirection: Axis.horizontal,
          itemCount: cardProvider.numberAvailableUsers,
          itemBuilder: (BuildContext context, int index) {
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
                    model: AvailableSizes(constraints.minHeight),
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
