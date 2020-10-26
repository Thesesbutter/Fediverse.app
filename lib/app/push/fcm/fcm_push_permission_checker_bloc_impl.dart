import 'package:fedi/app/push/fcm/fcm_push_permission_asked_local_preferences_bloc.dart';
import 'package:fedi/app/push/fcm/fcm_push_permission_checker_bloc.dart';
import 'package:fedi/app/push/subscription_settings/push_subscription_settings_bloc.dart';
import 'package:fedi/disposable/disposable_owner.dart';
import 'package:fedi/push/fcm/fcm_push_service.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

final _logger = Logger("fcm_push_permission_checker_bloc_impl.dart");

class FcmPushPermissionCheckerBloc extends DisposableOwner
    implements IFcmPushPermissionCheckerBloc {
  final IFcmPushService fcmPushService;
  final IFcmPushPermissionAskedLocalPreferencesBloc
      fcmPushPermissionAskedLocalPreferencesBloc;
  final IPushSubscriptionSettingsBloc pushSubscriptionSettingsBloc;

  FcmPushPermissionCheckerBloc({
    @required @required this.fcmPushService,
    @required this.fcmPushPermissionAskedLocalPreferencesBloc,
    @required this.pushSubscriptionSettingsBloc,
  });

  @override
  Future<bool> checkAndSubscribe() async {
    await fcmPushPermissionAskedLocalPreferencesBloc.setValue(true);
    var success = await fcmPushService.askPermissions();

    _logger.finest(() => "checkAndSubscribe success $success");

    var result;
    if (success) {
      try {
        _logger.finest(() => "checkAndSubscribe subscribeAllEnabled");
        await pushSubscriptionSettingsBloc.subscribeAllEnabled();
        result = true;
      } catch (e, stackTrace) {
        _logger.warning(
            () => "failed to subscribeWithDefaultPreferences", e, stackTrace);
        result = false;
      }
    } else {
      result = false;
    }

    _logger.finest(() => "checkAndSubscribe result $result");

    return result;
  }

  @override
  bool get isNeedCheckPermission =>
      !fcmPushPermissionAskedLocalPreferencesBloc.value &&
      !pushSubscriptionSettingsBloc.isHaveSubscription;

  @override
  Future onCheckDismissed() =>
      fcmPushPermissionAskedLocalPreferencesBloc.setValue(true);
}