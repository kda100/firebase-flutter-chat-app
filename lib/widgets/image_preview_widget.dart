import 'package:firebase_chat_app/widgets/placeholder_widgets.dart';
import 'package:flutter/material.dart';
import 'dart:io';

///displays image on media preview screen.

class ImagePreviewWidget extends StatelessWidget {
  final String imagePath;
  final bool isStorage; //if image on cloud or device.

  ImagePreviewWidget({
    required this.imagePath,
    required this.isStorage,
  });

  ImageProvider createImageProvider() {
    if (isStorage)
      return NetworkImage(imagePath);
    else
      return FileImage(File(imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Image(
      image: createImageProvider(),
      errorBuilder: (context, exception, stackTrace) =>
          BrokenImagePlaceHolderWidget(),
    ));
  }
}
