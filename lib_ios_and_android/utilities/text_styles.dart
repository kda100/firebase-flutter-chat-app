import 'dart:io';
import 'package:flutter/material.dart';

import '../constants/color_palette.dart';
import '../constants/fonts.dart';

class TextStyles {
  static final double _textSize = Platform.isIOS ? 17 : 14;

  static final TextStyle appBarTextStyle = TextStyle(
    fontWeight: Platform.isIOS ? FontWeight.bold : FontWeight.normal,
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.secondaryTextColor,
    fontSize: Platform.isIOS ? 17 : 20,
  );

  static final TextStyle textStyle1 = TextStyle(
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.primaryTextColor,
    fontSize: _textSize,
  );

  static final TextStyle textStyle2 = TextStyle(
    fontSize: _textSize - 2,
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.primaryTextColor,
  );

  static final TextStyle textStyle3 = TextStyle(
    color: ColorPalette.secondaryTextColor,
    fontFamily: Fonts.fontFamily,
    fontSize: _textSize,
  );

  static final TextStyle buttonTextStyle = TextStyle(
    fontFamily: Fonts.fontFamily,
    fontSize: _textSize,
    color: ColorPalette.primaryColor,
  );

  static final TextStyle alertDialogTextStyle = TextStyle(
    fontSize: _textSize,
    color: ColorPalette.primaryTextColor,
    fontFamily: Fonts.fontFamily,
    fontWeight: FontWeight.bold,
  );
}
