import 'package:fedi/app/instance/public_timeline/instance_public_timeline_page_bloc.dart';
import 'package:fedi/app/timeline/local_preferences/timeline_local_preference_bloc.dart';
import 'package:fedi/app/timeline/settings/edit/edit_timeline_settings_dialog.dart';
import 'package:fedi/app/timeline/timeline_model.dart';
import 'package:fedi/app/timeline/type/timeline_type_model.dart';
import 'package:fedi/app/ui/button/icon/fedi_icon_button.dart';
import 'package:fedi/app/ui/fedi_icons.dart';
import 'package:fedi/app/ui/page/app_bar/fedi_page_title_app_bar.dart';
import 'package:fedi/app/ui/theme/fedi_ui_theme_model.dart';
import 'package:fedi/pleroma/api/instance/pleroma_api_instance_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InstancePublicTimelinePageAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const InstancePublicTimelinePageAppBarWidget();

  @override
  Widget build(BuildContext context) {
    return FediPageTitleAppBar(
      centerTitle: false,
      title: "title",
      actions: <Widget>[
        const _InstancePublicTimelinePageAppBarSettingsActionWidget(),
        const _InstancePublicTimelinePageAppBarOpenInBrowserAction(),
      ],
    );
  }

  @override
  Size get preferredSize => FediPageTitleAppBar.calculatePreferredSize();
}

class _InstancePublicTimelinePageAppBarOpenInBrowserAction
    extends StatelessWidget {
  const _InstancePublicTimelinePageAppBarOpenInBrowserAction({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
    // var instancePublicTimeline = Provider.of<IInstancePublicTimeline>(context);
    //
    // return FediIconButton(
    //   color: IFediUiColorTheme.of(context).darkGrey,
    //   icon: Icon(FediIcons.external_icon),
    //   onPressed: () {
    //     UrlHelper.handleUrlClickOnLocalInstanceLocation(
    //       context: context,
    //       url: instancePublicTimeline.url,
    //     );
    //   },
    // );
  }
}

class _InstancePublicTimelinePageAppBarSettingsActionWidget
    extends StatelessWidget {
  const _InstancePublicTimelinePageAppBarSettingsActionWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var instancePublicTimelinePageBloc =
        IInstancePublicTimelinePageBloc.of(context);
    var instanceLocation = instancePublicTimelinePageBloc.instanceLocation;

    return FediIconButton(
      icon: Icon(
        FediIcons.settings,
        color: IFediUiColorTheme.of(context).darkGrey,
      ),
      onPressed: () {
        var timelineLocalPreferenceBloc = ITimelineLocalPreferenceBloc.of(
          context,
          listen: false,
        );
        var timeline = timelineLocalPreferenceBloc.value!;

        showEditTimelineLocalPreferenceBlocSettingsDialog(
          context: context,
          instanceLocation: instanceLocation,
          timelineLocalPreferenceBloc: timelineLocalPreferenceBloc,
          timeline: Timeline.byType(
            id: timeline.id,
            isPossibleToDelete: false,
            label: "instancePublicTimeline.name",
            type: TimelineType.public,
            settings: timeline.settings,
          ),
          lockedSource: true,
          pleromaApiInstance:
              Provider.of<IPleromaApiInstance>(context, listen: false),
        );
      },
    );
  }
}