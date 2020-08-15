import 'package:fedi/disposable/disposable.dart';
import 'package:fedi/ui/form/field/value/bool/form_bool_field_bloc.dart';
import 'package:fedi/ui/form/field/value/date_time/form_date_time_field_bloc.dart';
import 'package:fedi/ui/form/field/value/string/form_string_field_bloc.dart';
import 'package:fedi/ui/form/form_bloc.dart';
import 'package:fedi/ui/form/group/one_type/form_one_type_group_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

abstract class IPostStatusPollBloc implements IFormBloc, Disposable {
  static IPostStatusPollBloc of(BuildContext context, {bool listen = true}) =>
      Provider.of<IPostStatusPollBloc>(context, listen: listen);

  static final Duration requiredMinimumDuration = Duration(minutes: 10);


  IFormOneTypeGroupBloc<IFormStringFieldBloc> get pollOptionsGroupBloc;
  IFormBoolFieldBloc get multiplyFieldBloc;
  IFormDateTimeFieldBloc get expiresAtFieldBloc;


}