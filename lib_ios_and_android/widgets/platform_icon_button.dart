import 'package:firebase_chat_app/models/platform_widget_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class PlatformIconButton
    extends PlatformStatelessWidget<CupertinoButton, IconButton> {
  final Icon icon;
  final void Function() onPressed;
  final double materialSize;

  PlatformIconButton({
    required this.icon,
    required this.onPressed,
    this.materialSize = 25,
  });

  @override
  CupertinoButton buildCupertinoWidget(BuildContext context) {
    return CupertinoButton(
      child: icon,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
    );
  }

  @override
  IconButton buildMaterialWidget(BuildContext context) {
    return IconButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: onPressed,
      icon: icon,
      iconSize: materialSize,
    );
  }
}
