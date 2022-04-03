import 'package:firebase_chat_app/constants/color_palette.dart';
import 'package:flutter/cupertino.dart';

///custom back button for Cupertino Navigation Bar for IOS devices.

class CustomCupertinoBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        child: Icon(
          CupertinoIcons.back,
          color: CupertinoColors.white,
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
