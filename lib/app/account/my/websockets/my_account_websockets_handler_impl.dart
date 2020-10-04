import 'package:fedi/app/chat/chat_new_messages_handler_bloc.dart';
import 'package:fedi/app/conversation/repository/conversation_repository.dart';
import 'package:fedi/app/notification/repository/notification_repository.dart';
import 'package:fedi/app/status/repository/status_repository.dart';
import 'package:fedi/app/websockets/web_sockets_handler_impl.dart';
import 'package:fedi/pleroma/websockets/pleroma_websockets_model.dart';
import 'package:fedi/pleroma/websockets/pleroma_websockets_service.dart';
import 'package:flutter/widgets.dart';

class MyAccountWebSocketsHandler extends WebSocketsChannelHandler {
  MyAccountWebSocketsHandler({
    @required IPleromaWebSocketsService pleromaWebSocketsService,
    @required IStatusRepository statusRepository,
    @required INotificationRepository notificationRepository,
    @required IConversationRepository conversationRepository,
    @required IChatNewMessagesHandlerBloc chatNewMessagesHandlerBloc,
    @required bool chat,
    @required bool notification,
  }) : super(
          webSocketsChannel: pleromaWebSocketsService.getMyAccountChannel(
            chat: chat,
            notification: notification,
          ),
          statusRepository: statusRepository,
          notificationRepository: notificationRepository,
          conversationRepository: conversationRepository,
          chatNewMessagesHandlerBloc: chatNewMessagesHandlerBloc,
          statusListRemoteId: null,
          statusConversationRemoteId: null,
          isFromHomeTimeline: true,
        );

  static MyAccountWebSocketsHandler createFromContext(
    BuildContext context, {
    @required bool chat,
    @required bool notification,
  }) =>
      MyAccountWebSocketsHandler(
        chat: chat,
        notification: notification,
        pleromaWebSocketsService:
            IPleromaWebSocketsService.of(context, listen: false),
        notificationRepository:
            INotificationRepository.of(context, listen: false),
        conversationRepository:
            IConversationRepository.of(context, listen: false),
        statusRepository: IStatusRepository.of(context, listen: false),
        chatNewMessagesHandlerBloc:
            IChatNewMessagesHandlerBloc.of(context, listen: false),
      );

  @override
  Future handleEvent(PleromaWebSocketsEvent event) async {

    // todo: remove hack
    // it is for isHomeTimeline flag
    // other websockets handle can handle same Status and override this flag
    // we should be sure that handler with isHomeTimeline executes after all
    // other handlers
    await Future.delayed(Duration(milliseconds: 500));
    return super.handleEvent(event);
  }


  @override
  String get logTag => "my_notifications_websockets_handler_impl.dart";
}