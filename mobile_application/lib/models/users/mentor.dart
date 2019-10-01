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
    @required favoriteLanguages,
    @required pastExperiences,
    @required this.company,
    @required this.jobType,
    @required this.workingSpecialization,
    @required this.urlCompanyImage,
  }) : super(
          name: name,
          surname: surname,
          pictureUrl: pictureUrl,
          location: location,
          bio: bio,
          favoriteLanguages: favoriteLanguages,
          pastExperiences: pastExperiences,
        );
}
