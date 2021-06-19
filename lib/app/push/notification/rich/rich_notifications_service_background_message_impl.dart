import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:collection/collection.dart';
import 'package:fedi/app/auth/instance/auth_instance_model.dart';
import 'package:fedi/app/auth/instance/list/local_preferences/auth_instance_list_local_preference_bloc_impl.dart';
import 'package:fedi/app/config/config_service_impl.dart';
import 'package:fedi/app/hive/hive_service_impl.dart';
import 'package:fedi/app/localization/settings/local_preferences/global/global_localization_settings_local_preference_bloc_impl.dart';
import 'package:fedi/app/logging/logging_service_impl.dart';
import 'package:fedi/app/push/notification/rich/rich_notifications_service.dart';
import 'package:fedi/app/push/settings/local_preferences/instance/instance_push_settings_local_preference_bloc_impl.dart';
import 'package:fedi/app/push/settings/push_settings_model.dart';
import 'package:fedi/app/ui/theme/light/light_fedi_ui_theme_model.dart';
import 'package:fedi/async/loading/init/async_init_loading_bloc_impl.dart';
import 'package:fedi/connection/connection_service_impl.dart';
import 'package:fedi/disposable/disposable_owner.dart';
import 'package:fedi/generated/l10n.dart';
import 'package:fedi/local_preferences/hive_local_preferences_service_impl.dart';
import 'package:fedi/local_preferences/local_preferences_service.dart';
import 'package:fedi/localization/localization_model.dart';
import 'package:fedi/pleroma/api/media/attachment/pleroma_api_media_attachment_model.dart';
import 'package:fedi/pleroma/api/notification/pleroma_api_notification_model.dart';
import 'package:fedi/pleroma/api/notification/pleroma_api_notification_service_impl.dart';
import 'package:fedi/pleroma/api/pagination/pleroma_api_pagination_model.dart';
import 'package:fedi/pleroma/api/rest/auth/pleroma_api_auth_rest_service_impl.dart';
import 'package:fedi/rest/rest_service_impl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';

var _logger = Logger('rich_notifications_service_background_message_impl.dart');

const _pushDataAccountKey = 'account';
const _pushDataServerKey = 'server';

const _followChannelKey = 'push.follow';
const _favouriteChannelKey = 'push.favourite';
const _favouriteChannelGroupKey = 'push.favourite.group';
const _reblogChannelKey = 'push.reblog';
const _reblogChannelGroupKey = 'push.reblog.group';
const _mentionChannelKey = 'push.mention';
const _pollChannelKey = 'push.poll';
const _moveChannelKey = 'push.move';
const _followRequestChannelKey = 'push.followRequest';
const _pleromaEmojiReactionChannelKey = 'push.pleromaEmojiReaction';
const _pleromaEmojiReactionGroupKey = 'push.pleromaEmojiReaction.group';
const _pleromaChatMentionChannelKey = 'push.pleromaChatMention';
const _pleromaReportChannelKey = 'push.pleromaReport';
const _unknownChannelKey = 'push.unknown';

