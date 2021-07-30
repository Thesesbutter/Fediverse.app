import 'package:fedi/app/instance/instance_bloc.dart';
import 'package:fedi/app/ui/page/app_bar/fedi_page_title_app_bar.dart';
import 'package:fedi/generated/l10n.dart';
import 'package:flutter/widgets.dart';

class InstanceHostAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const InstanceHostAppBarWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var instanceBloc = IInstanceBloc.of(context);

    var instanceUriDomain = instanceBloc.instanceUriDomain;

    // todo: apply only for mock launch type
    instanceUriDomain = instanceUriDomain.replaceAll('10.0.2.2', 'fedi.app');
    instanceUriDomain = instanceUriDomain.replaceAll('localhost', 'fedi.app');

    return FediPageTitleAppBar(
      title: S.of(context).app_instance_details_title(
            instanceUriDomain,
          ),
    );
  }

  @override
  Size get preferredSize => FediPageTitleAppBar.calculatePreferredSize();
}
