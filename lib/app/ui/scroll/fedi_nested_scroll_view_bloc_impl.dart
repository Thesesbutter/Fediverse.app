import 'package:fedi/app/ui/scroll/fedi_nested_scroll_view_bloc.dart';
import 'package:fedi/disposable/disposable_owner.dart';
import 'package:fedi/ui/scroll/nested_scroll_controller_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:nested_scroll_controller/nested_scroll_controller.dart';
import 'package:rxdart/rxdart.dart';

var _logger = Logger("fedi_sliver_app_bar_bloc_impl.dart");

class FediNestedScrollViewBloc extends DisposableOwner
    implements IFediNestedScrollViewBloc {
  @override
  final INestedScrollControllerBloc nestedScrollControllerBloc;

  BehaviorSubject<bool> isNestedScrollViewBodyStartedScrollSubject =
      BehaviorSubject();
  BehaviorSubject<int> scrollOffsetSubject = BehaviorSubject();

  ScrollController get scrollController =>
      nestedScrollControllerBloc.nestedScrollController;

  @override
  bool get isNestedScrollViewBodyStartedScroll =>
      isNestedScrollViewBodyStartedScrollSubject.value;

  @override
  Stream<bool> get isNestedScrollViewBodyStartedScrollStream =>
      isNestedScrollViewBodyStartedScrollSubject.stream.distinct();

  @override
  bool get isNestedScrollViewBodyNotStartedScroll =>
      isNestedScrollViewBodyStartedScroll != true;

  @override
  Stream<bool> get isNestedScrollViewBodyNotStartedScrollStream =>
      isNestedScrollViewBodyStartedScrollStream.map(
          (isNestedScrollViewBodyStartedScroll) =>
              isNestedScrollViewBodyStartedScroll != true);

  @override
  int get scrollOffset => scrollOffsetSubject.value;

  @override
  Stream<int> get scrollOffsetStream => scrollOffsetSubject.stream.distinct();

  FediNestedScrollViewBloc({@required this.nestedScrollControllerBloc}) {
    addDisposable(subject: isNestedScrollViewBodyStartedScrollSubject);
    addDisposable(subject: scrollOffsetSubject);

    var listener = () {
      onScroll();
    };
    scrollController.addListener(listener);

    addDisposable(custom: () {
      try {
        scrollController.removeListener(listener);
      } catch (e, stackTrace) {
        _logger.warning(
          () => "failed to unsubscribe scrollController"
              ".removeListener(listener);",
          e,
          stackTrace,
        );
      }
    });
  }

  void onScroll() {
    var pixels = scrollController.position.pixels;
    var maxScrollExtent = scrollController.position.maxScrollExtent;

    scrollOffsetSubject.add(pixels.toInt());

    // -1 is hack, because scroll extent sometimes invalid
    // it should be equal to maxScrollExtent when nested scroll body start
    // scrolls but actually it is a little smaller (0.00001 difference)
    maxScrollExtent = maxScrollExtent - 1;
    var isAtLeastStartExpand = pixels <= maxScrollExtent;
    isNestedScrollViewBodyStartedScrollSubject.add(isAtLeastStartExpand);
//    _logger.finest(() => "offset: ${scrollController.offset} \n"
//            "\t innerOffset: ${scrollController.innerOffset} \n"
//            "\t totalOffset: ${scrollController.totalOffset} \n"
//            "\t position: ${scrollController.position} \n"
//            "\t isAtLeastStartExpand: ${isAtLeastStartExpand} \n"
//            "\t scrollController.position.pixels: ${scrollController.position.pixels} scrollController.position.maxScrollExtent ${scrollController.position.maxScrollExtent}"
//    //          "\t isScrolledAtLeastOneScreen: ${isScrolledAtLeastOneScreen} \n"
//        );
  }

  @override
  NestedScrollController get nestedScrollController =>
      nestedScrollControllerBloc.nestedScrollController;
}