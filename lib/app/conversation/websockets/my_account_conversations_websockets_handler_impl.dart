import 'package:fedi/app/conversation/repository/conversation_repository.dart';
import 'package:fedi/app/notification/repository/notification_repository.dart';
import 'package:fedi/app/status/repository/status_repository.dart';
import 'package:fedi/app/websockets/web_sockets_handler_impl.dart';
import 'package:fedi/pleroma/websockets/pleroma_websockets_service.dart';
import 'package:flutter/widgets.dart';

class MyAccountConversationsWebSocketsHandler extends WebSocketsChannelHandler {
  MyAccountConversationsWebSocketsHandler(
      {@required IPleromaWebSocketsService pleromaWebSocketsService,
      @required IStatusRepository statusRepository,
      @required INotificationRepository notificationRepository,
      @required IConversationRepository conversationRepository})
      : super(
          webSocketsChannel:
              pleromaWebSocketsService.getDirectChannel(accountId: null),
          statusRepository: statusRepository,
          notificationRepository: notificationRepository,
          conversationRepository: conversationRepository,
        );

  static MyAccountConversationsWebSocketsHandler createFromContext(
          BuildContext context) =>
      MyAccountConversationsWebSocketsHandler(
        pleromaWebSocketsService:
            IPleromaWebSocketsService.of(context, listen: false),
        notificationRepository:
            INotificationRepository.of(context, listen: false),
        conversationRepository:
            IConversationRepository.of(context, listen: false),
        statusRepository: IStatusRepository.of(context, listen: false),
      );


  @override
  String get logTag => "my_account_conversations_websockets_handler_impl.dart";
}