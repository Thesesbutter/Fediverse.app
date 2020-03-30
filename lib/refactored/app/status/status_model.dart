import 'package:fedi/refactored/app/account/account_model.dart';
import 'package:fedi/refactored/app/database/app_database.dart';
import 'package:fedi/refactored/pleroma/application/pleroma_application_model.dart';
import 'package:fedi/refactored/pleroma/card/pleroma_card_model.dart';
import 'package:fedi/refactored/pleroma/content/pleroma_content_model.dart';
import 'package:fedi/refactored/pleroma/emoji/pleroma_emoji_model.dart';
import 'package:fedi/refactored/pleroma/media/attachment/pleroma_media_attachment_model.dart';
import 'package:fedi/refactored/pleroma/mention/pleroma_mention_model.dart';
import 'package:fedi/refactored/pleroma/poll/pleroma_poll_model.dart';
import 'package:fedi/refactored/pleroma/status/pleroma_status_model.dart';
import 'package:fedi/refactored/pleroma/tag/pleroma_tag_model.dart';
import 'package:fedi/refactored/pleroma/visibility/pleroma_visibility_model.dart';
import 'package:flutter/widgets.dart';

abstract class IStatus {
  IStatus get reblog;

  int get localId;

  String get remoteId;

  DateTime get createdAt;

  String get inReplyToRemoteId;

  String get inReplyToAccountRemoteId;

  bool get sensitive;

  String get spoilerText;

  String get uri;

  String get url;

  int get repliesCount;

  int get reblogsCount;

  int get favouritesCount;

  bool get favourited;

  bool get reblogged;

  bool get pinned;

  bool get muted;

  bool get bookmarked;

  String get content;

  String get reblogStatusRemoteId;

  PleromaApplication get application;

  IAccount get account;

  List<PleromaMediaAttachment> get mediaAttachments;

  List<PleromaMention> get mentions;

  List<PleromaTag> get tags;

  List<PleromaEmoji> get emojis;

  PleromaPoll get poll;

  PleromaCard get card;

  PleromaVisibility get visibility;

  String get language;

  // expanded pleroma object fields

  /// a map consisting of alternate representations of the content property with
  /// the key being it's mimetype.
  /// Currently the only alternate representation supported is text/plain
  PleromaContent get pleromaContent;

  /// the ID of the AP context the status is associated with (if any)

  int get pleromaConversationId;

  /// the ID of the Mastodon direct message conversation the status
  /// is associated with (if any)
  int get pleromaDirectConversationId;

  /// the acct property of User entity for replied user (if any)
  String get pleromaInReplyToAccountAcct;

  bool get pleromaLocal;

  /// a map consisting of alternate representations of the spoiler_text property
  /// with the key being it's mimetype. Currently the only alternate
  /// representation supported is text/plain
  PleromaContent get pleromaSpoilerText;

  /// a datetime (iso8601) that states when
  /// the post will expire (be deleted automatically),
  /// or empty if the post won't expire
  DateTime get pleromaExpiresAt;

  bool get pleromaThreadMuted;

  /// A list with emoji / reaction maps. The format is
  /// {name: "☕", count: 1, me: true}.
  /// Contains no information about the reacting users,
  /// for that use the /statuses/:id/reactions endpoint.
  List<PleromaStatusEmojiReaction> get pleromaEmojiReactions;
}

class DbStatusPopulatedWrapper implements IStatus {
  final DbStatusPopulated dbStatusPopulated;

  DbStatusPopulatedWrapper(this.dbStatusPopulated);

  @override
  DbAccountWrapper get account => DbAccountWrapper(dbStatusPopulated.account);

  @override
  PleromaApplication get application => dbStatusPopulated.status.application;

  @override
  bool get bookmarked => dbStatusPopulated.status.bookmarked;

  @override
  PleromaCard get card => dbStatusPopulated.status.card;

  @override
  String get content => dbStatusPopulated.status.content;

  @override
  DateTime get createdAt => dbStatusPopulated.status.createdAt;

  @override
  List<PleromaEmoji> get emojis => dbStatusPopulated.status.emojis;

  @override
  bool get favourited => dbStatusPopulated.status.favourited;

  @override
  int get favouritesCount => dbStatusPopulated.status.favouritesCount;

