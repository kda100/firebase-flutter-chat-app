import 'package:firebase_chat_app/widgets/placeholder_widgets.dart';
import 'package:flutter/material.dart';

///screen to display user profile picture.

class ProfilePicScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Name?"),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: PersonPlaceHolderWidget(),
      ),
    );
  }
}