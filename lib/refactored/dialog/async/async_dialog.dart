import 'package:async/async.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fedi/refactored/dialog/alert/simple_alert_dialog.dart';
import 'package:fedi/refactored/dialog/async/async_dialog_model.dart';
import 'package:fedi/refactored/dialog/base_dialog.dart';
import 'package:fedi/refactored/dialog/progress/indeterminate_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

Logger _logger = Logger("async_dialog.dart");

typedef BaseDialog ErrorAlertDialogHandler(dynamic error);

Future<AsyncDialogResult<T>> doAsyncOperationWithProgressDialog<T>({
  @required BuildContext context,
  @required Future<T> asyncCode(),
  String contentMessage,
  List<ErrorAlertDialogHandler> errorAlertDialogHandlers: const [],
  bool showDefaultErrorAlertDialogOnUnhandledError: true,
  bool cancelable = false,
}) async {
  T result;
  CancelableOperation<T> cancelableOperation =
      CancelableOperation.fromFuture(asyncCode());
  var progressDialog = IndeterminateProgressDialog(
      cancelable: cancelable,
      contentMessage: contentMessage ??
          AppLocalizations.of(context).tr("dialog.progress.content"),
      cancelableOperation: cancelableOperation);
  progressDialog.show(context);
  var error;
  BaseDialog errorDialog;

  var needRethrow = true;

  try {
    result = await cancelableOperation.valueOrCancellation(null);
  } catch (e, stackTrace) {
    error = e;
    for (var handler in errorAlertDialogHandlers ?? []) {
      errorDialog = handler(e);
      if (errorDialog != null) {
        needRethrow = false;
        break;
      }
    }

    if (errorDialog == null && showDefaultErrorAlertDialogOnUnhandledError) {
      errorDialog = SimpleAlertDialog(
        context: context,
        title: AppLocalizations.of(context).tr("dialog.error.title"),
        content: AppLocalizations.of(context).tr("dialog.error.content"),
      );
    }

    if (needRethrow) {
      _logger.severe(() => "rethrow error during "
          "doAsyncOperationWithProgressDialog");
    } else {
      _logger.warning(
          () => "handled error during "
              "doAsyncOperationWithProgressDialog",
          error,
          stackTrace);
    }
  } finally {
    progressDialog.hide(context);
  }

  AsyncDialogResult dialogResult;
  if (progressDialog.isCanceled) {
    dialogResult = AsyncDialogResult.canceled();
    _logger.fine(() => "canceled doAsyncOperationWithProgressDialog");
  } else if (error != null) {
    if (errorDialog != null) {
      await errorDialog.show(context);
    }

    if (needRethrow) {
      throw error;
    }
    dialogResult = AsyncDialogResult.withError(error);
  } else {
    _logger
        .finest(() => "success doAsyncOperationWithProgressDialog =$result}");
    dialogResult = AsyncDialogResult.success(result);
  }

  return dialogResult;
}
