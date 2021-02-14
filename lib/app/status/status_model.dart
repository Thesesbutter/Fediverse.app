import 'package:fedi/app/account/account_model.dart';
import 'package:fedi/app/database/app_database.dart';
import 'package:fedi/app/pending/pending_model.dart';
import 'package:fedi/pleroma/application/pleroma_application_model.dart';
import 'package:fedi/pleroma/card/pleroma_card_model.dart';
import 'package:fedi/pleroma/content/pleroma_content_model.dart';
import 'package:fedi/pleroma/emoji/pleroma_emoji_model.dart';
import 'package:fedi/pleroma/media/attachment/pleroma_media_attachment_model.dart';
import 'package:fedi/pleroma/mention/pleroma_mention_model.dart';
import 'package:fedi/pleroma/poll/pleroma_poll_model.dart';
import 'package:fedi/pleroma/status/pleroma_status_model.dart';
import 'package:fedi/pleroma/tag/pleroma_tag_model.dart';
import 'package:fedi/pleroma/visibility/pleroma_visibility_model.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

final _logger = Logger("status_model.dart");

typedef StatusAndContextCallback = Function(
    BuildContext context, IStatus status);
typedef StatusCallback = Function(IStatus status);

abstract class IStatus {
  IStatus get reblog;

  int get localId;

  String get remoteId;

  DateTime get createdAt;

  IStatus get inReplyToStatus;

  String get inReplyToRemoteId;

  String get inReplyToAccountRemoteId;

  bool get nsfwSensitive;

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

  bool get isReply =>
      inReplyToAccountRemoteId != null && inReplyToRemoteId != null;

  bool get isHaveReblog => reblogStatusRemoteId != null;

  bool get deleted;

  PendingState get pendingState;

  String get oldPendingRemoteId;

  bool get hiddenLocallyOnDevice;

  String get wasSentWithIdempotencyKey;

  IStatus copyWith({
    IAccount account,
    IStatus reblog,
    int id,
    String remoteId,
    DateTime createdAt,
    IStatus inReplyToStatus,
    String inReplyToRemoteId,
    String inReplyToAccountRemoteId,
    bool nsfwSensitive,
    String spoilerText,
    PleromaVisibility visibility,
    String uri,
    String url,
    int repliesCount,
    int reblogsCount,
    int favouritesCount,
    bool favourited,
    bool reblogged,
    bool muted,
    bool bookmarked,
    bool pinned,
    String content,
    String reblogStatusRemoteId,
    PleromaApplication application,
    String accountRemoteId,
    List<PleromaMediaAttachment> mediaAttachments,
    List<PleromaMention> mentions,
    List<PleromaTag> tags,
    List<PleromaEmoji> emojis,
    PleromaPoll poll,
    PleromaCard card,
    String language,
    PleromaContent pleromaContent,
    int pleromaConversationId,
    int pleromaDirectConversationId,
    String pleromaInReplyToAccountAcct,
    bool pleromaLocal,
    PleromaContent pleromaSpoilerText,
    DateTime pleromaExpiresAt,
    bool pleromaThreadMuted,
    List<PleromaStatusEmojiReaction> pleromaEmojiReactions,
    bool deleted,
    PendingState pendingState,
    String oldPendingRemoteId,
    bool hiddenLocallyOnDevice,
    String wasSentWithIdempotencyKey,
  });
}

class DbStatusPopulatedWrapper extends IStatus {
  final DbStatusPopulated dbStatusPopulated;

  DbStatusPopulatedWrapper(this.dbStatusPopulated);

  @override
  DbAccountWrapper get account => DbAccountWrapper(dbStatusPopulated.dbAccount);

  @override
  PleromaApplication get application => dbStatusPopulated.dbStatus.application;

  @override
  bool get bookmarked => dbStatusPopulated.dbStatus.bookmarked;

  @override
  PleromaCard get card => dbStatusPopulated.dbStatus.card;

  @override
  String get content => dbStatusPopulated.dbStatus.content;

  @override
  DateTime get createdAt => dbStatusPopulated.dbStatus.createdAt;

  @override
  List<PleromaEmoji> get emojis => dbStatusPopulated.dbStatus.emojis;

  @override
  bool get favourited => dbStatusPopulated.dbStatus.favourited;

  @override
  int get favouritesCount => dbStatusPopulated.dbStatus.favouritesCount;

