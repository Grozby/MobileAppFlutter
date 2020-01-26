import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../models/users/experiences/institution.dart';
import '../../../models/users/experiences/past_experience.dart';
import '../../../widgets/general/image_wrapper.dart';

part 'job.g.dart';

@JsonSerializable(explicitToJson: true)
class Job extends PastExperience {
  final String workingRole;

  Job({
    @required this.workingRole,
    @required Institution institution,
    @required DateTime fromDate,
    DateTime toDate,
  }) : super(
          institution: institution,
          fromDate: fromDate,
          toDate: toDate,
        );

  @override
  String get haveDone => workingRole;

  //TODO Change how we manage this on the widget!!
  @override
  String get assetPath => AssetImages.work;

  ///
  /// Serializable methods
  ///
  factory Job.fromJson(Map json) => _$JobFromJson(json);

  Map<String, dynamic> toJson() => _$JobToJson(this);
}
