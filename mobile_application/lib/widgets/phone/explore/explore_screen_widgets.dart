import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:ryfy/providers/explore/questions_provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/utility/available_sizes.dart';
import '../../../providers/chat/chat_provider.dart';
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
                    style: Theme.of(context).textTheme.display3,
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
                              .numberUnreadMessagesStream ?? null,
                          builder: (context, snapshot) {
                            return snapshot.hasData && snapshot.data != 0
                                ? Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    child: AutoSizeText(
                                      "${snapshot.data}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .title
                                          .copyWith(color: Colors.white),
                                      maxLines: 1,
                                    ),
                                  )
                                : Center();
                          },
                        ),
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
    with TickerProviderStateMixin {
  double heightFraction = 0.9;
  int currentIndex = 0;
  PageController pageController;
  Animation<double> animation;
  Widget removingWidget;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 0.9);
    pageController.addListener(updatePage);
  }

  @override
  void dispose() {
    pageController.removeListener(updatePage);
    pageController.dispose();
    super.dispose();
  }

  void updatePage() {
    int nextIndex = pageController.page.round();
    if (currentIndex != nextIndex) {
      setState(() {
        currentIndex = nextIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        CardProvider cardProvider = Provider.of<CardProvider>(context);

        return GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: constraints.minHeight,
              maxWidth: constraints.maxWidth,
            ),
            child: cardProvider.numberAvailableUsers != 0
                ? PageView.builder(
                    physics: const BouncingScrollPhysics(),
                    controller: pageController,
                    scrollDirection: Axis.horizontal,
                    itemCount: cardProvider.numberAvailableUsers,
                    itemBuilder: (context, index) => cardProvider
                                .indexToRemove !=
                            index
                        ? AnimatedBuilder(
                            animation: pageController,
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: constraints.minHeight,
                              ),
                              child: SingleChildScrollView(
                                primary: true,
                                physics: const ScrollPhysics(),
                                child: ScopedModel<AvailableSizes>(
                                  model: AvailableSizes(
                                      height: constraints.minHeight),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ExploreCard(
                                      indexUser: index,
                                      key: ValueKey(
                                        cardProvider.getUser(index).id,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            builder: (_, child) {
                              double value = 1.0;
                              if (pageController.position.haveDimensions) {
                                value = pageController.page - index;
                                value =
                                    (1 - (value.abs() * .4)).clamp(0.0, 1.0);
                              }

                              return Transform.scale(
                                alignment: index > currentIndex
                                    ? Alignment.centerLeft
                                    : (index < currentIndex
                                        ? Alignment.centerRight
                                        : Alignment.center),
                                scale: Curves.easeOut.transform(value),
                                child: child,
                              );
                            },
                          )
                        : removingWidget ??= RemovingExploreCardAnimated(
                            userId: cardProvider.getUser(index).id,
                            controller: AnimationController(
                              duration: const Duration(milliseconds: 500),
                              vsync: this,
                            )..forward(),
                            removeElement: (String userId) {
                              cardProvider.removeUser(
                                userId,
                                context: context,
                              );
                              removingWidget = null;
                            },
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: constraints.minHeight,
                              ),
                              child: SingleChildScrollView(
                                primary: false,
                                physics: const ScrollPhysics(),
                                child: ScopedModel<AvailableSizes>(
                                  model: AvailableSizes(
                                      height: constraints.minHeight),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ExploreCard(
                                      indexUser: index,
                                      key: ValueKey(
                                        cardProvider.getUser(index).id,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  )
                : Center(
                    child: AutoSizeText(
                      Provider.of<UserDataProvider>(context)
                          .behavior
                          .noUsersInExploreMessage,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class RemovingExploreCardAnimated extends StatelessWidget {
  final AnimationController controller;
  final Animation<Offset> slideTransition;
  final void Function(String id) removeElement;
  final Widget child;
  final String userId;

  RemovingExploreCardAnimated({
    Key key,
    @required this.controller,
    @required this.child,
    @required this.removeElement,
    @required this.userId,
  })  : slideTransition = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, -1.1),
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0, 1.0, curve: Curves.easeOut),
          ),
        )..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              removeElement(userId);
            }
          }),
        super(key: key) {
    print("Active");
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      child: child,
      builder: (ctx, child) {
        return SlideTransition(
          position: slideTransition,
          child: child,
        );
      },
      animation: controller,
    );
  }
}
