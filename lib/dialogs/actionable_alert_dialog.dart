import 'package:flutter/material.dart';

///An Alert dialog with two actions for a yes and no response.

class ActionableAlertDialog extends StatelessWidget {
  final String title;

  ActionableAlertDialog({
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
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
      ],
    );
  }
}
