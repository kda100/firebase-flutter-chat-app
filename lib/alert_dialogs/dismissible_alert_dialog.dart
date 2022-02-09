import 'package:flutter/material.dart';

class DismissibleAlertDialog extends StatelessWidget {
  final String title;

  DismissibleAlertDialog({required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Dismiss"),
        ),
      ],
    );
  }
}
