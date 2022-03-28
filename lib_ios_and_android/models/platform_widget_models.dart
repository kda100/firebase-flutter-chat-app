import 'dart:io';

import 'package:flutter/cupertino.dart';

///class extension for widget to make stateless widgets with build functions for material and cupertino widgets.
abstract class PlatformStatelessWidget<C extends Widget, M extends Widget>
    extends StatelessWidget {
  PlatformStatelessWidget({Key? key}) : super(key: key);

  C buildCupertinoWidget(BuildContext context);
  M buildMaterialWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return buildCupertinoWidget(context);
    } else {
      return buildMaterialWidget(context);
    }
  }
}

///class extension for widget to make stateful widgets 'state' class with build functions for material and cupertino widgets.
abstract class PlatformState<T extends StatefulWidget, C extends Widget,
    M extends Widget> extends State<T> {
  C buildCupertinoWidget(BuildContext context);
  M buildMaterialWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return buildCupertinoWidget(context);
    } else {
      return buildMaterialWidget(context);
    }
  }
}
