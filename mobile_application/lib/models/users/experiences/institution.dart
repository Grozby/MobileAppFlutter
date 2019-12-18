import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'institution.g.dart';

@JsonSerializable(explicitToJson: true)
class Institution {
  String pictureUrl;
  String name;

  Institution({
    @required this.name,
    this.pictureUrl,
  }) : assert(name != null);

  factory Institution.fromJson(Map json) => _$InstitutionFromJson(json);

  Map<String, dynamic> toJson() => _$InstitutionToJson(this);
}
