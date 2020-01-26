import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/users/mentee.dart';
import '../../../models/users/mentor.dart';
import '../../../providers/explore/card_provider.dart';
import '../../../providers/explore/should_collapse_provider.dart';
import 'explore_card_mentor.dart';

class ExploreCard extends StatelessWidget {
  final int indexUser;

  const ExploreCard({@required this.indexUser});

  @override
  Widget build(BuildContext context) {
    CardProvider cardProvider = Provider.of<CardProvider>(
      context,
      listen: false,
    );
    switch (cardProvider.getUser(indexUser).runtimeType) {
      case Mentee:
        //TODO
        Mentee m = cardProvider.getUser(indexUser) as Mentee;
        return Card();
      case Mentor:

        /// The [ScopedModel][IndexUser] is used for determining which user
        /// we are referring to.
        /// The [ShouldCollapseProvider] instead is used for aesthetic purposes.
        /// When we turn the card, we close all the already expanded sections.
        return ScopedModel<IndexUser>(
          model: IndexUser(indexUser),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => ShouldCollapseProvider(),
              ),
              ChangeNotifierProvider.value(
                value: cardProvider.getQuestionProvider(indexUser),
              ),
            ],
            child: const MentorCard(),
          ),
        );
      default:
        throw Exception("Not a user!");
    }
  }
}

class IndexUser extends Model {
  final int indexUser;

  IndexUser(this.indexUser);

  static IndexUser of(BuildContext context) =>
      ScopedModel.of<IndexUser>(context);
}
