import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_application/models/users/experiences/past_experience.dart';

part 'job.g.dart';

@JsonSerializable(explicitToJson: true)
class Job implements PastExperience {
  final String company;
  final String workingRole;
  final String companyImageUrl;

  Job({
    @required this.company,
    @required this.workingRole,
    this.companyImageUrl,
  });

  @override
  String get at => company;

  @override
  String get haveDone => workingRole;

  @override
  String get pictureUrl => companyImageUrl;

  //TODO Change how we manage this on the widget!!
  @override
  String get assetPath =>  "assets/images/job.png";

  factory Job.fromJson(Map json) => _$JobFromJson(json);

  Map<String, dynamic> toJson() => _$JobToJson(this);
}
