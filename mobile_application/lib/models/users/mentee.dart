import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';

import 'user.dart';

class Mentee extends User {
  int tokenCount;

  Mentee({
    @required name,
    @required surname,
    @required pictureUrl,
    @required location,
    @required bio,
    @required questions,
    @required experiences,
    @required socialAccounts,
    @required currentJob,
    @required this.tokenCount,
  })  : assert(tokenCount != null),
        super(
          name: name,
          surname: surname,
          pictureUrl: pictureUrl,
          location: location,
          bio: bio,
          questions: questions,
          experiences: experiences,
          socialAccounts: socialAccounts,
          currentJob: currentJob,
        );

  @override
  Color get color => ThemeProvider.menteeColor;

  @override
  Color get cardColor => ThemeProvider.menteeCardColor;
}