  @override
  String get inReplyToAccountRemoteId =>
      dbStatusPopulated.status.inReplyToAccountRemoteId;

  @override
  String get inReplyToRemoteId => dbStatusPopulated.status.inReplyToRemoteId;

  @override
  int get localId => dbStatusPopulated.status.id;

  @override
  List<PleromaMediaAttachment> get mediaAttachments =>
      dbStatusPopulated.status.mediaAttachments;

  @override
  List<PleromaMention> get mentions => dbStatusPopulated.status.mentions;

  @override
  bool get muted => dbStatusPopulated.status.muted;

  @override
  PleromaContent get pleromaContent => dbStatusPopulated.status.pleromaContent;

  @override
  int get pleromaConversationId =>
      dbStatusPopulated.status.pleromaConversationId;

  @override
  int get pleromaDirectConversationId =>
      dbStatusPopulated.status.pleromaDirectConversationId;

  @override
  List<PleromaStatusEmojiReaction> get pleromaEmojiReactions =>
      dbStatusPopulated.status.pleromaEmojiReactions;

  @override
  DateTime get pleromaExpiresAt => dbStatusPopulated.status.pleromaExpiresAt;

  @override
  String get pleromaInReplyToAccountAcct =>
      dbStatusPopulated.status.pleromaInReplyToAccountAcct;

  @override
  bool get pleromaLocal => dbStatusPopulated.status.pleromaLocal;

  @override
  PleromaContent get pleromaSpoilerText =>
      dbStatusPopulated.status.pleromaSpoilerText;

  @override
  bool get pleromaThreadMuted => dbStatusPopulated.status.pleromaThreadMuted;

  @override
  PleromaPoll get poll => dbStatusPopulated.status.poll;

  @override
  String get reblogStatusRemoteId =>
      dbStatusPopulated.status.reblogStatusRemoteId;

  @override
  bool get reblogged => dbStatusPopulated.status.reblogged;

  @override
  int get reblogsCount => dbStatusPopulated.status.reblogsCount;

  @override
  String get remoteId => dbStatusPopulated.status.remoteId;

  @override
  int get repliesCount => dbStatusPopulated.status.repliesCount;

  @override
  bool get sensitive => dbStatusPopulated.status.sensitive;

  @override
  String get spoilerText => dbStatusPopulated.status.spoilerText;

  @override
  List<PleromaTag> get tags => dbStatusPopulated.status.tags;

  @override
  String get uri => dbStatusPopulated.status.uri;

  @override
  String get url => dbStatusPopulated.status.url;

  @override
  PleromaVisibility get visibility => dbStatusPopulated.status.visibility;

  @override
  String get language => dbStatusPopulated.status.language;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbStatusPopulatedWrapper &&
          runtimeType == other.runtimeType &&
          dbStatusPopulated == other.dbStatusPopulated;

  @override
  int get hashCode => dbStatusPopulated.hashCode;
  @override
  String toString() {
    return 'DbStatusPopulatedWrapper{dbStatusPopulated: $dbStatusPopulated}';
  }

  @override
  bool get pinned => dbStatusPopulated.status.pinned;

  @override
  IStatus get reblog {
    if (dbStatusPopulated.rebloggedStatus != null &&
        dbStatusPopulated.rebloggedStatusAccount != null) {
      return DbStatusPopulatedWrapper(DbStatusPopulated(
          status: dbStatusPopulated.rebloggedStatus,
          account: dbStatusPopulated.rebloggedStatusAccount,
          rebloggedStatus: null,
          rebloggedStatusAccount: null));
    } else {
      return null;
    }
  }
}

class DbStatusPopulated {
  final DbStatus status;
  final DbAccount account;
  final DbStatus rebloggedStatus;
  final DbAccount rebloggedStatusAccount;

  DbStatusPopulated({
    @required this.status,
    @required this.account,
    @required this.rebloggedStatus,
    @required this.rebloggedStatusAccount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbStatusPopulated &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          account == other.account &&
          rebloggedStatus == other.rebloggedStatus &&
          rebloggedStatusAccount == other.rebloggedStatusAccount;
  @override
  int get hashCode =>
      status.hashCode ^
      account.hashCode ^
      rebloggedStatus.hashCode ^
      rebloggedStatusAccount.hashCode;
  @override
  String toString() {
    return 'DbStatusPopulated{status: $status, account: $account}';
  }
}
