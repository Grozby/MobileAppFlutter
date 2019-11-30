import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/widgets/general/image_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/users/user.dart';
import '../models/utility/available_sizes.dart';
import '../providers/user/user_data_provider.dart';
import '../widgets/general/expandable_widget.dart';
import '../widgets/phone/explore/card_container.dart';

class UserProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserDataProvider>(context).user;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Ryfy'),
        ),
        body: SafeArea(
          child: LayoutBuilder(builder: (ctx, constraints) {
            return ScopedModel<AvailableSizes>(
              model: AvailableSizes(constraints.maxHeight),
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Positioned(
                    top: 100,
                    width: constraints.maxWidth * 0.90,
                    child: CardContainer(
                      rotateCard: () {},
                      canExpand: true,
                      startingColor: user.cardColor,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 60,
                          ),
                          Container(
                            child: Text(
                              user.completeName,
                              style: Theme.of(context).textTheme.title,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AutoSizeText(
                            user.currentJob.workingRole + " @ ",
                            style: Theme.of(context).textTheme.overline,
                          ),
                          AutoSizeText(
                            user.currentJob.company,
                            style:
                                Theme.of(context).textTheme.overline.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(height: 16),
                          ExpandableWidget(
                            height: 120,
                            durationInMilliseconds: 300,
                            child: Container(
                              alignment: Alignment.topCenter,
                              child: Text(
                                user.bio,
                                style: Theme.of(context).textTheme.body1,
                              ),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    child: Container(
                      alignment: Alignment.center,
                      height: 120,
                      width: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(const Radius.circular(1000)),
                        child: ImageWrapper(
                          assetPath: "user.png",
                          imageUrl: user.pictureUrl,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ));
  }
}
