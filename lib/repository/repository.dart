import 'package:fedi/repository/repository_model.dart';
import 'package:moor/moor.dart';

abstract class IBaseReadRepository<DbId> {
  Future<int> countAll();

  Future<bool> isExistWithDbId(DbId dbId);
}

abstract class IDbReadRepository<DbItem extends DataClass, DbId, Filters,
        OrderingTerm extends RepositoryOrderingTerm>
    extends IBaseReadRepository<DbId> {
  Future<List<DbItem>> getAllInDbType();

  Stream<List<DbItem>> watchAllInDbType();

  Future<DbItem?> findByDbIdInDbType(DbId dbId);

  Stream<DbItem?> watchByDbIdInDbType(DbId dbId);

  Future<DbItem?> findInDbType({
    required RepositoryPagination<DbItem>? pagination,
    required Filters? filters,
    required List<OrderingTerm>? orderingTerms,
  });

  Stream<DbItem?> watchInDbType({
    required RepositoryPagination<DbItem>? pagination,
    required Filters? filters,
    required List<OrderingTerm>? orderingTerms,
  });

  Future<List<DbItem>> findAllInDbType({
    required RepositoryPagination<DbItem>? pagination,
    required Filters? filters,
    required List<OrderingTerm>? orderingTerms,
  });

  Stream<List<DbItem>> watchFindAllInDbType({
    required RepositoryPagination<DbItem>? pagination,
    required Filters? filters,
    required List<OrderingTerm>? orderingTerms,
  });
}

abstract class IAppReadRepository<DbItem extends DataClass, AppItem, DbId,
        Filters, OrderingTerm extends RepositoryOrderingTerm>
    extends IDbReadRepository<DbItem, DbId, Filters, OrderingTerm> {
  Future<List<AppItem>> getAllInAppType();

  Stream<List<AppItem>> watchAllInAppType();

  Future<AppItem?> findByDbIdInAppType(DbId dbId);

  Stream<AppItem?> watchByDbIdInAppType(DbId dbId);

  Future<AppItem?> findInAppType({
    required RepositoryPagination<AppItem>? pagination,
    required Filters? filters,
    required List<OrderingTerm>? orderingTerms,
  });

  Stream<AppItem?> watchInAppType({
    required RepositoryPagination<AppItem>? pagination,
    required Filters? filters,
    required List<OrderingTerm>? orderingTerms,
  });

  Future<List<AppItem>> findAllInAppType({
    required RepositoryPagination<AppItem>? pagination,
    required Filters? filters,
    required List<OrderingTerm>? orderingTerms,
  });

  Stream<List<AppItem>> watchFindAllInAppType({
    required RepositoryPagination<AppItem>? pagination,
    required Filters? filters,
    required List<OrderingTerm>? orderingTerms,
  });
}

abstract class IAppRemoteReadRepository<
        DbItem extends DataClass,
        AppItem,
        RemoteItem,
        DbId,
        RemoteId,
        Filters,
        OrderingTerm extends RepositoryOrderingTerm>
    extends IAppReadRepository<DbItem, AppItem, DbId, Filters, OrderingTerm> {
  Future<DbItem?> findByRemoteIdInDbType(RemoteId remoteId);

  Stream<DbItem?> watchByRemoteIdInDbType(RemoteId remoteId);

  Future<AppItem?> findByRemoteIdInAppType(RemoteId remoteId);

  Stream<AppItem?> watchByRemoteIdInAppType(RemoteId remoteId);

  Future<RemoteItem?> findByRemoteIdInRemoteType(RemoteId remoteId);

  Stream<RemoteItem?> watchByRemoteIdInRemoteType(RemoteId remoteId);

  Future<List<RemoteItem>> getAllInRemoteType();

  Stream<List<RemoteItem>> watchAllInRemoteType();

  Future<RemoteItem?> findByDbIdInRemoteType(DbId id);

  Stream<RemoteItem?> watchByDbIdInRemoteType(DbId id);

  Future<RemoteItem?> findInRemoteType({
    required RepositoryPagination<RemoteItem>? pagination,
    required Filters? filters,
    required List<OrderingTerm>? orderingTerms,
  });

  Stream<RemoteItem?> watchInRemoteType({
    required RepositoryPagination<RemoteItem>? pagination,
    required Filters? filters,
    required List<OrderingTerm>? orderingTerms,
  });

  Future<List<RemoteItem>> findAllInRemoteType({
    required RepositoryPagination<RemoteItem>? pagination,
    required Filters? filters,
    required List<OrderingTerm>? orderingTerms,
  });

  Stream<List<RemoteItem>> watchFindAllInRemoteType({
    required RepositoryPagination<RemoteItem>? pagination,
    required Filters? filters,
    required List<OrderingTerm>? orderingTerms,
  });
}

