import 'package:flutter/material.dart';

import '../../models/users/mentee.dart';
import '../../models/users/mentor.dart';
import '../../models/users/user.dart';
import 'explore_card_mentor.dart';

class ExploreCard extends StatelessWidget {
  final User user;

  ExploreCard({
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    switch (user.runtimeType) {
      case Mentee:
        Mentee m = user as Mentee;
        return Card();
      case Mentor:
        return MentorCard(
          mentor: user as Mentor,
        );
      default:
        throw Exception();
    }
  }
}