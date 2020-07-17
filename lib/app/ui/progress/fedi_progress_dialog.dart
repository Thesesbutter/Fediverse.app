import 'package:async/async.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fedi/app/ui/fedi_padding.dart';
import 'package:fedi/app/ui/fedi_text_styles.dart';
import 'package:fedi/app/ui/progress/fedi_circular_progress_indicator.dart';
import 'package:fedi/dialog/base_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

var _progressDialogSize = 50.0;

abstract class ProgressDialog extends BaseDialog {
  final String contentMessage;

  CancelableOperation cancelableOperation;

  // ignore: close_sinks
  final BehaviorSubject<bool> _isCanceledSubject =
      BehaviorSubject.seeded(false);

  bool get isCanceled => _isCanceledSubject.value;

  Stream<bool> get isCanceledStream => _isCanceledSubject.stream;

  ProgressDialog({
    this.contentMessage,
    @required this.cancelableOperation,
    @required bool cancelable,
  }) : super(cancelable: cancelable) {
    addDisposable(subject: _isCanceledSubject);
  }

  Widget buildDialogContent(BuildContext context);

  Widget buildDialogContentMessage(BuildContext context) {
    return Text(
      contentMessage ?? tr("dialog.progress.content"),
      textAlign: TextAlign.center,
      style: FediTextStyles.subHeaderShortDarkGrey,
    );
  }

  @override
  Widget buildDialog(BuildContext context) => Dialog(
      insetAnimationCurve: Curves.easeInOut,
      insetAnimationDuration: Duration(milliseconds: 100),
      elevation: 10.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: buildDialogContainer(context));

  Widget buildDialogContainer(BuildContext context) {
    return Padding(
      padding: FediPadding.allBigPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: FediCircularProgressIndicator(
                size: _progressDialogSize,
              ),
            ),
            Expanded(child: buildDialogContent(context))
          ]),
          if (cancelable)
            StreamBuilder<bool>(
                stream: isCanceledStream,
                initialData: isCanceled,
                builder: (context, snapshot) {
                  var canceled = snapshot.data;
                  Future<Null> Function() onPressed;

                  if (!canceled) {
                    onPressed = () async {
                      _isCanceledSubject.add(true);
                      await cancelableOperation.cancel();
                      hide(context);
                    };
                  }
                  return FlatButton(
                    child: Text(
                      tr("dialog.progress.action.cancel"),
                    ),
                    onPressed: onPressed,
                  );
                })
        ],
      ),
    );
  }
}