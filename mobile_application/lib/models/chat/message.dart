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
    this.id,
    @required this.userId,
    @required this.content,
    @required this.kind,
    @required this.createdAt,
    @required this.isRead,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id && isRead == other.isRead;

  @override
  int get hashCode =>
      id.hashCode;

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
