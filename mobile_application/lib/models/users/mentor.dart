import 'package:flutter/foundation.dart';

import 'user.dart';

class Mentor extends User {
  String company;
  String workingRole;

  Mentor({
    @required name,
    @required surname,
    @required pictureUrl,
    @required location,
    @required bio,
    @required this.company,
    @required this.workingRole,
  }) : super(
          name: name,
          surname: surname,
          pictureUrl: pictureUrl,
          location: location,
          bio: bio,
        );
}
