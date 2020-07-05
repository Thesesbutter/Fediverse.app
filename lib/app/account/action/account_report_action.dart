import 'package:easy_localization/easy_localization.dart';
import 'package:fedi/app/account/account_bloc.dart';
import 'package:fedi/app/ui/notification_overlay/info_fedi_notification_overlay.dart';
import 'package:fedi/dialog/alert/simple_alert_dialog.dart';
import 'package:fedi/dialog/async/async_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool> doAsyncActionReport(BuildContext context,
    IAccountBloc accountBloc) async {
  var dialogResult = await doAsyncOperationWithDialog(
      context: context, asyncCode: () => accountBloc.report());

  var success = dialogResult.success;
  if (success) {
    showInfoFediNotificationOverlay(
        contentText: tr("app.account.action.report.success.toast"),
        titleText: null);
  } else {
    await SimpleAlertDialog(
      context: context,
      title: tr("app.account.action.report.fail.dialog.title"),
      content: tr("app.account.action.report.fail.dialog.content"),
    ).show(context);
  }
  return success;
}
