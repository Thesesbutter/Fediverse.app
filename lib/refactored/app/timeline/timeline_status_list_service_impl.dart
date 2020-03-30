import 'package:fedi/refactored/pleroma/api/pleroma_api_service.dart';
import 'package:fedi/refactored/pleroma/status/pleroma_status_model.dart';
import 'package:fedi/refactored/pleroma/timeline/pleroma_timeline_service.dart';
import 'package:fedi/refactored/app/auth/instance/current/current_instance_bloc.dart';
import 'package:fedi/refactored/app/status/list/status_list_service.dart';
import 'package:fedi/refactored/app/status/repository/status_repository.dart';
import 'package:fedi/refactored/app/status/repository/status_repository_model.dart';
import 'package:fedi/refactored/app/status/status_model.dart';
import 'package:fedi/refactored/app/timeline/local_preferences/timeline_local_preferences_bloc_impl.dart';
import 'package:fedi/refactored/app/timeline/timeline_model.dart';
import 'package:fedi/refactored/disposable/disposable_owner.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:moor/moor.dart';

var _logger = Logger("timeline_status_list_service_impl.dart");

abstract class TimelineStatusListService extends DisposableOwner
    implements IStatusListService {
  final IPleromaTimelineService pleromaTimelineService;
  final IStatusRepository statusRepository;
  final ICurrentInstanceBloc currentInstanceBloc;
  final TimelineLocalPreferencesBloc timelineLocalPreferencesBloc;

  TimelineStatusListService(
      {@required this.pleromaTimelineService,
      @required this.statusRepository,
      @required this.currentInstanceBloc,
      @required this.timelineLocalPreferencesBloc});

  @override
  IPleromaApi get pleromaApi => pleromaTimelineService;

  ITimelineSettings retrieveTimelineSettings();

  @override
  Future<bool> refreshItemsFromRemoteForPage(
      {@required int limit,
      @required IStatus newerThanStatus,
      @required IStatus olderThanStatus}) async {
    var timelineSettings = retrieveTimelineSettings();
    _logger.fine(() => "start refreshItemsFromRemoteForPage \n"
        "\t timelineSettings = $timelineSettings"
        "\t newerThanStatus = $newerThanStatus"
        "\t olderThanStatus = $olderThanStatus");
    try {
      List<IPleromaStatus> remoteStatuses;
      switch (timelineSettings.remoteType) {
        case TimelineRemoteType.public:
          remoteStatuses = await pleromaTimelineService.getPublicTimeline(
            maxId: olderThanStatus?.remoteId,
            sinceId: newerThanStatus?.remoteId,
            limit: limit,
            onlyLocal: timelineSettings.onlyLocal != null,
            onlyWithMedia: timelineLocalPreferencesBloc.value.onlyWithMedia,
            withMuted: !timelineSettings.onlyNotMuted,
            excludeVisibilities: timelineSettings.excludeVisibilities,
          );
          break;
        case TimelineRemoteType.list:
          remoteStatuses = await pleromaTimelineService.getListTimeline(
            listId: timelineSettings.onlyInListWithRemoteId,
            maxId: olderThanStatus?.remoteId,
            sinceId: newerThanStatus?.remoteId,
            limit: limit,
            onlyLocal: timelineSettings.onlyLocal != null,
            onlyWithMedia: timelineLocalPreferencesBloc.value.onlyWithMedia,
            withMuted: !timelineSettings.onlyNotMuted,
            excludeVisibilities: timelineSettings.excludeVisibilities,
          );
          break;
        case TimelineRemoteType.home:
          remoteStatuses = await pleromaTimelineService.getHomeTimeline(
            maxId: olderThanStatus?.remoteId,
            sinceId: newerThanStatus?.remoteId,
            limit: limit,
            onlyLocal: timelineSettings.onlyLocal != null,
            onlyWithMedia: timelineLocalPreferencesBloc.value.onlyWithMedia,
            withMuted: !timelineSettings.onlyNotMuted,
            excludeVisibilities: timelineSettings.excludeVisibilities,
          );
          break;
        case TimelineRemoteType.hashtag:
          remoteStatuses = await pleromaTimelineService.getHashtagTimeline(
            hashtag: timelineSettings.withHashtag,
            maxId: olderThanStatus?.remoteId,
            sinceId: newerThanStatus?.remoteId,
            limit: limit,
            onlyLocal: timelineSettings.onlyLocal != null,
            onlyWithMedia: timelineLocalPreferencesBloc.value.onlyWithMedia,
            withMuted: !timelineSettings.onlyNotMuted,
            excludeVisibilities: timelineSettings.excludeVisibilities,
          );
          break;
      }

      if (remoteStatuses != null) {
        await statusRepository.upsertRemoteStatuses(remoteStatuses,
            listRemoteId: null, conversationRemoteId: null);

        return true;
      } else {
        _logger.severe(() => "error during refreshItemsFromRemoteForPage: "
            "statuses is null");
        return false;
      }
    } catch (e, stackTrace) {
      _logger.severe(
          () => "error during refreshItemsFromRemoteForPage", e, stackTrace);
      return false;
    }
  }

  @override
  Future<List<IStatus>> loadLocalItems(
      {@required int limit,
      @required IStatus newerThanStatus,
      @required IStatus olderThanStatus}) async {
    var timelineSettings = retrieveTimelineSettings();
    _logger.finest(() => "start loadLocalItems \n"
        "\t newerThanStatus=$newerThanStatus"
        "\t olderThanStatus=$olderThanStatus");

    var onlyLocalFilter;
    if (timelineSettings.onlyLocal == true) {
      var localUrlHost = currentInstanceBloc.currentInstance.urlHost;
      onlyLocalFilter = OnlyLocalStatusFilter(localUrlHost);
    }
    var timelineLocalPreferences = timelineLocalPreferencesBloc.value;
    var statuses = await statusRepository.getStatuses(
        onlyInConversation: null,
        onlyFromAccount: null,
        onlyInListWithRemoteId: timelineSettings.onlyInListWithRemoteId,
        onlyWithHashtag: timelineSettings.withHashtag,
        onlyFromAccountsFollowingByAccount: timelineSettings.homeAccount,
        onlyLocal: onlyLocalFilter,
        onlyWithMedia: timelineLocalPreferences.onlyWithMedia,
        onlyNotMuted: timelineSettings.onlyNotMuted,
        excludeVisibilities: timelineSettings.excludeVisibilities,
        olderThanStatus: olderThanStatus,
        newerThanStatus: newerThanStatus,
        onlyNoNsfwSensitive: timelineLocalPreferences.onlyNoNsfwSensitive,
        onlyNoReplies: timelineLocalPreferences.onlyNoReplies,
        limit: limit,
        offset: null,
        orderingTermData: StatusOrderingTermData(
            orderingMode: OrderingMode.desc,
            orderByType: StatusOrderByType.remoteId));

    _logger.finer(() =>
        "finish loadLocalItems for $timelineSettings statuses ${statuses.length}");
    return statuses;
  }

  Future preRefreshAllAction() async {}
}
