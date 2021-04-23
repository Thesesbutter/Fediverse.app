import 'package:fedi/app/account/account_model_adapter.dart';
import 'package:fedi/app/database/app_database.dart';
import 'package:fedi/app/pending/pending_model.dart';
import 'package:fedi/app/status/status_model.dart';
import 'package:fedi/pleroma/api/application/pleroma_application_model.dart';
import 'package:fedi/pleroma/api/card/pleroma_card_model.dart';
import 'package:fedi/pleroma/api/emoji/pleroma_emoji_model.dart';
import 'package:fedi/pleroma/api/media/attachment/pleroma_media_attachment_model.dart';
import 'package:fedi/pleroma/api/mention/pleroma_mention_model.dart';
import 'package:fedi/pleroma/api/poll/pleroma_poll_model.dart';
import 'package:fedi/pleroma/api/status/pleroma_status_model.dart';
import 'package:fedi/pleroma/api/tag/pleroma_tag_model.dart';
import 'package:fedi/pleroma/api/visibility/pleroma_visibility_model.dart';

extension PleromaStatusDbExtension on IPleromaStatus {
  DbStatusPopulatedWrapper toDbStatusPopulatedWrapper() {
    if (this is DbStatusPopulatedWrapper) {
      return this as DbStatusPopulatedWrapper;
    } else {
      return DbStatusPopulatedWrapper(
        dbStatusPopulated: toDbStatusPopulated(),
      );
    }
  }

  DbStatusPopulated toDbStatusPopulated() {
    if (this is DbStatusPopulatedWrapper) {
      return (this as DbStatusPopulatedWrapper).dbStatusPopulated;
    } else {
      return DbStatusPopulated(
        dbStatus: toDbStatus(),
        dbAccount: account.toDbAccount(),
        reblogDbStatus: reblog?.toDbStatus(),
        reblogDbStatusAccount: reblog?.account.toDbAccount(),
        replyReblogDbStatus: null,
        replyDbStatusAccount: null,
        replyReblogDbStatusAccount: null,
        replyDbStatus: null,
      );
    }
  }

  // ignore: code-metrics
  DbStatus toDbStatus() {
    var remoteStatus = this;

    return DbStatus(
      id: null,
      remoteId: remoteStatus.id,
      createdAt: remoteStatus.createdAt,
      inReplyToRemoteId: remoteStatus.inReplyToId,
      inReplyToAccountRemoteId: remoteStatus.inReplyToAccountId,
      sensitive: remoteStatus.sensitive,
      spoilerText: remoteStatus.spoilerText,
      visibility: remoteStatus.visibilityPleroma,
      uri: remoteStatus.uri,
      url: remoteStatus.url,
      repliesCount: remoteStatus.repliesCount ?? 0,
      reblogsCount: remoteStatus.reblogsCount ?? 0,
      favouritesCount: remoteStatus.favouritesCount ?? 0,
      favourited: remoteStatus.favourited ?? false,
      reblogged: remoteStatus.reblogged ?? false,
      muted: remoteStatus.muted ?? false,
      bookmarked: remoteStatus.bookmarked,
      pinned: remoteStatus.pinned,
      language: remoteStatus.language,
      content: remoteStatus.content,
      reblogStatusRemoteId: remoteStatus.reblog?.id,
      application: remoteStatus.application?.toPleromaApplication(),
      mediaAttachments:
          remoteStatus.mediaAttachments?.toPleromaMediaAttachments(),
      mentions: remoteStatus.mentions?.toPleromaMentions(),
      tags: remoteStatus.tags?.toPleromaTags(),
      emojis: remoteStatus.emojis?.toPleromaEmojis(),
      poll: remoteStatus.poll?.toPleromaPoll(),
      card: remoteStatus.card?.toPleromaCard(),
      pleromaContent: remoteStatus.pleroma?.content,
      pleromaConversationId: remoteStatus.pleroma?.conversationId,
      pleromaDirectConversationId: remoteStatus.pleroma?.directConversationId,
      pleromaInReplyToAccountAcct: remoteStatus.pleroma?.inReplyToAccountAcct,
      pleromaLocal: remoteStatus.pleroma?.local,
      pleromaSpoilerText: remoteStatus.pleroma?.spoilerText,
      pleromaExpiresAt: remoteStatus.pleroma?.expiresAt,
      pleromaThreadMuted: remoteStatus.pleroma?.threadMuted,
      pleromaEmojiReactions:
          remoteStatus.pleroma?.emojiReactions?.toPleromaStatusEmojiReactions(),
      accountRemoteId: remoteStatus.account.id,
      // remote statuses always published
      pendingState: PendingState.published,
      wasSentWithIdempotencyKey: null,
      hiddenLocallyOnDevice: null,
      oldPendingRemoteId: null,
      deleted: null,
    );
  }
}

extension IStatusPleromaExtension on IStatus {
  PleromaStatusPleromaPart toPleromaStatusPleromaPart() =>
      PleromaStatusPleromaPart(
        content: pleromaContent,
        conversationId: pleromaConversationId,
        directConversationId: pleromaDirectConversationId,
        inReplyToAccountAcct: pleromaInReplyToAccountAcct,
        local: pleromaLocal,
        spoilerText: pleromaSpoilerText,
        expiresAt: pleromaExpiresAt,
        threadMuted: pleromaThreadMuted,
        emojiReactions: pleromaEmojiReactions,
      );

  PleromaStatus toPleromaStatus() {
    return PleromaStatus(
      id: remoteId!,
      createdAt: createdAt,
      inReplyToId: inReplyToRemoteId,
      inReplyToAccountId: inReplyToAccountRemoteId,
      sensitive: nsfwSensitive,
      spoilerText: spoilerText,
      visibility: visibility.toJsonValue(),
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
      reblog: reblog?.toPleromaStatus(),
      language: language,
      application: application,
      mediaAttachments: mediaAttachments,
      mentions: mentions,
      tags: tags,
      emojis: emojis,
      poll: poll,
      card: card,
      account: account.toPleromaAccount(),
      pleroma: toPleromaStatusPleromaPart(),
    );
  }
}
