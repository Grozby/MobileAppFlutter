import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_application/models/users/experiences/past_experience.dart';

part 'job.g.dart';

@JsonSerializable(explicitToJson: true)
class Job extends PastExperience {
  final String company;
  final String workingRole;

  Job({
    @required this.company,
    @required this.workingRole,
    companyImageUrl,
    @required startingTime,
    endingTime,
  }) : super(
          pictureUrl: companyImageUrl,
          startingTime: startingTime,
          endingTime: endingTime,
        );

  @override
  String get at => company;

  @override
  String get haveDone => workingRole;

  //TODO Change how we manage this on the widget!!
  @override
  String get assetPath => "job_128.png";

  factory Job.fromJson(Map json) => _$JobFromJson(json);

  Map<String, dynamic> toJson() => _$JobToJson(this);
}