class RichNotificationsServiceBackgroundMessage extends AsyncInitLoadingBloc
    implements IRichNotificationsService {
  final S localizationContext;

  RichNotificationsServiceBackgroundMessage({
    required this.localizationContext,
  });

  @override
  Future internalAsyncInit() async {
    var awesomeNotifications = AwesomeNotifications();
    await awesomeNotifications.initialize(
      // android only
      'resource://drawable/ic_stat_name',
      [
        _createFollowChannel(),
        _createFavouriteChannel(),
        _createReblogChannel(),
        _createMentionChannel(),
        _createPollChannel(),
        _createMoveChannel(),
        _createFollowRequestChannel(),
        _createPleromaEmojiReactionChannel(),
        _createPleromaChatMentionChannel(),
        _createPleromaReportChannel(),
        _createUnknownChannel(),
      ],
    );

    awesomeNotifications.actionStream.listen((ReceivedAction receivedAction) {

      _logger.finest(() => 'receivedAction ${receivedAction.toMap()}');
    });

  }

  NotificationChannel _createFollowChannel() => NotificationChannel(
        channelKey: _followChannelKey,
        channelName: localizationContext.app_push_channel_follow_name,
        channelDescription:
            localizationContext.app_push_channel_follow_description,
        channelShowBadge: true,
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: false,
        enableLights: true,
        ledColor: lightFediUiTheme.colorTheme.primary,
        groupKey: null,
        groupSort: null,
        groupAlertBehavior: null,
        defaultPrivacy: NotificationPrivacy.Public,
        defaultColor: lightFediUiTheme.colorTheme.darkGrey,
        locked: false,
        onlyAlertOnce: false,
      );

  NotificationChannel _createFavouriteChannel() => NotificationChannel(
        channelKey: _favouriteChannelKey,
        channelName: localizationContext.app_push_channel_favourite_name,
        channelDescription:
            localizationContext.app_push_channel_favourite_description,
        channelShowBadge: false,
        importance: NotificationImportance.Default,
        playSound: false,
        enableVibration: false,
        enableLights: false,
        ledColor: lightFediUiTheme.colorTheme.primary,
        groupKey: _favouriteChannelGroupKey,
        groupSort: GroupSort.Desc,
        groupAlertBehavior: GroupAlertBehavior.All,
        defaultPrivacy: NotificationPrivacy.Public,
        defaultColor: lightFediUiTheme.colorTheme.darkGrey,
        locked: false,
        onlyAlertOnce: false,
      );

  NotificationChannel _createReblogChannel() => NotificationChannel(
        channelKey: _reblogChannelKey,
        channelName: localizationContext.app_push_channel_reblog_name,
        channelDescription:
            localizationContext.app_push_channel_reblog_description,
        channelShowBadge: true,
        importance: NotificationImportance.Default,
        playSound: true,
        enableVibration: true,
        enableLights: false,
        ledColor: lightFediUiTheme.colorTheme.primary,
        groupKey: _reblogChannelGroupKey,
        groupSort: GroupSort.Desc,
        groupAlertBehavior: GroupAlertBehavior.All,
        defaultPrivacy: NotificationPrivacy.Public,
        defaultColor: lightFediUiTheme.colorTheme.darkGrey,
        locked: false,
        onlyAlertOnce: false,
      );

  NotificationChannel _createMentionChannel() => NotificationChannel(
        channelKey: _mentionChannelKey,
        channelName: localizationContext.app_push_channel_mention_name,
        channelDescription:
            localizationContext.app_push_channel_mention_description,
        channelShowBadge: true,
        importance: NotificationImportance.Max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: lightFediUiTheme.colorTheme.primary,
        groupKey: null,
        groupSort: null,
        groupAlertBehavior: null,
        defaultPrivacy: NotificationPrivacy.Public,
        defaultColor: lightFediUiTheme.colorTheme.darkGrey,
        locked: false,
        onlyAlertOnce: false,
      );

  NotificationChannel _createPollChannel() => NotificationChannel(
        channelKey: _pollChannelKey,
        channelName: localizationContext.app_push_channel_poll_name,
        channelDescription:
            localizationContext.app_push_channel_poll_description,
        channelShowBadge: false,
        importance: NotificationImportance.Default,
        playSound: false,
        enableVibration: false,
        enableLights: false,
        ledColor: lightFediUiTheme.colorTheme.primary,
        groupKey: null,
        groupSort: null,
        groupAlertBehavior: null,
        defaultPrivacy: NotificationPrivacy.Public,
        defaultColor: lightFediUiTheme.colorTheme.darkGrey,
        locked: false,
        onlyAlertOnce: false,
      );

  NotificationChannel _createMoveChannel() => NotificationChannel(
        channelKey: _moveChannelKey,
        channelName: localizationContext.app_push_channel_move_name,
        channelDescription:
            localizationContext.app_push_channel_move_description,
        channelShowBadge: false,
        importance: NotificationImportance.Default,
        playSound: false,
        enableVibration: false,
        enableLights: false,
        ledColor: lightFediUiTheme.colorTheme.primary,
        groupKey: null,
        groupSort: null,
        groupAlertBehavior: null,
        defaultPrivacy: NotificationPrivacy.Public,
        defaultColor: lightFediUiTheme.colorTheme.darkGrey,
        locked: false,
        onlyAlertOnce: false,
      );

  NotificationChannel _createFollowRequestChannel() => NotificationChannel(
        channelKey: _followRequestChannelKey,
        channelName: localizationContext.app_push_channel_followRequest_name,
        channelDescription:
            localizationContext.app_push_channel_followRequest_description,
        channelShowBadge: true,
        importance: NotificationImportance.Max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: lightFediUiTheme.colorTheme.primary,
        groupKey: null,
        groupSort: null,
        groupAlertBehavior: null,
        defaultPrivacy: NotificationPrivacy.Public,
        defaultColor: lightFediUiTheme.colorTheme.darkGrey,
        locked: false,
        onlyAlertOnce: false,
      );

  NotificationChannel _createPleromaEmojiReactionChannel() =>
      NotificationChannel(
        channelKey: _pleromaEmojiReactionChannelKey,
        channelName:
            localizationContext.app_push_channel_pleromaEmojiReaction_name,
        channelDescription: localizationContext
            .app_push_channel_pleromaEmojiReaction_description,
        channelShowBadge: false,
        importance: NotificationImportance.Default,
        playSound: false,
        enableVibration: false,
        enableLights: false,
        ledColor: lightFediUiTheme.colorTheme.primary,
        groupKey: _pleromaEmojiReactionGroupKey,
        groupSort: GroupSort.Desc,
        groupAlertBehavior: GroupAlertBehavior.Children,
        defaultPrivacy: NotificationPrivacy.Public,
        defaultColor: lightFediUiTheme.colorTheme.darkGrey,
        locked: false,
        onlyAlertOnce: false,
      );

  NotificationChannel _createPleromaChatMentionChannel() => NotificationChannel(
        channelKey: _pleromaChatMentionChannelKey,
        channelName:
            localizationContext.app_push_channel_pleromaChatMention_name,
        channelDescription:
            localizationContext.app_push_channel_pleromaChatMention_description,
        channelShowBadge: true,
        importance: NotificationImportance.Max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: lightFediUiTheme.colorTheme.primary,
        groupKey: null,
        groupSort: GroupSort.Desc,
        groupAlertBehavior: GroupAlertBehavior.All,
        defaultPrivacy: NotificationPrivacy.Private,
        defaultColor: lightFediUiTheme.colorTheme.darkGrey,
        locked: false,
        onlyAlertOnce: false,
      );

  NotificationChannel _createPleromaReportChannel() => NotificationChannel(
        channelKey: _pleromaReportChannelKey,
        channelName: localizationContext.app_push_channel_pleromaReport_name,
        channelDescription:
            localizationContext.app_push_channel_pleromaReport_description,
        channelShowBadge: true,
        importance: NotificationImportance.Default,
        playSound: true,
        enableVibration: true,
        enableLights: false,
        ledColor: lightFediUiTheme.colorTheme.primary,
        groupKey: null,
        groupSort: null,
        groupAlertBehavior: null,
        defaultPrivacy: NotificationPrivacy.Public,
        defaultColor: lightFediUiTheme.colorTheme.darkGrey,
        locked: false,
        onlyAlertOnce: false,
      );

  NotificationChannel _createUnknownChannel() => NotificationChannel(
        channelKey: _unknownChannelKey,
        channelName: localizationContext.app_push_channel_unknown_name,
        channelDescription:
            localizationContext.app_push_channel_unknown_description,
        channelShowBadge: true,
        importance: NotificationImportance.Default,
        playSound: false,
        enableVibration: false,
        enableLights: false,
        ledColor: lightFediUiTheme.colorTheme.primary,
        groupKey: null,
        groupSort: null,
        groupAlertBehavior: null,
        defaultPrivacy: NotificationPrivacy.Public,
        defaultColor: lightFediUiTheme.colorTheme.darkGrey,
        locked: false,
        onlyAlertOnce: false,
      );
}

