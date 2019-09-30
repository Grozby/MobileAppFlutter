import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/users/experiences/past_experience.dart';

class OldJob implements PastExperience{
  final String company;
  final String workingRole;

  OldJob({
    @required this.company,
    @required this.workingRole,
  });

  @override
  String get at => company;

  @override
  String get haveDone => workingRole;

  @override
  String get assetPath => "assets/images/job.png";
}
