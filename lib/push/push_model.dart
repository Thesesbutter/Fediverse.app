import 'package:fedi/enum/enum_values.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'push_model.g.dart';

typedef dynamic PushMessageListener(PushMessage message);

@HiveType(typeId: -32 + 67)
class PushMessage {
  PushMessageType get type =>
      pushMessageTypeEnumValues.valueToEnumMap[typeString];

  @HiveField(1)
  PushNotification notification;
  @HiveField(2)
  Map<String, dynamic> data;

  @HiveField(3)
  String typeString;

  bool get isLaunchOrResume =>
      type == PushMessageType.launch || type == PushMessageType.resume;

  PushMessage({this.typeString, this.notification, this.data});

  @override
  String toString() {
    return 'PushMessage{type: $type,'
        ' notification: $notification,'
        ' data: $data}';
  }
}

enum PushMessageType {
  foreground,
  launch,
  resume,
}

EnumValues<PushMessageType> pushMessageTypeEnumValues = EnumValues({
  "foreground": PushMessageType.foreground,
  "launch": PushMessageType.launch,
  "resume": PushMessageType.resume,
});

@HiveType(typeId: -32 + 73)
@JsonSerializable()
class PushNotification {
  @HiveField(0)
  String title;
  @HiveField(1)
  String body;

  PushNotification({this.title, this.body});

  @override
  String toString() {
    return 'PushNotification{title: $title, body: $body}';
  }

  Map<String, dynamic> toJson() => _$PushNotificationToJson(this);

  factory PushNotification.fromJson(Map<dynamic, dynamic> json) =>
      _$PushNotificationFromJson(json);
}