Future richNotificationsFirebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  print('richNotificationsFirebaseMessagingBackgroundHandler');

  var disposableOwner = DisposableOwner();

  var configService = ConfigService();
  await configService.performAsyncInit();
  disposableOwner.addDisposable(disposable: configService);
  var loggingService = LoggingService(enabled: configService.logEnabled);
  await loggingService.performAsyncInit();
  disposableOwner.addDisposable(disposable: loggingService);
  _logger.finest(() => 'Handling a background message: $message');

  var notification = message.notification;
  var data = message.data;
  _logger.finest(
    () => 'Background message notification $notification data: $data',
  );

  if (data.containsKey(_pushDataAccountKey) &&
      data.containsKey(_pushDataServerKey)) {
    var account = data[_pushDataAccountKey];
    var server = data[_pushDataServerKey];

    await _handleRichNotification(
      acct: account,
      host: server,
    );
  }

  await disposableOwner.dispose();
}

Future _handleRichNotification({
  required String acct,
  required String host,
}) async {
  var disposableOwner = DisposableOwner();

  _logger.finest(() => 'Background message for $acct@$host');

  var hiveService = HiveService();
  await hiveService.performAsyncInit();
  disposableOwner.addDisposable(disposable: hiveService);

  var hiveLocalPreferencesService =
      HiveLocalPreferencesService.withLastVersionBoxName();
  await hiveLocalPreferencesService.performAsyncInit();
  disposableOwner.addDisposable(disposable: hiveLocalPreferencesService);

  var foundInstance = await _findInstanceByUserAtHost(
    localPreferencesService: hiveLocalPreferencesService,
    acct: acct,
    host: host,
  );

  if (foundInstance == null) {
    _logger.warning(() => 'instance for $acct@$host not found');
    await disposableOwner.dispose();
  } else {
    await _proceedNotificationForInstance(
      localPreferencesService: hiveLocalPreferencesService,
      authInstance: foundInstance,
    );

    await disposableOwner.dispose();
  }
}

