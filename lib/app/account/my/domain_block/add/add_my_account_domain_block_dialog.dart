import 'package:easy_localization/easy_localization.dart';
import 'package:fedi/app/account/my/domain_block/add/add_my_account_domain_block_bloc.dart';
import 'package:fedi/app/account/my/domain_block/add/add_my_account_domain_block_bloc_impl.dart';
import 'package:fedi/app/async/pleroma_async_operation_helper.dart';
import 'package:fedi/app/form/form_string_field_form_row_widget.dart';
import 'package:fedi/app/ui/dialog/fedi_dialog.dart';
import 'package:fedi/dialog/base_dialog.dart';
import 'package:fedi/pleroma/account/pleroma_account_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AddMyAccountDomainBlockDialog extends FediDialog {
  IAddMyAccountDomainBlockBloc addMyAccountDomainBlockBloc;

  AddMyAccountDomainBlockDialog.createFromContext({
    @required BuildContext context,
    @required VoidCallback successCallback,
  }) : super(
            title: "app.account.my.domain_block.add.dialog.title".tr(),
            actions: [
              BaseDialog.createDefaultOkAction(
                context: context,
                action: (context) async {
                  var addMyAccountDomainBlockBloc =
                      IAddMyAccountDomainBlockBloc.of(context, listen: false);
                  await PleromaAsyncOperationHelper
                      .performPleromaAsyncOperation(
                          context: context,
                          asyncCode: () async {
                            await addMyAccountDomainBlockBloc.submit();
                          });

                  successCallback();
                },
                isActionEnabledFetcher: (context) =>
                    IAddMyAccountDomainBlockBloc.of(context, listen: false)
                        .isReadyToSubmit,
                isActionEnabledStreamFetcher: (context) =>
                    IAddMyAccountDomainBlockBloc.of(context, listen: false)
                        .isReadyToSubmitStream,
              ),
            ],
            actionsAxis: Axis.horizontal,
            cancelable: true) {
    addMyAccountDomainBlockBloc = AddMyAccountDomainBlockBloc(
      pleromaAccountService: IPleromaAccountService.of(
        context,
        listen: false,
      ),
    );

    addDisposable(disposable: addMyAccountDomainBlockBloc);
  }

  @override
  Widget buildDialogBody(BuildContext context) => Provider.value(
        value: addMyAccountDomainBlockBloc,
        child: Builder(
          builder: (context) => super.buildDialogBody(context),
        ),
      );

  @override
  Widget buildContentWidget(BuildContext context) =>
      FormStringFieldFormRowWidget(
        label: null,
        autocorrect: false,
        hint: "app.account.my.domain_block.add.dialog.field.domain.hint".tr(),
        formStringFieldBloc: addMyAccountDomainBlockBloc.domainField,
        onSubmitted: (_) {
          // nothing
        },
        textInputAction: TextInputAction.done,
      );
}