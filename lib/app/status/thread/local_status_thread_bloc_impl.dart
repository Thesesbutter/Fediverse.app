import 'package:fedi/app/filter/filter_model.dart';
import 'package:fedi/app/filter/repository/filter_repository.dart';
import 'package:fedi/app/filter/repository/filter_repository_model.dart';
import 'package:fedi/app/instance/location/instance_location_model.dart';
import 'package:fedi/app/status/repository/status_repository.dart';
import 'package:fedi/app/status/status_model.dart';
import 'package:fedi/app/status/thread/status_thread_bloc.dart';
import 'package:fedi/app/status/thread/status_thread_bloc_impl.dart';
import 'package:fedi/disposable/disposable_provider.dart';
import 'package:fedi/mastodon/api/filter/mastodon_filter_model.dart';
import 'package:fedi/pleroma/api/media/attachment/pleroma_media_attachment_model.dart';
import 'package:fedi/pleroma/api/status/pleroma_status_model.dart';
import 'package:fedi/pleroma/api/status/pleroma_status_service.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';

class LocalStatusThreadBloc extends StatusThreadBloc {
  final IStatusRepository statusRepository;
  final IFilterRepository filterRepository;

  LocalStatusThreadBloc({
    required this.statusRepository,
    required this.filterRepository,
    required IStatus initialStatusToFetchThread,
    required IPleromaMediaAttachment? initialMediaAttachment,
    required IPleromaStatusService pleromaStatusService,
  }) : super(
          pleromaStatusService: pleromaStatusService,
          initialStatusToFetchThread: initialStatusToFetchThread,
          initialMediaAttachment: initialMediaAttachment,
        );

  static LocalStatusThreadBloc createFromContext(
    BuildContext context, {
    required IStatus initialStatusToFetchThread,
    required IPleromaMediaAttachment? initialMediaAttachment,
  }) =>
      LocalStatusThreadBloc(
        initialStatusToFetchThread: initialStatusToFetchThread,
        initialMediaAttachment: initialMediaAttachment,
        pleromaStatusService: IPleromaStatusService.of(
          context,
          listen: false,
        ),
        statusRepository: IStatusRepository.of(
          context,
          listen: false,
        ),
        filterRepository: IFilterRepository.of(
          context,
          listen: false,
        ),
      );

  static Widget provideToContext(
    BuildContext context, {
    required IStatus initialStatusToFetchThread,
    required IPleromaMediaAttachment initialMediaAttachment,
    required Widget child,
  }) {
    return DisposableProvider<IStatusThreadBloc>(
      create: (context) => LocalStatusThreadBloc.createFromContext(
        context,
        initialStatusToFetchThread: initialStatusToFetchThread,
        initialMediaAttachment: initialMediaAttachment,
      ),
      child: child,
    );
  }

  @override
  Future<List<IFilter>> loadFilters() async {
    var filters = await filterRepository.findAllInAppType(
      filters: FilterRepositoryFilters(
        onlyWithContextTypes: [
          MastodonFilterContextType.thread,
        ],
        notExpired: true,
      ),
      pagination: null,
      orderingTerms: null,
    );
    return filters;
  }

  @override
  void onInitialStatusUpdated(IPleromaStatus updatedStartRemoteStatus) {
    unawaited(
      statusRepository.updateAppTypeByRemoteType(
        appItem: initialStatusToFetchThread,
        remoteItem: updatedStartRemoteStatus,
        batchTransaction: null,
      ),
    );
  }

  @override
  InstanceLocation get instanceLocation => InstanceLocation.local;

  @override
  Uri? get remoteInstanceUriOrNull => null;
}
