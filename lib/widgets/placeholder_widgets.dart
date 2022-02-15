import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return MediaPlaceholderWidget(
      placeholder: Icons.broken_image,
    );
  }
}

class PersonPlaceHolderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaPlaceholderWidget(
      placeholder: Icons.person,
    );
  }
}

class LoadingImagePlaceHolderWidget extends StatelessWidget {
  const LoadingImagePlaceHolderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaPlaceholderWidget(
      placeholder: Icons.image,
    );
  }
}
