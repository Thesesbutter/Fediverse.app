import 'package:fedi/app/account/account_model.dart';
import 'package:fedi/app/conversation/conversation_bloc.dart';
import 'package:fedi/app/ui/fedi_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConversationTitleWidget extends StatelessWidget {
  final TextStyle textStyle;

  const ConversationTitleWidget(
      {this.textStyle = const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: FediColors.darkGrey)});

  @override
  Widget build(BuildContext context) {
    var conversationBloc = IConversationBloc.of(context, listen: false);

    return StreamBuilder<List<IAccount>>(
        stream: conversationBloc.accountsWithoutMeStream,
        builder: (context, snapshot) {
          var accounts = snapshot.data;

          if (accounts?.isNotEmpty != true) {
            return SizedBox.shrink();
          }
          return Row(
            children: <Widget>[
              Text(
                accounts.map((account) => account.acct).join(", "),
                style: textStyle,
              ),
            ],
          );
        });
  }
}