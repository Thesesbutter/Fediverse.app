import 'package:fedi/app/share/share_with_message_widget.dart';
import 'package:fedi/app/status/list/status_list_item_timeline_widget.dart';
import 'package:fedi/app/status/status_model.dart';
import 'package:flutter/cupertino.dart';

class ShareStatusWithMessageWidget extends StatelessWidget {
  final IStatus status;
  final Widget header;

  ShareStatusWithMessageWidget({
    @required this.status,
    @required this.header,
  });

  @override
  Widget build(BuildContext context) => ShareWithMessageWidget(
        child: StatusListItemTimelineWidget.list(
          collapsible: false,
          displayActions: false,
        ),
        header: header,
      );
}