Future _proceedNotificationForInstance({
  required ILocalPreferencesService localPreferencesService,
  required AuthInstance authInstance,
}) async {
  var pleromaApiNotification = await _loadLastNotificationForInstance(
    localPreferencesService: localPreferencesService,
    authInstance: authInstance,
  );

  if (pleromaApiNotification == null) {
    _logger.warning(
      () => 'failed to load not notification for push. It is empty',
    );
  } else {
    await _createPushForNotification(
      localPreferencesService: localPreferencesService,
      authInstance: authInstance,
      pleromaApiNotification: pleromaApiNotification,
    );
  }
}

Future<IPleromaApiNotification?> _loadLastNotificationForInstance({
  required ILocalPreferencesService localPreferencesService,
  required AuthInstance authInstance,
}) async {
  var disposableOwner = DisposableOwner();

  var userAtHost = authInstance.userAtHost;

  var instancePushSettingsLocalPreferenceBloc =
      InstancePushSettingsLocalPreferenceBloc(
    localPreferencesService,
    userAtHost: userAtHost,
  );
  await instancePushSettingsLocalPreferenceBloc.performAsyncInit();
  disposableOwner.addDisposable(
    disposable: instancePushSettingsLocalPreferenceBloc,
  );

  var pushSettings = instancePushSettingsLocalPreferenceBloc.value;

  var connectionService = ConnectionService();
  await connectionService.performAsyncInit();
  disposableOwner.addDisposable(disposable: connectionService);

  var restService = RestService(baseUri: authInstance.uri);
  disposableOwner.addDisposable(disposable: restService);

  var pleromaApiAuthRestService = PleromaApiAuthRestService(
    restService: restService,
    connectionService: connectionService,
    isPleroma: authInstance.isPleroma,
    accessToken: authInstance.token!.accessToken,
  );
  disposableOwner.addDisposable(disposable: pleromaApiAuthRestService);

  var pleromaApiNotificationService =
      PleromaApiNotificationService(restService: pleromaApiAuthRestService);
  disposableOwner.addDisposable(disposable: pleromaApiNotificationService);

  try {
    var pleromaApiNotifications =
        await pleromaApiNotificationService.getNotifications(
      pagination: PleromaApiPaginationRequest(
        limit: 1,
      ),
      excludeTypes: _calculateExcludePushNotificationTypesBaseOnPushSettings(
        pushSettings: pushSettings,
        isPleroma: authInstance.isPleroma,
      ),
      includeTypes: _calculateIncludePushNotificationTypesBaseOnPushSettings(
        pushSettings: pushSettings,
        isPleroma: authInstance.isPleroma,
      ),
    );

    return pleromaApiNotifications.firstOrNull;
  } catch (e, stackTrace) {
    _logger.warning(() => 'failed to load notification', e, stackTrace);

    return null;
  } finally {
    await disposableOwner.dispose();
  }
}

