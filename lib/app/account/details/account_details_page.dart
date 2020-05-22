import 'package:fedi/app/account/account_bloc.dart';
import 'package:fedi/app/account/account_bloc_impl.dart';
import 'package:fedi/app/account/account_model.dart';
import 'package:fedi/app/account/details/account_details_widget.dart';
import 'package:fedi/app/ui/page/fedi_sub_page_title_app_bar.dart';
import 'package:fedi/disposable/disposable_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var accountBloc = IAccountBloc.of(context, listen: true);

    return Scaffold(
      appBar: FediSubPageTitleAppBar(
        title: accountBloc.acct,
      ),
      body: const AccountDetailsWidget(),
    );
  }

  const AccountDetailsPage();
}

void goToAccountDetailsPage(BuildContext context, IAccount account) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => DisposableProvider<IAccountBloc>(
            create: (context) => AccountBloc.createFromContext(context,
                isNeedWatchLocalRepositoryForUpdates: true,
                account: account,
                isNeedRefreshFromNetworkOnInit: false,
                isNeedWatchWebSocketsEvents: false),
            child: const AccountDetailsPage())),
  );
}