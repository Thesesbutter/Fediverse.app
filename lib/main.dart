import 'package:fedi/app/account/my/my_account_bloc.dart';
import 'package:fedi/app/analytics/analytics_service.dart';
import 'package:fedi/app/auth/instance/auth_instance_model.dart';
import 'package:fedi/app/auth/instance/current/context/current_auth_instance_context_bloc_impl.dart';
import 'package:fedi/app/auth/instance/current/context/loading/current_auth_instance_context_loading_bloc.dart';
import 'package:fedi/app/auth/instance/current/context/loading/current_auth_instance_context_loading_bloc_impl.dart';
import 'package:fedi/app/auth/instance/current/context/loading/current_auth_instance_context_loading_widget.dart';
import 'package:fedi/app/auth/instance/current/current_auth_instance_bloc.dart';
import 'package:fedi/app/auth/instance/join/from_scratch/from_scratch_join_auth_instance_page.dart';
import 'package:fedi/app/auth/instance/join/join_auth_instance_bloc.dart';
import 'package:fedi/app/auth/instance/join/join_auth_instance_bloc_impl.dart';
import 'package:fedi/app/context/app_context_bloc.dart';
import 'package:fedi/app/context/app_context_bloc_impl.dart';
import 'package:fedi/app/home/home_bloc.dart';
import 'package:fedi/app/home/home_bloc_impl.dart';
import 'package:fedi/app/home/home_model.dart';
import 'package:fedi/app/home/home_page.dart';
import 'package:fedi/app/init/init_bloc.dart';
import 'package:fedi/app/init/init_bloc_impl.dart';
import 'package:fedi/app/localization/localization_loader.dart';
import 'package:fedi/app/localization/localization_provider_widget.dart';
import 'package:fedi/app/localization/localization_service.dart';
import 'package:fedi/app/splash/splash_page.dart';
import 'package:fedi/app/ui/fedi_colors.dart';
import 'package:fedi/app/ui/fedi_text_styles.dart';
import 'package:fedi/app/ui/fedi_theme.dart';
import 'package:fedi/async/loading/init/async_init_loading_model.dart';
import 'package:fedi/disposable/disposable_provider.dart';
import 'package:fedi/pleroma/instance/pleroma_instance_service.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:moor/moor.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

var _logger = Logger("main.dart");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(MaterialApp(home: SplashPage()));

  IInitBloc initBloc = InitBloc();
  unawaited(initBloc.performAsyncInit());

  initBloc.initLoadingStateStream.listen((newState) async {
    _logger.fine(() => "appContextBloc.initLoadingStateStream.newState "
        "$newState");

    if (newState == AsyncInitLoadingState.finished) {
      var currentInstanceBloc =
          initBloc.appContextBloc.get<ICurrentAuthInstanceBloc>();

      currentInstanceBloc.currentInstanceStream
          .distinct(
              (previous, next) => previous?.userAtHost == next?.userAtHost)
          .listen((currentInstance) {
        buildCurrentInstanceApp(initBloc.appContextBloc, currentInstance);
      });
    } else if (newState == AsyncInitLoadingState.failed) {
      runApp(MaterialApp(
          home: Scaffold(
        backgroundColor: FediColors.primaryColorDark,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            // todo: localization
            child: Text(
              "Failed to start app.\nTry restart or re-install app.",
              style: FediTextStyles.mediumShortBoldWhite,
            ),
          ),
        ),
      )));
      _logger.severe(() => "failed to init App");
    }
  });
}

CurrentAuthInstanceContextBloc currentInstanceContextBloc;

void showSplashPage(AppContextBloc appContextBloc) {
  var easyLocalization = appContextBloc.provideContextToChild(
    child: _buildEasyLocalization(
      child: FediApp(
        child: Provider<IAppContextBloc>.value(
          value: appContextBloc,
          child: (const SplashPage()),
        ),
      ),
    ),
  );
  runApp(easyLocalization);
}

void buildCurrentInstanceApp(
    AppContextBloc appContextBloc, AuthInstance currentInstance) async {
  _logger.finest(() => "buildCurrentInstanceApp $buildCurrentInstanceApp");
  if (currentInstance != null) {
    showSplashPage(appContextBloc);
    currentInstanceContextBloc?.dispose();

    currentInstanceContextBloc = CurrentAuthInstanceContextBloc(
        currentInstance: currentInstance,
        preferencesService: appContextBloc.get(),
        connectionService: appContextBloc.get(),
        pushRelayService: appContextBloc.get(),
        pushHandlerBloc: appContextBloc.get(),
        fcmPushService: appContextBloc.get(),
        webSocketsService: appContextBloc.get());
    await currentInstanceContextBloc.performAsyncInit();
    _logger.finest(
        () => "buildCurrentInstanceApp CurrentInstanceContextLoadingPage");
    runApp(appContextBloc.provideContextToChild(
        child: _buildEasyLocalization(
            child: currentInstanceContextBloc.provideContextToChild(
                child: DisposableProvider<
                        ICurrentAuthInstanceContextLoadingBloc>(
                    create: (context) {
                      var currentAuthInstanceContextLoadingBloc =
                          CurrentAuthInstanceContextLoadingBloc(
                        myAccountBloc:
                            IMyAccountBloc.of(context, listen: false),
                        pleromaInstanceService:
                            IPleromaInstanceService.of(context, listen: false),
                        currentAuthInstanceBloc:
                            ICurrentAuthInstanceBloc.of(context, listen: false),
                      );
                      currentAuthInstanceContextLoadingBloc.performAsyncInit();
                      return currentAuthInstanceContextLoadingBloc;
                    },
                    child: FediApp(
                        child: CurrentAuthInstanceContextLoadingWidget(
                      child: DisposableProvider<IHomeBloc>(
                          create: (context) =>
                              HomeBloc(startTab: HomeTab.timelines),
                          child: const HomePage()),
                    )))))));
  } else {
    runApp(appContextBloc.provideContextToChild(
        child: _buildEasyLocalization(
            child: DisposableProvider<IJoinAuthInstanceBloc>(
                create: (context) => JoinAuthInstanceBloc(),
                child:
                    const FediApp(child: FromScratchJoinAuthInstancePage())))));
  }
}

Widget _buildEasyLocalization({@required Widget child}) {
  return Builder(
    builder: (context) => LocalizationProvider(
      key: PageStorageKey("EasyLocalization"),
      assetLoader: CodegenLoader(),
      preloaderColor: FediColors.primaryColorDark,
      preloaderWidget: MaterialApp(home: SplashPage()),
      supportedLocales: [Locale('en', 'US')],
      path: "assets/langs",
      localizationBloc:
          ILocalizationService.of(context, listen: false).localizationBloc,
      child: child,
    ),
  );
}

class FediApp extends StatelessWidget {
  final Widget child;

  const FediApp({@required this.child});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    var localizationProvider = LocalizationProvider.of(context);
    var app = MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fedi2',
      localizationsDelegates: localizationProvider.delegates,
      supportedLocales: localizationProvider.supportedLocales,
      locale: localizationProvider.locale,
      theme: fediTheme,
      initialRoute: "/",
      home: child,
      navigatorObservers: [
        FirebaseAnalyticsObserver(
            analytics:
                IAnalyticsService.of(context, listen: false).firebaseAnalytics),
      ],
    );
    return OverlaySupport(child: app);
  }
}
