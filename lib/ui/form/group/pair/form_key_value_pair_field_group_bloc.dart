import 'package:fedi/ui/form/field/value/form_value_field_bloc.dart';
import 'package:fedi/ui/form/group/form_group_bloc.dart';

abstract class IFormKeyValuePairFieldGroupBloc<K extends IFormValueFieldBloc,
    V extends IFormValueFieldBloc> extends IFormGroupBloc {
  K get keyField;

  V get valueField;
}