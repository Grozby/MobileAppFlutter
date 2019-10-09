import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_application/models/users/experiences/past_experience.dart';

part 'old_job.g.dart';

@JsonSerializable(explicitToJson: true)
class OldJob implements PastExperience {
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

  factory OldJob.fromJson(Map json) => _$OldJobFromJson(json);

  Map<String, dynamic> toJson() => _$OldJobToJson(this);
}