  @override
  IStatus get inReplyToStatus {
    if (dbStatusPopulated.replyDbStatus != null &&
        dbStatusPopulated.replyDbStatusAccount != null) {
      return DbStatusPopulatedWrapper(
        DbStatusPopulated(
          dbStatus: dbStatusPopulated.replyDbStatus,
          dbAccount: dbStatusPopulated.replyDbStatusAccount,
          reblogDbStatus: dbStatusPopulated.replyReblogDbStatus,
          reblogDbStatusAccount: dbStatusPopulated.replyReblogDbStatusAccount,
          replyDbStatus: null,
          replyReblogDbStatusAccount: null,
          replyReblogDbStatus: null,
          replyDbStatusAccount: null,
        ),
      );
    } else {
      return null;
    }
  }

  @override
  String get inReplyToAccountRemoteId =>
      dbStatusPopulated.dbStatus.inReplyToAccountRemoteId;

  @override
  String get inReplyToRemoteId => dbStatusPopulated.dbStatus.inReplyToRemoteId;

  @override
  int get localId => dbStatusPopulated.dbStatus.id;

  @override
  List<PleromaMediaAttachment> get mediaAttachments =>
      dbStatusPopulated.dbStatus.mediaAttachments;

  @override
  List<PleromaMention> get mentions => dbStatusPopulated.dbStatus.mentions;

  @override
  bool get muted => dbStatusPopulated.dbStatus.muted;

  @override
  PleromaContent get pleromaContent =>
      dbStatusPopulated.dbStatus.pleromaContent;

  @override
  int get pleromaConversationId =>
      dbStatusPopulated.dbStatus.pleromaConversationId;

  @override
  int get pleromaDirectConversationId =>
      dbStatusPopulated.dbStatus.pleromaDirectConversationId;

  @override
  List<PleromaStatusEmojiReaction> get pleromaEmojiReactions =>
      dbStatusPopulated.dbStatus.pleromaEmojiReactions;

  @override
  DateTime get pleromaExpiresAt => dbStatusPopulated.dbStatus.pleromaExpiresAt;

  @override
  String get pleromaInReplyToAccountAcct =>
      dbStatusPopulated.dbStatus.pleromaInReplyToAccountAcct;

  @override
  bool get pleromaLocal => dbStatusPopulated.dbStatus.pleromaLocal;

  @override
  PleromaContent get pleromaSpoilerText =>
      dbStatusPopulated.dbStatus.pleromaSpoilerText;

  @override
  bool get pleromaThreadMuted => dbStatusPopulated.dbStatus.pleromaThreadMuted;

  @override
  PleromaPoll get poll => dbStatusPopulated.dbStatus.poll;

  @override
  String get reblogStatusRemoteId =>
      dbStatusPopulated.dbStatus.reblogStatusRemoteId;

  @override
  bool get reblogged => dbStatusPopulated.dbStatus.reblogged;

  @override
  int get reblogsCount => dbStatusPopulated.dbStatus.reblogsCount;

  @override
  String get remoteId => dbStatusPopulated.dbStatus.remoteId;

  @override
  int get repliesCount => dbStatusPopulated.dbStatus.repliesCount;

  @override
  bool get nsfwSensitive => dbStatusPopulated.dbStatus.sensitive;

  @override
  String get spoilerText => dbStatusPopulated.dbStatus.spoilerText;

  @override
  List<PleromaTag> get tags => dbStatusPopulated.dbStatus.tags;

  @override
  String get uri => dbStatusPopulated.dbStatus.uri;

  @override
  String get url => dbStatusPopulated.dbStatus.url;

  @override
  PleromaVisibility get visibility => dbStatusPopulated.dbStatus.visibility;

  @override
  String get language => dbStatusPopulated.dbStatus.language;

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
  bool get pinned => dbStatusPopulated.dbStatus.pinned;

  @override
  bool get deleted => dbStatusPopulated.dbStatus.deleted;

  @override
  bool get hiddenLocallyOnDevice =>
      dbStatusPopulated.dbStatus.hiddenLocallyOnDevice;

  @override
  PendingState get pendingState => dbStatusPopulated.dbStatus.pendingState;

  @override
  String get oldPendingRemoteId =>
      dbStatusPopulated.dbStatus.oldPendingRemoteId;

