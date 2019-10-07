import 'package:flutter/foundation.dart';

import 'user.dart';

class Mentor extends User {
  String company;
  String jobType;
  List<String> workingSpecialization;
  String urlCompanyImage;

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
    @required this.urlCompanyImage,
  })  : assert(company != null),
        assert(jobType != null),
        assert(workingSpecialization != null),
        assert(urlCompanyImage != null),
        super(
          name: name,
          surname: surname,
          pictureUrl: pictureUrl,
          location: location,
          bio: bio,
          questions: questions,
          pastExperiences: pastExperiences,
        );
}
