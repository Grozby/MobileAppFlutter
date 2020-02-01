import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(explicitToJson: true)
class Message {
  @JsonKey(name: "_id")
  String id;
  String userId;
  String content;
  String kind;
  @JsonKey(fromJson: getDateTimeFromString)
  DateTime createdAt;
  bool isRead;

  Message({
    @required this.userId,
    @required this.content,
    @required this.kind,
    @required this.createdAt,
    @required this.isRead,
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
