import 'package:fedi/app/account/my/my_account_bloc.dart';
import 'package:fedi/app/html/html_text_widget.dart';
import 'package:fedi/app/media/attachment/media_attachments_widget.dart';
import 'package:fedi/app/status/status_bloc.dart';
import 'package:fedi/app/ui/fedi_colors.dart';
import 'package:fedi/pleroma/media/attachment/pleroma_media_attachment_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _borderRadius = Radius.circular(16.0);

class ConversationStatusListItemWidget extends StatelessWidget {
  final bool isFirstInMinuteGroup;
  final bool isLastInMinuteGroup;

  ConversationStatusListItemWidget({
    @required this.isFirstInMinuteGroup,
    @required this.isLastInMinuteGroup,
  });

  @override
  Widget build(BuildContext context) {
    IStatusBloc statusBloc = IStatusBloc.of(context, listen: true);

    var myAccountBloc = IMyAccountBloc.of(context, listen: true);

    var deviceWidth = MediaQuery.of(context).size.width;

    var isStatusFromMe = myAccountBloc.checkIsStatusFromMe(statusBloc.status);

    var alignment =
        isStatusFromMe ? Alignment.centerRight : Alignment.centerLeft;
    return Align(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isStatusFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                color: isStatusFromMe
                    ? FediColors.primaryColorDark
                    : FediColors.ultraLightGrey,
                borderRadius: isStatusFromMe
                    ? BorderRadius.only(
                        topLeft: _borderRadius,
                        topRight:
                            isLastInMinuteGroup ? _borderRadius : Radius.zero,
                        bottomLeft: _borderRadius)
                    : BorderRadius.only(
                        topLeft:
                            isLastInMinuteGroup ? _borderRadius : Radius.zero,
                        topRight: _borderRadius,
                        bottomRight: _borderRadius)),
            constraints: BoxConstraints(maxWidth: deviceWidth * 0.80),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: buildContent(context, statusBloc, isStatusFromMe),
            ),
          ),
          if (isFirstInMinuteGroup)
            Align(
                alignment: alignment,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    TimeOfDay.fromDateTime(statusBloc.createdAt)
                        .format(context),
                    style: TextStyle(
                        height: 14 / 12,
                        fontSize: 12,
                        color: FediColors.mediumGrey),
                  ),
                ))
        ],
      ),
    );
  }

  Widget buildContent(
      BuildContext context, IStatusBloc statusBloc, bool isStatusFromMe) {
    return Column(
      children: <Widget>[
        buildTextContent(statusBloc, isStatusFromMe),
        buildMediaContent(statusBloc),
      ],
    );
  }

  Widget buildMediaContent(IStatusBloc statusBloc) =>
      StreamBuilder<List<IPleromaMediaAttachment>>(
          stream: statusBloc.mediaAttachmentsStream,
          initialData: statusBloc.mediaAttachments,
          builder: (context, snapshot) {
            var mediaAttachments = snapshot.data;

            return MediaAttachmentsWidget(
              mediaAttachments: mediaAttachments,
            );
          });

  Widget buildTextContent(IStatusBloc statusBloc, bool isStatusFromMe) =>
      StreamBuilder<Object>(
          stream: statusBloc.contentWithEmojisStream,
          initialData: statusBloc.contentWithEmojis,
          builder: (context, snapshot) {
            var contentWithEmojis = snapshot.data;

            if (contentWithEmojis != null) {
              return HtmlTextWidget(
                  shrinkWrap: true,
                  color:
                      isStatusFromMe ? FediColors.white : FediColors.darkGrey,
                  fontSize: 16.0,
                  lineHeight: 1.5,
                  data: contentWithEmojis,
                  onLinkTap: (String link) async {
                    if (await canLaunch(link)) {
                      await launch(link);
                    }
                  });
            } else {
              return SizedBox.shrink();
            }
          });
}