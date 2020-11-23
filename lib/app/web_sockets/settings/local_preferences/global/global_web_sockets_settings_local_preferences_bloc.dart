import 'package:fedi/app/web_sockets/settings/local_preferences/web_sockets_settings_local_preference_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

abstract class IGlobalWebSocketsSettingsLocalPreferencesBloc
    implements IWebSocketsSettingsLocalPreferencesBloc {
  static IGlobalWebSocketsSettingsLocalPreferencesBloc of(BuildContext context,
          {bool listen = true}) =>
      Provider.of<IGlobalWebSocketsSettingsLocalPreferencesBloc>(context,
          listen: listen);
}