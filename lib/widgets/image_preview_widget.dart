import 'package:firebase_chat_app/widgets/placeholder_widgets.dart';
import 'package:flutter/material.dart';
import 'dart:io';

///displays image on media preview screen.

class ImagePreviewWidget extends StatelessWidget {
  final String imagePath;

  ImagePreviewWidget({
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Image(
      image: NetworkImage(imagePath),
      errorBuilder: (context, exception, stackTrace) =>
          BrokenImagePlaceHolderWidget(),
    ));
  }
}
