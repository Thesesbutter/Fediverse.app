import 'package:fedi/app/status/list/status_list_item_timeline_widget.dart';
import 'package:fedi/app/status/pagination/list/status_pagination_list_base_widget.dart';
import 'package:fedi/app/status/status_bloc.dart';
import 'package:fedi/app/status/status_bloc_impl.dart';
import 'package:fedi/app/status/status_model.dart';
import 'package:fedi/app/ui/list/fedi_list_tile.dart';
import 'package:fedi/collapsible/collapsible_bloc.dart';
import 'package:fedi/disposable/disposable.dart';
import 'package:fedi/disposable/disposable_provider.dart';
import 'package:fedi/pagination/list/pagination_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPaginationListTimelineWidget
    extends StatusPaginationListBaseWidget {
  final bool needWatchLocalRepositoryForUpdates;

  const StatusPaginationListTimelineWidget(
      {@required Key key,
      Widget header,
      Widget footer,
      bool alwaysShowHeader,
      bool alwaysShowFooter,
      @required this.needWatchLocalRepositoryForUpdates})
      : super(
            key: key,
            header: header,
            footer: footer,
            alwaysShowFooter: alwaysShowFooter,
            alwaysShowHeader: alwaysShowHeader);

  @override
  ScrollView buildItemsCollectionView(
          {@required BuildContext context,
          @required List<IStatus> items,
          @required Widget header,
          @required Widget footer}) =>
      PaginationListWidget.buildItemsListView(
          context: context,
          items: items,
          header: header,
          footer: footer,
          itemBuilder: (context, index) {
            return Provider<IStatus>.value(
              value: items[index],
              child: DisposableProxyProvider<IStatus, IStatusBloc>(
                  update: (context, status, oldValue) {
                    var collapsibleBloc =
                        ICollapsibleBloc.of(context, listen: false);

                    var statusBloc = StatusBloc.createFromContext(
                        context, status,
                        isNeedWatchLocalRepositoryForUpdates:
                            needWatchLocalRepositoryForUpdates);

                    collapsibleBloc.addVisibleItem(statusBloc);

                    statusBloc.addDisposable(disposable: CustomDisposable(() {
                      collapsibleBloc.removeVisibleItem(statusBloc);
                    }));

                    return statusBloc;
                  },
                  child: FediListTile(
                    isFirstInList: index == 0 && header == null,
                    child: const StatusListItemTimelineWidget(
                      collapsible: true,
                    ),
                  )),
            );
          });
}