abstract class IBaseWriteRepository<DbId> {
  Future deleteById(
    DbId id, {
    required Batch? batchTransaction,
  });

  Future clear({
    required Batch? batchTransaction,
  });
}

abstract class IDbWriteRepository<DbItem extends DataClass, DbId>
    extends IBaseWriteRepository<DbId> {
  Future insertAllInDbType(
    List<Insertable<DbItem>> dbItems, {
    required InsertMode? mode,
    required Batch? batchTransaction,
  });

  Future upsertAllInDbType(
    List<Insertable<DbItem>> dbItems, {
    required Batch? batchTransaction,
  });

  Future insertInDbType(
    Insertable<DbItem> dbItem, {
    required InsertMode? mode,
    required Batch? batchTransaction,
  });

  Future upsertInDbType(
    Insertable<DbItem> dbItem, {
    required Batch? batchTransaction,
  });

  Future updateByDbIdInDbType({
    required DbId dbId,
    required Insertable<DbItem> dbItem,
    required Batch? batchTransaction,
  });
}

abstract class IAppWriteRepository<DbItem extends DataClass, AppItem, DbId>
    extends IDbWriteRepository<DbItem, DbId> {
  Future insertAllInAppType(
    List<AppItem> appItems, {
    required InsertMode? insertMode,
    required Batch? batchTransaction,
  });

  Future upsertAllInAppType(
    List<AppItem> appItems, {
    required Batch? batchTransaction,
  });

  Future insertInAppType(
    AppItem appItem, {
    required InsertMode? insertMode,
    required Batch? batchTransaction,
  });

  Future upsertInAppType(
    AppItem appItem, {
    required Batch? batchTransaction,
  });

  Future updateByDbIdInAppType({
    required DbId dbId,
    required AppItem appItem,
    required Batch? batchTransaction,
  });

  Future updateDbTypeByAppType({
    required DbItem dbItem,
    required AppItem appItem,
    required Batch? batchTransaction,
  });

  Future updateAppTypeByDbType({
    required DbItem dbItem,
    required AppItem appItem,
    required Batch? batchTransaction,
  });
}

abstract class IAppRemoteWriteRepository<
    DbItem extends DataClass,
    AppItem,
    RemoteItem,
    DbId,
    RemoteId> extends IAppWriteRepository<DbItem, AppItem, DbId> {
  Future deleteByRemoteId(
    RemoteId remoteId, {
    required Batch? batchTransaction,
  });

  Future insertAllInRemoteType(
    List<RemoteItem> remoteItems, {
    required InsertMode? insertMode,
    required Batch? batchTransaction,
  });

  Future upsertAllInRemoteType(
    List<RemoteItem> remoteItems, {
    required Batch? batchTransaction,
  });

  Future insertInRemoteType(
    RemoteItem remoteItem, {
    required InsertMode? insertMode,
    required Batch? batchTransaction,
  });

  Future upsertInRemoteType(
    RemoteItem remoteItem, {
    required Batch? batchTransaction,
  });

  Future updateByIdInRemoteType({
    required DbId dbId,
    required RemoteItem remoteItem,
    required Batch? batchTransaction,
  });

  Future updateDbTypeByRemoteType({
    required DbItem dbItem,
    required RemoteItem remoteItem,
    required Batch? batchTransaction,
  });

  Future updateRemoteTypeByDbType({
    required DbItem dbItem,
    required RemoteItem remoteItem,
    required Batch? batchTransaction,
  });

  Future updateAppTypeByRemoteType({
    required AppItem appItem,
    required RemoteItem remoteItem,
    required Batch? batchTransaction,
  });
}

abstract class IBaseReadWriteRepository<DbId>
    implements IBaseReadRepository<DbId>, IBaseWriteRepository<DbId> {}

abstract class IDbReadWriteRepository<DbItem extends DataClass, DbId, Filters,
        OrderingTerm extends RepositoryOrderingTerm>
    implements
        IDbReadRepository<DbItem, DbId, Filters, OrderingTerm>,
        IDbWriteRepository<DbItem, DbId> {}

abstract class IAppReadWriteRepository<DbItem extends DataClass, AppItem, DbId,
        Filters, OrderingTerm extends RepositoryOrderingTerm>
    implements
        IAppReadRepository<DbItem, AppItem, DbId, Filters, OrderingTerm>,
        IAppWriteRepository<DbItem, AppItem, DbId> {}

abstract class IAppRemoteReadWriteRepository<
        DbItem extends DataClass,
        AppItem,
        RemoteItem,
        DbId,
        RemoteId,
        Filters,
        OrderingTerm extends RepositoryOrderingTerm>
    implements
        IAppRemoteReadRepository<DbItem, AppItem, RemoteItem, DbId, RemoteId,
            Filters, OrderingTerm>,
        IAppRemoteWriteRepository<DbItem, AppItem, RemoteItem, DbId, RemoteId> {
}