List<PleromaApiNotificationType>
    _calculateExcludePushNotificationTypesBaseOnPushSettings({
  required PushSettings pushSettings,
  required bool isPleroma,
}) {
  return [
    if (pushSettings.favourite != true) PleromaApiNotificationType.favourite,
    if (pushSettings.follow != true) PleromaApiNotificationType.follow,
    if (pushSettings.mention != true) PleromaApiNotificationType.mention,
    if (pushSettings.reblog != true) PleromaApiNotificationType.reblog,
    if (pushSettings.poll != true) PleromaApiNotificationType.poll,
    if (pushSettings.pleromaChatMention != true && isPleroma)
      PleromaApiNotificationType.pleromaChatMention,
    if (pushSettings.pleromaEmojiReaction != true && isPleroma)
      PleromaApiNotificationType.pleromaEmojiReaction,
  ];
}

List<PleromaApiNotificationType>
    _calculateIncludePushNotificationTypesBaseOnPushSettings({
  required PushSettings pushSettings,
  required bool isPleroma,
}) {
  return [
    if (pushSettings.favourite == true) PleromaApiNotificationType.favourite,
    if (pushSettings.follow == true) PleromaApiNotificationType.follow,
    if (pushSettings.mention == true) PleromaApiNotificationType.mention,
    if (pushSettings.reblog == true) PleromaApiNotificationType.reblog,
    if (pushSettings.poll == true) PleromaApiNotificationType.poll,
    if (pushSettings.pleromaChatMention == true && isPleroma)
      PleromaApiNotificationType.pleromaChatMention,
    if (pushSettings.pleromaEmojiReaction == true && isPleroma)
      PleromaApiNotificationType.pleromaEmojiReaction,
    if (isPleroma) PleromaApiNotificationType.pleromaReport,
  ];
}

const _notificationContentPayloadUserAtHostKey = 'userAtHost';
const _notificationContentPayloadNotificationJsonKey = 'notificationJson';
const _acceptFollowRequestActionKey = 'acceptFollowRequestActionKey';
const _rejectFollowRequestActionKey = 'rejectFollowRequestActionKey';
const _replyActionKey = 'replyActionKey';

