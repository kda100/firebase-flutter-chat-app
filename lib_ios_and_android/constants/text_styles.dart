import 'dart:io';
import 'package:flutter/material.dart';

import 'color_palette.dart';
import 'fonts.dart';

class TextStyles {
  static const TextStyle textStyle1 = TextStyle(
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.primaryTextColor,
    fontSize: 15,
  );

  static const TextStyle textStyle2 = TextStyle(
    fontSize: 13,
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.primaryTextColor,
  );

  static const TextStyle textStyle3 = TextStyle(
    color: ColorPalette.secondaryTextColor,
    fontFamily: Fonts.fontFamily,
    fontSize: 15,
  );

  static const TextStyle cupertinoSheetTextStyle = TextStyle(
    fontFamily: Fonts.fontFamily,
    fontSize: 17,
    color: ColorPalette.primaryColor,
  );

  static const TextStyle alertDialogTextStyle = TextStyle(
    fontSize: 15,
    color: ColorPalette.primaryTextColor,
    fontFamily: Fonts.fontFamily,
    fontWeight: FontWeight.bold,
  );
}
