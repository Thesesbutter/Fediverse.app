import 'package:fedi/pleroma/api/pleroma_api_service.dart';
import 'package:fedi/pleroma/filter/pleroma_filter_model.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

abstract class IPleromaFilterService implements IPleromaApi {
  static IPleromaFilterService of(BuildContext context, {bool listen = true}) =>
      Provider.of<IPleromaFilterService>(context, listen: listen);

  Future<List<IPleromaFilter>> getFilters({
    String sinceId,
    String maxId,
    int limit = 20,
  });

  Future<IPleromaFilter> getFilter({@required String filterRemoteId});

  Future deleteFilter({@required String filterRemoteId});

  Future<IPleromaFilter> createFilter({
    @required IPostPleromaFilter postPleromaFilter,
  });

  Future<IPleromaFilter> updateFilter({
    @required String filterRemoteId,
    @required IPostPleromaFilter postPleromaFilter,
  });
}