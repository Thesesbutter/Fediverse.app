import 'package:fedi/app/status/visibility/form/status_visibility_single_from_list_value_form_field_bloc.dart';
import 'package:fedi/form/field/value/select_from_list/single/single_select_from_list_value_form_field_bloc.dart';
import 'package:fedi/form/field/value/select_from_list/single/single_select_from_list_value_form_field_bloc_proxy_provider.dart';
import 'package:fedi/pleroma/visibility/pleroma_visibility_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class StatusVisibilitySingleFromListValueFormFieldBlocProxyProvider
    extends StatelessWidget {
  final Widget child;

  StatusVisibilitySingleFromListValueFormFieldBlocProxyProvider({
    @required this.child,
  });

  @override
  Widget build(BuildContext context) => ProxyProvider<
          IStatusVisibilitySingleFromListValueFormFieldBloc,
          ISingleSelectFromListValueFormFieldBloc<PleromaVisibility>>(
        update: (context, value, previous) => value,
        child: SingleSelectFromListValueFormFieldBlocProxyProvider<PleromaVisibility>(
          child: child,
        ),
      );
}
