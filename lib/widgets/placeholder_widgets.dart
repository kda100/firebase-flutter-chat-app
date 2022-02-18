import 'package:flutter/material.dart';

///placeholder widgets to use when media files have not loaded successfully,
///when the file is awaiting to be loaded.
///or when there is no image to load.

class MediaPlaceholderWidget extends StatelessWidget {
  final IconData placeholder;

  MediaPlaceholderWidget({
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Icon(
          placeholder,
          size: constraint.biggest.width,
          color: Theme.of(context).primaryColorDark,
        );
      },
    );
  }
}

class BrokenImagePlaceHolderWidget extends StatelessWidget {
  //error in download
  @override
  Widget build(BuildContext context) {
    return MediaPlaceholderWidget(
      placeholder: Icons.broken_image,
    );
  }
}

class PersonPlaceHolderWidget extends StatelessWidget {
  //when no profile picture exists.
  @override
  Widget build(BuildContext context) {
    return MediaPlaceholderWidget(
      placeholder: Icons.person,
    );
  }
}
