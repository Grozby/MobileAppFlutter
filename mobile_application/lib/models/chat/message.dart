import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(explicitToJson: true)
class Message {
  String userId;
  String content;
  String kind;
  @JsonKey(fromJson: getDateTimeFromString)
  DateTime createdAt;

  Message({
    @required this.userId,
    @required this.content,
    @required this.kind,
    @required this.createdAt,
  });

  ///
  /// Serializable methods
  ///
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  static DateTime getDateTimeFromString(String string) {
    return string == null ? null : DateTime.parse(string);
  }
}