  @override
  IStatus get reblog {
    if (dbStatusPopulated.reblogDbStatus != null &&
        dbStatusPopulated.reblogDbStatusAccount != null) {
      return DbStatusPopulatedWrapper(
        DbStatusPopulated(
          dbStatus: dbStatusPopulated.reblogDbStatus,
          dbAccount: dbStatusPopulated.reblogDbStatusAccount,
          reblogDbStatus: null,
          reblogDbStatusAccount: null,
          replyDbStatus: null,
          replyReblogDbStatusAccount: null,
          replyDbStatusAccount: null,
          replyReblogDbStatus: null,
        ),
      );
    } else {
      return null;
    }
  }

  @override
  DbStatusPopulatedWrapper copyWith({
    IAccount account,
    IStatus reblog,
    int id,
    String remoteId,
    DateTime createdAt,
    IStatus inReplyToStatus,
    String inReplyToRemoteId,
    String inReplyToAccountRemoteId,
    bool nsfwSensitive,
    String spoilerText,
    PleromaVisibility visibility,
    String uri,
    String url,
    int repliesCount,
    int reblogsCount,
    int favouritesCount,
    bool favourited,
    bool reblogged,
    bool muted,
    bool bookmarked,
    bool pinned,
    String content,
    String reblogStatusRemoteId,
    PleromaApplication application,
    String accountRemoteId,
    List<PleromaMediaAttachment> mediaAttachments,
    List<PleromaMention> mentions,
    List<PleromaTag> tags,
    List<PleromaEmoji> emojis,
    PleromaPoll poll,
    PleromaCard card,
    String language,
    PleromaContent pleromaContent,
    int pleromaConversationId,
    int pleromaDirectConversationId,
    String pleromaInReplyToAccountAcct,
    bool pleromaLocal,
    PleromaContent pleromaSpoilerText,
    DateTime pleromaExpiresAt,
    bool pleromaThreadMuted,
    List<PleromaStatusEmojiReaction> pleromaEmojiReactions,
    bool deleted,
    PendingState pendingState,
    String oldPendingRemoteId,
    bool hiddenLocallyOnDevice,
    String wasSentWithIdempotencyKey,
  }) {
    DbStatus reblogStatus;
    DbAccount reblogStatusAccount;

    if (reblog != null) {
      reblogStatus = dbStatusFromStatus(reblog);

      var account = reblog.account;
      reblogStatusAccount = dbAccountFromAccount(account);
    }

    DbStatus replyStatus;
    DbAccount replyStatusAccount;

    DbStatus replyReblogStatus;
    DbAccount replyReblogStatusAccount;
    if (inReplyToStatus != null) {
      replyStatus = dbStatusFromStatus(inReplyToStatus);

      var account = inReplyToStatus.account;
      replyStatusAccount = dbAccountFromAccount(account);

      if (inReplyToStatus.reblog != null) {
        replyReblogStatus = dbStatusFromStatus(inReplyToStatus.reblog);

        var account = inReplyToStatus.reblog.account;
        replyReblogStatusAccount = dbAccountFromAccount(account);
      }
    }

    return DbStatusPopulatedWrapper(
      dbStatusPopulated.copyWith(
        status: dbStatusPopulated.dbStatus.copyWith(
          id: id,
          remoteId: remoteId,
          createdAt: createdAt,
          inReplyToRemoteId: inReplyToRemoteId,
          inReplyToAccountRemoteId: inReplyToAccountRemoteId,
          sensitive: nsfwSensitive,
          spoilerText: spoilerText,
          visibility: visibility,
          uri: uri,
          url: url,
          repliesCount: repliesCount,
          reblogsCount: reblogsCount,
          favouritesCount: favouritesCount,
          favourited: favourited,
          reblogged: reblogged,
          muted: muted,
          bookmarked: bookmarked,
          pinned: pinned,
          content: content,
          reblogStatusRemoteId: reblogStatusRemoteId,
          application: application,
          accountRemoteId: accountRemoteId,
          mediaAttachments: mediaAttachments,
          mentions: mentions,
          tags: tags,
          emojis: emojis,
          poll: poll,
          card: card,
          language: language,
          pleromaContent: pleromaContent,
          pleromaConversationId: pleromaConversationId,
          pleromaDirectConversationId: pleromaDirectConversationId,
          pleromaInReplyToAccountAcct: pleromaInReplyToAccountAcct,
          pleromaLocal: pleromaLocal,
          pleromaSpoilerText: pleromaSpoilerText,
          pleromaExpiresAt: pleromaExpiresAt,
          pleromaThreadMuted: pleromaThreadMuted,
          pleromaEmojiReactions: pleromaEmojiReactions,
          deleted: deleted,
          pendingState: pendingState,
          oldPendingRemoteId: oldPendingRemoteId,
          hiddenLocallyOnDevice: hiddenLocallyOnDevice,
          wasSentWithIdempotencyKey: wasSentWithIdempotencyKey,
        ),
        account: dbStatusPopulated.dbAccount.copyWith(
          id: account?.localId,
          remoteId: account?.remoteId,
          username: account?.username,
          url: account?.url,
          note: account?.note,
          locked: account?.locked,
          headerStatic: account?.headerStatic,
          header: account?.header,
          followingCount: account?.followingCount,
          followersCount: account?.followersCount,
          statusesCount: account?.statusesCount,
          displayName: account?.displayName,
          createdAt: account?.createdAt,
          bot: account?.bot,
          avatarStatic: account?.avatarStatic,
          avatar: account?.avatar,
          acct: account?.acct,
          lastStatusAt: account?.lastStatusAt,
          fields: account?.fields,
          emojis: account?.emojis,
          pleromaRelationship: account?.pleromaRelationship,
          pleromaTags: account?.pleromaTags,
          pleromaIsAdmin: account?.pleromaIsAdmin,
          pleromaIsModerator: account?.pleromaIsModerator,
          pleromaConfirmationPending: account?.pleromaConfirmationPending,
          pleromaHideFavorites: account?.pleromaHideFavorites,
          pleromaHideFollowers: account?.pleromaHideFollowers,
          pleromaHideFollows: account?.pleromaHideFollows,
          pleromaHideFollowersCount: account?.pleromaHideFollowersCount,
          pleromaHideFollowsCount: account?.pleromaHideFollowsCount,
          pleromaDeactivated: account?.pleromaDeactivated,
          pleromaAllowFollowingMove: account?.pleromaAllowFollowingMove,
          pleromaSkipThreadContainment: account?.pleromaSkipThreadContainment,
        ),
        reblogDbStatus: reblogStatus,
        reblogDbStatusAccount: reblogStatusAccount,
        replyDbStatus: replyStatus,
        replyDbStatusAccount: replyStatusAccount,
        replyReblogDbStatus: replyReblogStatus,
        replyReblogDbStatusAccount: replyReblogStatusAccount,
      ),
    );
  }

