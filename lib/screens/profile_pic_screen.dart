import 'package:firebase_chat_app/chat_provider.dart';
import 'package:firebase_chat_app/widgets/placeholder_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///screen to display user profile picture.

class ProfilePicScreen extends StatelessWidget {
  final String recipientName;

  ProfilePicScreen({
    required this.recipientName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipientName),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: PersonPlaceHolderWidget(),
      ),
    );
  }
}
