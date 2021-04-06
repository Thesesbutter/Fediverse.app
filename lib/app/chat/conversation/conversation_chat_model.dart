import 'package:fedi/app/account/account_model.dart';
import 'package:fedi/app/chat/chat_model.dart';
import 'package:fedi/app/chat/conversation/message/conversation_chat_message_model.dart';
import 'package:fedi/app/chat/conversation/with_last_message/conversation_chat_with_last_message_model.dart';
import 'package:fedi/app/database/app_database.dart';
import 'package:fedi/app/status/status_model.dart';
import 'package:fedi/pleroma/conversation/pleroma_conversation_model.dart';

abstract class IConversationChat implements IChat {
  IPleromaConversationPleromaPart? get pleroma;

  @override
  IConversationChat copyWith({
    int? id,
    String? remoteId,
    int? unread,
    DateTime? updatedAt,
    List<IAccount>? accounts,
  });
}

class DbConversationPopulated {
  final DbConversation dbConversation;

  DbConversationPopulated({
    required this.dbConversation,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbConversationPopulated &&
          runtimeType == other.runtimeType &&
          dbConversation == other.dbConversation;

  @override
  int get hashCode => dbConversation.hashCode;

  @override
  String toString() {
    return 'DbConversationPopulated{'
        'dbConversation: $dbConversation'
        '}';
  }

  DbConversationPopulated copyWith({
    DbConversation? dbConversation,
  }) {
    return DbConversationPopulated(
      dbConversation: dbConversation ?? this.dbConversation,
    );
  }
}

class DbConversationChatPopulatedWrapper implements IConversationChat {
  final DbConversationPopulated dbConversationPopulated;

  DbConversationChatPopulatedWrapper({
    required this.dbConversationPopulated,
  });

  @override
  int? get localId => dbConversationPopulated.dbConversation.id;

  @override
  String get remoteId => dbConversationPopulated.dbConversation.remoteId;

  @override
  int get unread =>
      dbConversationPopulated.dbConversation.unread == true ? 1 : 0;

  @override
  String toString() {
    return 'DbConversationChatPopulatedWrapper{'
        'dbConversationPopulated: $dbConversationPopulated'
        '}';
  }

  @override
  DbConversationChatPopulatedWrapper copyWith({
    int? id,
    String? remoteId,
    int? unread,
    DateTime? updatedAt,
    List<IAccount>? accounts,
  }) {
    if (accounts != null) {
      throw UnimplementedError();
    }
    return DbConversationChatPopulatedWrapper(
      dbConversationPopulated: DbConversationPopulated(
          dbConversation: dbConversationPopulated.dbConversation.copyWith(
        id: id ?? localId,
        remoteId: remoteId ?? this.remoteId,
        unread: unread != null
            ? unread > 0
                ? true
                : false
            : this.unread > 0
                ? true
                : false,
        updatedAt: updatedAt ?? this.updatedAt,
      )),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbConversationChatPopulatedWrapper &&
          runtimeType == other.runtimeType &&
          dbConversationPopulated == other.dbConversationPopulated;

  @override
  int get hashCode => dbConversationPopulated.hashCode;

  @override
  DateTime? get updatedAt => dbConversationPopulated.dbConversation.updatedAt;

  @override
  // todo: implement
  IPleromaConversationPleromaPart? get pleroma => null;

  @override
  List<IAccount> get accounts => throw Exception(
        "accounts not included in ConversationChat "
        "and should be manually fetched from repository",
      );
}

class DbConversationChatWithLastMessagePopulated {
  final DbConversationPopulated dbConversationPopulated;
  final DbStatusPopulated? dbStatusPopulated;

  DbConversationChatWithLastMessagePopulated({
    required this.dbConversationPopulated,
    required this.dbStatusPopulated,
  });
}

class DbConversationChatWithLastMessagePopulatedWrapper
    implements IConversationChatWithLastMessage {
  final DbConversationChatWithLastMessagePopulated
      dbConversationChatWithLastMessagePopulated;

  DbConversationChatWithLastMessagePopulatedWrapper({
    required this.dbConversationChatWithLastMessagePopulated,
  });

  @override
  IConversationChat get chat => DbConversationChatPopulatedWrapper(
        dbConversationPopulated:
            dbConversationChatWithLastMessagePopulated.dbConversationPopulated,
      );

  @override
  IConversationChatMessage? get lastChatMessage =>
      dbConversationChatWithLastMessagePopulated.dbStatusPopulated != null
          ? ConversationChatMessageStatusAdapter(
              status: DbStatusPopulatedWrapper(
                dbStatusPopulated: dbConversationChatWithLastMessagePopulated
                    .dbStatusPopulated!,
              ),
            )
          : null;
}
