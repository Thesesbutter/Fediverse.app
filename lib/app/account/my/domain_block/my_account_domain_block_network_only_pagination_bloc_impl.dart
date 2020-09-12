import 'package:fedi/app/account/my/domain_block/my_account_domain_block_model.dart';
import 'package:fedi/app/account/my/domain_block/my_account_domain_block_network_only_pagination_bloc.dart';
import 'package:fedi/app/list/network_only/network_only_list_bloc.dart';
import 'package:fedi/app/pagination/network_only/network_only_pleroma_pagination_bloc_impl.dart';
import 'package:fedi/pagination/pagination_model.dart';
import 'package:fedi/pleroma/api/pleroma_api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class MyAccountDomainBlockNetworkOnlyPaginationBloc
    extends NetworkOnlyPleromaPaginationBloc<DomainBlock>
    implements IMyAccountDomainBlockNetworkOnlyPaginationBloc {
  final INetworkOnlyListBloc<DomainBlock> listBloc;

  MyAccountDomainBlockNetworkOnlyPaginationBloc(
      {@required this.listBloc,
      @required int itemsCountPerPage,
      @required int maximumCachedPagesCount})
      : super(
            maximumCachedPagesCount: maximumCachedPagesCount,
            itemsCountPerPage: itemsCountPerPage);

  @override
  IPleromaApi get pleromaApi => listBloc.pleromaApi;

  static MyAccountDomainBlockNetworkOnlyPaginationBloc createFromContext(BuildContext context,
          {int itemsCountPerPage = 20, int maximumCachedPagesCount}) =>
      MyAccountDomainBlockNetworkOnlyPaginationBloc(
          maximumCachedPagesCount: maximumCachedPagesCount,
          itemsCountPerPage: itemsCountPerPage,
          listBloc: Provider.of<INetworkOnlyListBloc<DomainBlock>>(context,
              listen: false));

  @override
  Future<List<DomainBlock>> loadItemsFromRemoteForPage(
          {@required int pageIndex,
          @required int itemsCountPerPage,
          @required PaginationPage<DomainBlock> olderPage,
          @required PaginationPage<DomainBlock> newerPage}) =>
      listBloc.loadItemsFromRemoteForPage(
          itemsCountPerPage: itemsCountPerPage,
          maxId: newerPage?.items?.last?.domain,
          minId: olderPage?.items?.first?.domain,
          pageIndex: pageIndex);
}