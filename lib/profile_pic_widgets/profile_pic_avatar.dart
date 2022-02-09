import 'package:firebase_chat_app/app_wide/placeholder_widgets.dart';
import 'package:flutter/material.dart';

class ProfilePicAvatar extends StatelessWidget {
  final ImageProvider? profilePicProvider;

  ProfilePicAvatar({
    required this.profilePicProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: profilePicProvider != null
          ? Image(
              image: profilePicProvider!,
              errorBuilder: (context, exception, stackTrace) =>
                  BrokenImagePlaceHolderWidget(),
              fit: BoxFit.fill,
            )
          : PersonPlaceHolderWidget(),
    );
  }
}
