import 'package:fedi/app/account/my/my_account_widget.dart';
import 'package:fedi/app/account/statuses/account_statuses_widget.dart';
import 'package:fedi/app/ui/list/fedi_list_tile.dart';
import 'package:fedi/collapsible/collapsible_owner_widget.dart';
import 'package:fedi/ui/scroll/scroll_controller_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAccountDetailsBodyWidget extends StatelessWidget {
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) => CollapsibleOwnerWidget(
        child: buildAccountStatusesWidget(context),
      );

  AccountStatusesWidget buildAccountStatusesWidget(BuildContext context) =>
      AccountStatusesWidget(
        scrollController: scrollController,
        header: FediListTile(
          isFirstInList: true,
          child: MyAccountWidget(
            onStatusesTapCallback: () {
              var scrollControllerBloc =
                  IScrollControllerBloc.of(context, listen: false);
              scrollControllerBloc.scrollController.animateTo(
                MediaQuery.of(context).size.height / 2,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            },
          ),
        ),
        alwaysShowHeader: true,
        key: PageStorageKey("MyAccountDetailsBodyWidget"),
      );

  const MyAccountDetailsBodyWidget({this.scrollController});
}