// ignore: long-method
Future<void> _createPushForNotification({
  required ILocalPreferencesService localPreferencesService,
  required AuthInstance authInstance,
  required IPleromaApiNotification pleromaApiNotification,
}) async {
  _logger.finest(() => 'create push for $pleromaApiNotification');

  var disposableOwner = DisposableOwner();

  var globalLocalizationSettingsLocalPreferenceBloc =
      GlobalLocalizationSettingsLocalPreferenceBloc(
    localPreferencesService,
  );
  await globalLocalizationSettingsLocalPreferenceBloc.performAsyncInit();
  disposableOwner.addDisposable(
    disposable: globalLocalizationSettingsLocalPreferenceBloc,
  );

  var localizationSettings =
      globalLocalizationSettingsLocalPreferenceBloc.value;

  var localizationLocale = localizationSettings.localizationLocale;
  var locale = LocalizationLocale
      .calculateLocaleBaseOnLocalizationLocaleOrPlatformLocale(
    localizationLocale: localizationLocale,
  );
  var localizationContext = await S.load(
    locale,
  );

  var status = pleromaApiNotification.status;
  var chatMessage = pleromaApiNotification.chatMessage;

  IPleromaApiMediaAttachment? mediaAttachment;
  String? body;

  var pleromaApiNotificationType = pleromaApiNotification.typeAsPleromaApi;

  var isMentionType =
      pleromaApiNotificationType == PleromaApiNotificationType.mention;
  var isFollowRequestType =
      pleromaApiNotificationType == PleromaApiNotificationType.followRequest;
  var isPleromaChatMentionType = pleromaApiNotificationType ==
      PleromaApiNotificationType.pleromaChatMention;
  if (isMentionType && status != null) {
    if (!status.sensitive) {
      mediaAttachment = status.mediaAttachments?.firstOrNull;
    }
    var spoilerText = status.spoilerText;
    if (spoilerText?.isNotEmpty == true) {
      body = spoilerText;
    } else {
      body = status.content;
    }
  } else if (isPleromaChatMentionType && chatMessage != null) {
    mediaAttachment = chatMessage.mediaAttachment;
    body = chatMessage.content;
  }
  NotificationLayout layout;
  if (body?.isNotEmpty == true) {
    layout = NotificationLayout.BigText;
  } else if (mediaAttachment != null) {
    layout = NotificationLayout.BigPicture;
  } else {
    layout = NotificationLayout.Default;
  }


  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: _extractNotificationId(pleromaApiNotification),
      channelKey: _calculateChannelKey(pleromaApiNotification),
      title: calculateTitle(
        localizationContext: localizationContext,
        pleromaApiNotification: pleromaApiNotification,
      ),
      body: body,
      summary: calculateSummary(
        localizationContext: localizationContext,
        pleromaApiNotification: pleromaApiNotification,
      ),
      showWhen: true,
      icon: null,
      largeIcon: pleromaApiNotification.account?.avatar,
      bigPicture: mediaAttachment?.url,
      customSound: null,
      autoCancel: true,
      color: lightFediUiTheme.colorTheme.darkGrey,
      backgroundColor: lightFediUiTheme.colorTheme.white,
      payload: {
        _notificationContentPayloadUserAtHostKey: authInstance.userAtHost,
        _notificationContentPayloadNotificationJsonKey: json.encode(
          pleromaApiNotification.toJson(),
        ),
      },
      notificationLayout: layout,
      hideLargeIconOnExpand: false,
      ticker: null,
      createdDate: pleromaApiNotification.createdAt.toIso8601String(),
    ),
    actionButtons: [
      if (isFollowRequestType)
        NotificationActionButton(
          key: _acceptFollowRequestActionKey,
          label: localizationContext
              .app_push_richNotification_action_acceptFollowRequest,
          enabled: true,
          autoCancel: true,
          buttonType: ActionButtonType.Default,
        ),
      if (isFollowRequestType)
        NotificationActionButton(
          key: _rejectFollowRequestActionKey,
          label: localizationContext
              .app_push_richNotification_action_rejectFollowRequest,
          enabled: true,
          autoCancel: true,
          buttonType: ActionButtonType.Default,
        ),
      if (isPleromaChatMentionType || isMentionType)
        NotificationActionButton(
          key: _replyActionKey,
          label: localizationContext.app_push_richNotification_action_reply,
          enabled: true,
          autoCancel: true,
          buttonType: ActionButtonType.InputField,
        ),
    ],
  );

  await disposableOwner.dispose();
}

String? calculateSummary({
  required S localizationContext,
  required IPleromaApiNotification pleromaApiNotification,
}) {
  String? summary;

  switch (pleromaApiNotification.typeAsPleromaApi) {
    case PleromaApiNotificationType.follow:
      summary = localizationContext.app_push_richNotification_follow_summary;
      break;
    case PleromaApiNotificationType.favourite:
      summary = localizationContext.app_push_richNotification_favourite_summary;
      break;
    case PleromaApiNotificationType.reblog:
      summary = localizationContext.app_push_richNotification_reblog_summary;
      break;
    case PleromaApiNotificationType.mention:
      summary = localizationContext.app_push_richNotification_mention_summary;
      break;
    case PleromaApiNotificationType.poll:
      summary = localizationContext.app_push_richNotification_poll_summary;
      break;
    case PleromaApiNotificationType.move:
      summary = localizationContext.app_push_richNotification_move_summary;
      break;
    case PleromaApiNotificationType.followRequest:
      summary =
          localizationContext.app_push_richNotification_followRequest_summary;
      break;
    case PleromaApiNotificationType.pleromaEmojiReaction:
      summary = localizationContext
          .app_push_richNotification_pleromaEmojiReaction_summary;
      break;
    case PleromaApiNotificationType.pleromaChatMention:
      summary = localizationContext
          .app_push_richNotification_pleromaChatMention_summary;
      break;
    case PleromaApiNotificationType.pleromaReport:
      summary =
          localizationContext.app_push_richNotification_pleromaReport_summary;
      break;
    case PleromaApiNotificationType.unknown:
      summary = localizationContext.app_push_richNotification_unknown_summary;
      break;
  }

  return summary;
}

