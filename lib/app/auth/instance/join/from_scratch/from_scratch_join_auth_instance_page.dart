import 'package:fedi/app/auth/instance/join/join_auth_instance_bloc.dart';
import 'package:fedi/app/auth/instance/join/join_auth_instance_bloc_impl.dart';
import 'package:fedi/app/auth/instance/join/join_auth_instance_widget.dart';
import 'package:fedi/app/theme/theme.dart';
import 'package:fedi/disposable/disposable_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FromScratchJoinAuthInstancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: romaBlueColor,
      body: SafeArea(
        child: JoinAuthInstanceWidget(),
      ),
    );
  }

  const FromScratchJoinAuthInstancePage();
}

void goToJoinNewInstancePage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => DisposableProvider<IJoinAuthInstanceBloc>(
            create: (context) => JoinAuthInstanceBloc(),
            child: FromScratchJoinAuthInstancePage())),
  );
}