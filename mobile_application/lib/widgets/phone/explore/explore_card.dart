import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_application/providers/explore/questions_provider.dart';
import 'package:mobile_application/providers/explore/should_collapse_provider.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/users/mentee.dart';
import '../../../models/users/mentor.dart';
import '../../../models/users/user.dart';
import '../../../providers/explore/card_provider.dart';
import 'explore_card_mentor.dart';

class ExploreCard extends StatelessWidget {
  final int indexUser;

  const ExploreCard({@required this.indexUser});

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getUser(indexUser);
    switch (user.runtimeType) {
      case Mentee:
        //TODO
        Mentee m = user as Mentee;
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
              ChangeNotifierProvider(
                create: (_) => QuestionsProvider(
                  numberOfQuestions: (user as Mentor).howManyQuestionsToAnswer,
                ),
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