String? calculateTitle({
  required S localizationContext,
  required IPleromaApiNotification pleromaApiNotification,
}) {
  String? title;
  var acct = pleromaApiNotification.account?.acct ?? '';

  switch (pleromaApiNotification.typeAsPleromaApi) {
    case PleromaApiNotificationType.follow:
      title = localizationContext.app_push_richNotification_follow_title(acct);
      break;
    case PleromaApiNotificationType.favourite:
      title =
          localizationContext.app_push_richNotification_favourite_title(acct);
      break;
    case PleromaApiNotificationType.reblog:
      title = localizationContext.app_push_richNotification_reblog_title(acct);
      break;
    case PleromaApiNotificationType.mention:
      title = localizationContext.app_push_richNotification_mention_title(acct);
      break;
    case PleromaApiNotificationType.poll:
      title = localizationContext.app_push_richNotification_poll_title;
      break;
    case PleromaApiNotificationType.move:
      title = localizationContext.app_push_richNotification_move_title(acct);
      break;
    case PleromaApiNotificationType.followRequest:
      title = localizationContext
          .app_push_richNotification_followRequest_title(acct);
      break;
    case PleromaApiNotificationType.pleromaEmojiReaction:
      title = localizationContext
          .app_push_richNotification_pleromaEmojiReaction_title(
        acct,
        pleromaApiNotification.emoji!,
      );
      break;
    case PleromaApiNotificationType.pleromaChatMention:
      title = localizationContext
          .app_push_richNotification_pleromaChatMention_title(acct);
      break;
    case PleromaApiNotificationType.pleromaReport:
      title = localizationContext
          .app_push_richNotification_pleromaReport_title(acct);
      break;
    case PleromaApiNotificationType.unknown:
      title = localizationContext.app_push_richNotification_unknown_title;
      break;
  }

  return title;
}

String _calculateChannelKey(IPleromaApiNotification pleromaApiNotification) {
  String channelKey;

  switch (pleromaApiNotification.typeAsPleromaApi) {
    case PleromaApiNotificationType.follow:
      channelKey = _followChannelKey;
      break;
    case PleromaApiNotificationType.favourite:
      channelKey = _favouriteChannelKey;
      break;
    case PleromaApiNotificationType.reblog:
      channelKey = _reblogChannelKey;
      break;
    case PleromaApiNotificationType.mention:
      channelKey = _mentionChannelKey;
      break;
    case PleromaApiNotificationType.poll:
      channelKey = _pollChannelKey;
      break;
    case PleromaApiNotificationType.move:
      channelKey = _moveChannelKey;
      break;
    case PleromaApiNotificationType.followRequest:
      channelKey = _followRequestChannelKey;
      break;
    case PleromaApiNotificationType.pleromaEmojiReaction:
      channelKey = _pleromaEmojiReactionChannelKey;
      break;
    case PleromaApiNotificationType.pleromaChatMention:
      channelKey = _pleromaChatMentionChannelKey;
      break;
    case PleromaApiNotificationType.pleromaReport:
      channelKey = _pleromaReportChannelKey;
      break;
    case PleromaApiNotificationType.unknown:
      channelKey = _unknownChannelKey;
      break;
  }

  return channelKey;
}

int _extractNotificationId(IPleromaApiNotification pleromaApiNotification) {
  try {
    // usually id is int type
    return int.parse(pleromaApiNotification.id);
  } catch (_) {
    // if id is not it just use ms from epoch to make it unique
    return DateTime.now().millisecondsSinceEpoch;
  }
}

Future<AuthInstance?> _findInstanceByUserAtHost({
  required String acct,
  required String host,
  required ILocalPreferencesService localPreferencesService,
}) async {
  var disposableOwner = DisposableOwner();

  var authInstanceListLocalPreferenceBloc =
      AuthInstanceListLocalPreferenceBloc(localPreferencesService);
  await authInstanceListLocalPreferenceBloc.performAsyncInit();
  disposableOwner.addDisposable(
    disposable: authInstanceListLocalPreferenceBloc,
  );

  var authInstanceList = authInstanceListLocalPreferenceBloc.value!;

  AuthInstance? foundInstance;

  for (var authInstance in authInstanceList.instances) {
    var found = authInstance.isInstanceWithHostAndAcct(
      host: host,
      acct: acct,
    );
    if (found) {
      foundInstance = authInstance;
      break;
    }
  }

  await disposableOwner.dispose();

  return foundInstance;
}
