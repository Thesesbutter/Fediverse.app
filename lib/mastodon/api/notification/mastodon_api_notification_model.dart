import 'package:fedi/mastodon/api/account/mastodon_api_account_model.dart';
import 'package:fedi/mastodon/api/status/mastodon_api_status_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:moor/moor.dart';

abstract class IMastodonApiNotification {
  IMastodonApiAccount? get account;

  DateTime get createdAt;

  String get id;

  String get type;

  MastodonApiNotificationType get typeAsMastodonApi;

  IMastodonApiStatus? get status;
}

enum MastodonApiNotificationType {
  follow,
  favourite,
  reblog,
  mention,
  poll,
  move,
  followRequest,
  unknown,
}

const unknownMastodonApiNotificationType = MastodonApiNotificationType.unknown;

const _followMastodonApiNotificationTypeJsonValue = "follow";
const _favouriteMastodonApiNotificationTypeJsonValue = "favourite";
const _reblogMastodonApiNotificationTypeJsonValue = "reblog";
const _mentionMastodonApiNotificationTypeJsonValue = "mention";
const _pollMastodonApiNotificationTypeJsonValue = "poll";
const _moveMastodonApiNotificationTypeJsonValue = "move";
const _followRequestMastodonApiNotificationTypeJsonValue = "follow_request";
const _unknownRequestMastodonApiNotificationTypeJsonValue = "unknown";

extension MastodonApiNotificationTypeListExtension
    on List<MastodonApiNotificationType> {
  List<String> toMastodonApiNotificationTypeStrings() => map(
        (notificationType) => notificationType.toJsonValue(),
      ).toList();
}

extension MastodonApiNotificationTypeExtension on MastodonApiNotificationType {
  String toJsonValue() {
    String result;

    switch (this) {
      case MastodonApiNotificationType.follow:
        result = _followMastodonApiNotificationTypeJsonValue;
        break;
      case MastodonApiNotificationType.favourite:
        result = _favouriteMastodonApiNotificationTypeJsonValue;
        break;
      case MastodonApiNotificationType.reblog:
        result = _reblogMastodonApiNotificationTypeJsonValue;
        break;
      case MastodonApiNotificationType.mention:
        result = _mentionMastodonApiNotificationTypeJsonValue;
        break;
      case MastodonApiNotificationType.poll:
        result = _pollMastodonApiNotificationTypeJsonValue;
        break;
      case MastodonApiNotificationType.move:
        result = _moveMastodonApiNotificationTypeJsonValue;
        break;
      case MastodonApiNotificationType.followRequest:
        result = _followRequestMastodonApiNotificationTypeJsonValue;
        break;
      case MastodonApiNotificationType.unknown:
        result = _unknownRequestMastodonApiNotificationTypeJsonValue;
        break;
    }

    return result;
  }
}

extension MastodonApiNotificationTypeStringExtension on String {
  MastodonApiNotificationType toMastodonApiNotificationType() {
    MastodonApiNotificationType result;

    switch (this) {
      case _followMastodonApiNotificationTypeJsonValue:
        result = MastodonApiNotificationType.follow;
        break;
      case _moveMastodonApiNotificationTypeJsonValue:
        result = MastodonApiNotificationType.move;
        break;
      case _favouriteMastodonApiNotificationTypeJsonValue:
        result = MastodonApiNotificationType.favourite;
        break;
      case _pollMastodonApiNotificationTypeJsonValue:
        result = MastodonApiNotificationType.poll;
        break;
      case _mentionMastodonApiNotificationTypeJsonValue:
        result = MastodonApiNotificationType.mention;
        break;
      case _reblogMastodonApiNotificationTypeJsonValue:
        result = MastodonApiNotificationType.reblog;
        break;
      case _followRequestMastodonApiNotificationTypeJsonValue:
        result = MastodonApiNotificationType.followRequest;
        break;
      case _unknownRequestMastodonApiNotificationTypeJsonValue:
        result = MastodonApiNotificationType.unknown;
        break;
      // can't parse, default value
      default:
        result = unknownMastodonApiNotificationType;
        break;
    }

    return result;
  }
}

extension MastodonApiNotificationTypeStringPollExtension on List<String> {
  List<MastodonApiNotificationType> toPleromaVisibilities() => map(
        (notificationTypeString) =>
            notificationTypeString.toMastodonApiNotificationType(),
      ).toList();
}

class MastodonApiNotificationTypeTypeConverter
    implements
        JsonConverter<MastodonApiNotificationType, String?>,
        TypeConverter<MastodonApiNotificationType, String?> {
  const MastodonApiNotificationTypeTypeConverter();

  @override
  MastodonApiNotificationType fromJson(String? value) =>
      value?.toMastodonApiNotificationType() ??
      unknownMastodonApiNotificationType;

  @override
  String? toJson(MastodonApiNotificationType? value) => value?.toJsonValue();

  @override
  MastodonApiNotificationType? mapToDart(String? fromDb) => fromJson(fromDb);

  @override
  String? mapToSql(MastodonApiNotificationType? value) => toJson(value);
}