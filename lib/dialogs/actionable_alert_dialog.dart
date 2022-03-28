import 'package:firebase_chat_app/constants/text_styles.dart';
import 'package:firebase_chat_app/models/platform_widget_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///An Alert dialog with two actions for a yes and no response.

class ActionableAlertDialog
    extends PlatformStatelessWidget<CupertinoAlertDialog, AlertDialog> {
  final String title;

  ActionableAlertDialog({
    required this.title,
  });

  Text _buildTitle() {
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
          "Yes",
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context, false);
        },
        child: Text(
          "No",
        ),
      ),
    ];
  }

  @override
  CupertinoAlertDialog buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      content: _buildTitle(),
      actions: _buildActions(context),
    );
  }

  @override
  AlertDialog buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      content: _buildTitle(),
      actions: _buildActions(context),
    );
  }
}
