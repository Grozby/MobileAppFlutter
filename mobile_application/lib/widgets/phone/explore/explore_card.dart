import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_application/providers/should_collapse_provider.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/users/mentee.dart';
import '../../../models/users/mentor.dart';
import '../../../models/users/user.dart';
import '../../../providers/explore/card_provider.dart';
import 'explore_card_mentor.dart';

class ExploreCard extends StatelessWidget {
  final int indexUser;

  ExploreCard({@required this.indexUser});

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<CardProvider>(
      context,
      listen: false,
    ).getUser(indexUser);
    switch (user.runtimeType) {
      case Mentee:
        Mentee m = user as Mentee;
        return Card();
      case Mentor:
        return ScopedModel<IndexUser>(
          model: IndexUser(indexUser),
          child: ChangeNotifierProvider(
            builder: (_) => ShouldCollapseProvider(),
            child: MentorCard(),
          ),
        );
      default:
        throw Exception("Not a user!");
    }
  }
}

class IndexUser extends Model {
  int indexUser;

  IndexUser(this.indexUser);

  static IndexUser of(BuildContext context) =>
      ScopedModel.of<IndexUser>(context);
}
