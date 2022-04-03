import 'dart:io';
import 'package:firebase_chat_app/models/platform_widget_models.dart';
import 'package:firebase_chat_app/utilities/ui_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utilities/text_styles.dart';

///An Alert dialog with two actions for a yes and no response.

class ActionableAlertDialog
    extends PlatformStatelessWidget<CupertinoAlertDialog, AlertDialog> {
  final String title;

  ActionableAlertDialog({
    required this.title,
  });

  Text _buildTitle(BuildContext context) {
    return Text(
      title,
      style: TextStyles.alertDialogTextStyle,
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    //actions of alert dialog.
    return [
      TextButton(
        onPressed: () {
          Navigator.pop(context, true);
        },
        child: Text(
          Platform.isIOS ? "Yes" : "YES",
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context, false);
        },
        child: Text(
          Platform.isIOS ? "No" : "NO",
        ),
      ),
    ];
  }

  @override
  CupertinoAlertDialog buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      content: _buildTitle(context),
      actions: _buildActions(context),
    );
  }

  @override
  AlertDialog buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      content: _buildTitle(context),
      actions: _buildActions(context),
    );
  }
}
