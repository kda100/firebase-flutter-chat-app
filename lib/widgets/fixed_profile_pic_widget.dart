import 'package:firebase_chat_app/widgets/placeholder_widgets.dart';
import 'package:firebase_chat_app/screens/profile_pic_screen.dart';
import 'package:flutter/material.dart';

class FixedProfilePicWidget extends StatelessWidget {
  FixedProfilePicWidget();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfilePicScreen(),
          ),
        );
      },
      child: CircleAvatar(
        radius: double.infinity,
        backgroundColor: Theme.of(context).backgroundColor,
        child: ClipOval(
          child: PersonPlaceHolderWidget(),
        ),
      ),
    );
  }
}