  @override
  String get wasSentWithIdempotencyKey =>
      dbStatusPopulated.dbStatus.wasSentWithIdempotencyKey;
}

class DbStatusPopulated {
  final DbStatus dbStatus;
  final DbAccount dbAccount;
  final DbStatus reblogDbStatus;
  final DbAccount reblogDbStatusAccount;
  final DbStatus replyDbStatus;
  final DbAccount replyDbStatusAccount;
  final DbStatus replyReblogDbStatus;
  final DbAccount replyReblogDbStatusAccount;

  DbStatusPopulated({
    @required this.dbStatus,
    @required this.dbAccount,
    @required this.reblogDbStatus,
    @required this.reblogDbStatusAccount,
    @required this.replyDbStatus,
    @required this.replyDbStatusAccount,
    @required this.replyReblogDbStatus,
    @required this.replyReblogDbStatusAccount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbStatusPopulated &&
          runtimeType == other.runtimeType &&
          dbStatus == other.dbStatus &&
          dbAccount == other.dbAccount &&
          reblogDbStatus == other.reblogDbStatus &&
          reblogDbStatusAccount == other.reblogDbStatusAccount &&
          replyDbStatus == other.replyDbStatus &&
          replyDbStatusAccount == other.replyDbStatusAccount &&
          replyReblogDbStatus == other.replyReblogDbStatus &&
          replyReblogDbStatusAccount == other.replyReblogDbStatusAccount;

  @override
  int get hashCode =>
      dbStatus.hashCode ^
      dbAccount.hashCode ^
      reblogDbStatus.hashCode ^
      reblogDbStatusAccount.hashCode ^
      replyDbStatus.hashCode ^
      replyDbStatusAccount.hashCode ^
      replyReblogDbStatus.hashCode ^
      replyReblogDbStatusAccount.hashCode;

  @override
  String toString() {
    return 'DbStatusPopulated{dbStatus: $dbStatus, dbAccount: $dbAccount,'
        ' reblogDbStatus: $reblogDbStatus,'
        ' reblogDbStatusAccount: $reblogDbStatusAccount,'
        ' replyDbStatus: $replyDbStatus,'
        ' replyDbStatusAccount: $replyDbStatusAccount,'
        ' replyReblogDbStatus: $replyReblogDbStatus,'
        ' replyReblogDbStatusAccount: $replyReblogDbStatusAccount}';
  }

  DbStatusPopulated copyWith({
    DbStatus status,
    DbAccount account,
    DbStatus reblogDbStatus,
    DbAccount reblogDbStatusAccount,
    DbStatus replyDbStatus,
    DbAccount replyDbStatusAccount,
    DbStatus replyReblogDbStatus,
    DbAccount replyReblogDbStatusAccount,
  }) =>
      DbStatusPopulated(
        dbStatus: status,
        dbAccount: account,
        reblogDbStatus: reblogDbStatus,
        reblogDbStatusAccount: reblogDbStatusAccount,
        replyDbStatus: replyDbStatus,
        replyDbStatusAccount: replyDbStatusAccount,
        replyReblogDbStatus: replyReblogDbStatus,
        replyReblogDbStatusAccount: replyReblogDbStatusAccount,
      );
}

DbStatus dbStatusFromStatus(IStatus status) {
  if (status == null) {
    return null;
  }
  return DbStatus(
    id: status.localId,
    remoteId: status.remoteId,
    createdAt: status.createdAt,
    inReplyToRemoteId: status.inReplyToRemoteId,
    inReplyToAccountRemoteId: status.inReplyToAccountRemoteId,
    sensitive: status.nsfwSensitive,
    spoilerText: status.spoilerText,
    visibility: status.visibility,
    uri: status.uri,
    url: status.url,
    repliesCount: status.repliesCount,
    reblogsCount: status.reblogsCount,
    favouritesCount: status.favouritesCount,
    favourited: status.favourited,
    reblogged: status.reblogged,
    muted: status.muted,
    bookmarked: status.bookmarked,
    pinned: status.pinned,
    content: status.content,
    reblogStatusRemoteId: status.reblogStatusRemoteId,
    application: status.application,
    accountRemoteId: status.account.remoteId,
    mediaAttachments: status.mediaAttachments,
    mentions: status.mentions,
    tags: status.tags,
    emojis: status.emojis,
    poll: status.poll,
    card: status.card,
    language: status.language,
    pleromaContent: status.pleromaContent,
    pleromaConversationId: status.pleromaConversationId,
    pleromaDirectConversationId: status.pleromaDirectConversationId,
    pleromaInReplyToAccountAcct: status.pleromaInReplyToAccountAcct,
    pleromaLocal: status.pleromaLocal,
    pleromaSpoilerText: status.pleromaSpoilerText,
    pleromaExpiresAt: status.pleromaExpiresAt,
    pleromaThreadMuted: status.pleromaThreadMuted,
    pleromaEmojiReactions: status.pleromaEmojiReactions,
    deleted: null,
  );
}

extension IStatusExtension on IStatus {
  Uri get urlRemoteHostUri {
    var uri = Uri.parse(url);

    var resultUrl = "${uri.scheme}://${uri.host}";
    return Uri.parse(resultUrl);
  }

  String get urlRemoteId {
    try {
      // todo: perhaps need improvements
      var splitResult = url.split("/");

      var isHaveEndingSlash = splitResult.last.isNotEmpty;
      if (isHaveEndingSlash) {
        return splitResult.last;
      } else {
        return splitResult[splitResult.length - 2];
      }
    } catch (e, stackTrace) {
      var exception = CantExtractStatusRemoteIdFromStatusUrlException(
        e: e,
        status: this,
      );
      _logger.shout(() => "$exception", stackTrace);
      throw exception;
    }
  }
}

class CantExtractStatusRemoteIdFromStatusUrlException implements Exception {
  final IStatus status;
  final Exception e;

  CantExtractStatusRemoteIdFromStatusUrlException({
    @required this.status,
    this.e,
  });

  @override
  String toString() {
    return 'CantExtractStatusRemoteIdFromStatusUrlException{status: $status, e: $e}';
  }
}
