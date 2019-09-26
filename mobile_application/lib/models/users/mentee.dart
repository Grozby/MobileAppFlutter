import 'package:flutter/foundation.dart';

import 'user.dart';

class Mentee extends User {
  int tokenCount;

  Mentee({
    @required name,
    @required surname,
    @required pictureUrl,
    @required location,
    @required bio,
    @required favoriteLanguages,
    @required this.tokenCount,
  }) : super(
          name: name,
          surname: surname,
          pictureUrl: pictureUrl,
          location: location,
          bio: bio,
          favoriteLanguages: favoriteLanguages
        );
}
