import 'package:json_annotation/json_annotation.dart';

import '../users/answer.dart';
import '../users/user_minimal.dart';
import 'message.dart';

part 'contact_mentor.g.dart';

enum StatusRequest { accepted, refused, pending }

@JsonSerializable(explicitToJson: true)
class ContactMentor {
  @JsonKey(name: "_id")
  String id;
  UserMinimal user;
  String startingMessage;
  StatusRequest status;
  List<Answer> answers;
  List<Message> messages;
  @JsonKey(fromJson: getDateTimeFromString)
  DateTime createdAt;
  int unreadMessages;

  ContactMentor({
    this.user,
    this.startingMessage,
    this.status,
    this.answers,
    this.messages,
  });

  int get numberUnreadMessages =>
      messages.where((e) => !e.isRead).toList().length +
      unreadMessages -
      ((messages.isNotEmpty && messages[0].isRead) ? 1 : 0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactMentor &&
          runtimeType == other.runtimeType &&
          id == other.id;

  ///
  /// Serializable methods
  ///
  factory ContactMentor.fromJson(Map<String, dynamic> json) =>
      _$ContactMentorFromJson(json);

  Map<String, dynamic> toJson() => _$ContactMentorToJson(this);

  static DateTime getDateTimeFromString(String string) {
    return string == null ? null : DateTime.parse(string);
  }
}
