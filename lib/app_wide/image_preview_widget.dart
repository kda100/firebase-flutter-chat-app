import 'package:firebase_chat_app/app_wide/placeholder_widgets.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ImagePreviewWidget extends StatelessWidget {
  final String imagePath;
  final bool isStorage;

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
