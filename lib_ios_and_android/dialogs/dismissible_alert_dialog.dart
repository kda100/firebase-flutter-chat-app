import 'package:firebase_chat_app/models/platform_widget_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///An alert dialog to display important information to user that can be dismissed straight after.

class DismissibleAlertDialog
    extends PlatformStatelessWidget<CupertinoAlertDialog, AlertDialog> {
  final String title;

  DismissibleAlertDialog({required this.title});

  List<Widget> _buildActions(BuildContext context) {
    //actions for alert dialog.
    return [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text("Dismiss"),
      ),
    ];
  }

  _buildTitle() {
    return Text(title);
  }

  @override
  CupertinoAlertDialog buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: _buildTitle(),
      actions: _buildActions(context),
    );
  }

  @override
  AlertDialog buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(),
      actions: _buildActions(context),
    );
  }
}
