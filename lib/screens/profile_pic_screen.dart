import 'package:firebase_chat_app/constants/color_palette.dart';
import 'package:firebase_chat_app/models/platform_widget_models.dart';
import 'package:firebase_chat_app/screens/custom_cupertino_back_button.dart';
import 'package:firebase_chat_app/widgets/placeholder_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///screen to display user profile picture.

class ProfilePicScreen
    extends PlatformStatelessWidget<CupertinoPageScaffold, Scaffold> {
  final String recipientName;

  ProfilePicScreen({
    required this.recipientName,
  });

  final Widget _body = Center(
    child: PersonPlaceHolderWidget(),
  );

  Widget _buildTitle() {
    return Text(recipientName);
  }

  @override
  CupertinoPageScaffold buildCupertinoWidget(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.zero,
        leading: CustomCupertinoBackButton(),
        middle: _buildTitle(),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: ColorPalette.secondaryBackgroundColor,
      child: _body,
    );
  }

  @override
  Scaffold buildMaterialWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(),
      ),
      backgroundColor: ColorPalette.secondaryBackgroundColor,
      body: _body,
    );
  }
}
