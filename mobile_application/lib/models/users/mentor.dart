import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'mentor.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class Mentor extends User {
  String company;
  String jobType;
  List<String> workingSpecialization;
  String companyImageUrl;

  Mentor({
    @required name,
    @required surname,
    @required pictureUrl,
    @required location,
    @required bio,
    @required questions,
    @required pastExperiences,
    @required this.company,
    @required this.jobType,
    @required this.workingSpecialization,
    @required this.companyImageUrl,
  })  : assert(company != null),
        assert(jobType != null),
        assert(workingSpecialization != null),
        assert(companyImageUrl != null),
        super(
          name: name,
          surname: surname,
          pictureUrl: pictureUrl,
          location: location,
          bio: bio,
          questions: questions,
          pastExperiences: pastExperiences ?? [],
        );

  factory Mentor.fromJson(Map<String, dynamic> json) => _$MentorFromJson(json);

  Map<String, dynamic> toJson() => _$MentorToJson(this);
}
