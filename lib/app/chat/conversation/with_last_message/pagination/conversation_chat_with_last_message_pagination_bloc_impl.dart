import 'package:fedi/app/chat/conversation/with_last_message/conversation_chat_with_last_message_model.dart';
import 'package:fedi/app/chat/conversation/with_last_message/list/cached/conversation_chat_with_last_message_cached_list_bloc.dart';
import 'package:fedi/app/chat/conversation/with_last_message/pagination/conversation_chat_with_last_message_pagination_bloc.dart';
import 'package:fedi/app/pagination/cached/cached_pleroma_pagination_bloc_impl.dart';
import 'package:fedi/pagination/cached/cached_pagination_model.dart';
import 'package:fedi/pleroma/api/pleroma_api_service.dart';
import 'package:flutter/cupertino.dart';

class ConversationChatWithLastMessagePaginationBloc
    extends CachedPleromaPaginationBloc<IConversationChatWithLastMessage>
    implements IConversationChatWithLastMessagePaginationBloc {
  final IConversationChatWithLastMessageCachedBloc listService;

  ConversationChatWithLastMessagePaginationBloc(
      {@required this.listService,
      @required int itemsCountPerPage,
      @required int maximumCachedPagesCount})
      : super(
            maximumCachedPagesCount: maximumCachedPagesCount,
            itemsCountPerPage: itemsCountPerPage);

  @override
  IPleromaApi get pleromaApi => listService.pleromaApi;

  @override
  Future<List<IConversationChatWithLastMessage>> loadLocalItems(
          {@required
              int pageIndex,
          @required
              int itemsCountPerPage,
          @required
              CachedPaginationPage<IConversationChatWithLastMessage> olderPage,
          @required
              CachedPaginationPage<IConversationChatWithLastMessage>
                  newerPage}) =>
      listService.loadLocalItems(
        limit: itemsCountPerPage,
        newerThan: olderPage?.items?.first,
        olderThan: newerPage?.items?.last,
      );

  @override
  Future<bool> refreshItemsFromRemoteForPage(
      {@required
          int pageIndex,
      @required
          int itemsCountPerPage,
      @required
          CachedPaginationPage<IConversationChatWithLastMessage> olderPage,
      @required
          CachedPaginationPage<IConversationChatWithLastMessage>
              newerPage}) async {
    // can't refresh not first page without actual items bounds
    assert(!(pageIndex > 0 && olderPage == null && newerPage == null));

    return listService.refreshItemsFromRemoteForPage(
      limit: itemsCountPerPage,
      newerThan: olderPage?.items?.first,
      olderThan: newerPage?.items?.last,
    );
  }
}