import 'package:firebase_chat_app/constants/color_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///placeholder widgets to use when media files have not loaded successfully,
///when the file is awaiting to be loaded.
///or when there is no image to load.

class placeHolderWidget extends StatelessWidget {
  final IconData placeholder;

  placeHolderWidget({
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return FittedBox(
          child: Icon(
            placeholder,
            size: constraint.maxWidth,
            color: ColorPalette.darkPrimaryColor,
          ),
        );
      },
    );
  }
}

class BrokenImagePlaceHolderWidget extends StatelessWidget {
  final Color? backgroundColor;

  BrokenImagePlaceHolderWidget({this.backgroundColor});
  //error in download
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor),
      child: placeHolderWidget(
        placeholder: Icons.broken_image,
      ),
    );
  }
}

class PersonPlaceHolderWidget extends StatelessWidget {
  //when no profile picture exists.
  @override
  Widget build(BuildContext context) {
    return placeHolderWidget(
      placeholder: Icons.person,
    );
  }
}
