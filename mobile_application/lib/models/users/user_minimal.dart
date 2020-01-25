import 'package:json_annotation/json_annotation.dart';

part 'user_minimal.g.dart';

@JsonSerializable(explicitToJson: true)
class UserMinimal {
  @JsonKey(name: "_id")
  String id;
  String name;
  String surname;
  String pictureUrl;

  UserMinimal({
    this.id,
    this.name,
    this.surname,
    this.pictureUrl,
  });

  String get completeName => name + " " + surname;
  ///
  /// Serializable methods
  ///
  factory UserMinimal.fromJson(Map<String, dynamic> json) =>
      _$UserMinimalFromJson(json);

  Map<String, dynamic> toJson() => _$UserMinimalToJson(this);

}
