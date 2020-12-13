import 'package:fedi/app/filter/list/cached/filter_cached_list_bloc.dart';
import 'package:fedi/app/filter/filter_model.dart';
import 'package:fedi/app/filter/pagination/cached/filter_cached_pagination_bloc.dart';
import 'package:fedi/app/pagination/cached/cached_pleroma_pagination_bloc_impl.dart';
import 'package:fedi/disposable/disposable_provider.dart';
import 'package:fedi/pagination/cached/cached_pagination_bloc.dart';
import 'package:fedi/pagination/cached/cached_pagination_bloc_proxy_provider.dart';
import 'package:fedi/pagination/cached/cached_pagination_model.dart';
import 'package:fedi/pleroma/api/pleroma_api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class FilterCachedPaginationBloc
    extends CachedPleromaPaginationBloc<IFilter>
    implements IFilterCachedPaginationBloc {
  final IFilterCachedListBloc filterListService;

  FilterCachedPaginationBloc(
      {@required this.filterListService,
      @required int itemsCountPerPage,
      @required int maximumCachedPagesCount})
      : super(
            maximumCachedPagesCount: maximumCachedPagesCount,
            itemsCountPerPage: itemsCountPerPage);

  @override
  IPleromaApi get pleromaApi => filterListService.pleromaApi;

  @override
  Future<List<IFilter>> loadLocalItems(
          {@required int pageIndex,
          @required int itemsCountPerPage,
          @required CachedPaginationPage<IFilter> olderPage,
          @required CachedPaginationPage<IFilter> newerPage}) =>
      filterListService.loadLocalItems(
        limit: itemsCountPerPage,
        newerThan: olderPage?.items?.first,
        olderThan: newerPage?.items?.last,
      );

  @override
  Future<bool> refreshItemsFromRemoteForPage(
      {@required int pageIndex,
      @required int itemsCountPerPage,
      @required CachedPaginationPage<IFilter> olderPage,
      @required CachedPaginationPage<IFilter> newerPage}) async {
    // can't refresh not first page without actual items bounds
    assert(!(pageIndex > 0 && olderPage == null && newerPage == null));

    return filterListService.refreshItemsFromRemoteForPage(
      limit: itemsCountPerPage,
      newerThan: olderPage?.items?.first,
      olderThan: newerPage?.items?.last,
    );
  }

  static FilterCachedPaginationBloc createFromContext(
          BuildContext context,
          {int itemsCountPerPage = 20,
          int maximumCachedPagesCount}) =>
      FilterCachedPaginationBloc(
          filterListService:
              Provider.of<IFilterCachedListBloc>(context, listen: false),
          itemsCountPerPage: itemsCountPerPage,
          maximumCachedPagesCount: maximumCachedPagesCount);

  static Widget provideToContext(BuildContext context,
      {@required Widget child,
      int itemsCountPerPage = 20,
      int maximumCachedPagesCount}) {
    return DisposableProvider<
        ICachedPaginationBloc<CachedPaginationPage<IFilter>,
            IFilter>>(
      create: (context) => FilterCachedPaginationBloc.createFromContext(
        context,
        itemsCountPerPage: itemsCountPerPage,
        maximumCachedPagesCount: maximumCachedPagesCount,
      ),
      child: CachedPaginationBlocProxyProvider<
          CachedPaginationPage<IFilter>, IFilter>(child: child),
    );
  }
}
