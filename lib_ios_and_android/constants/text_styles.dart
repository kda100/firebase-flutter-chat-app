import 'dart:io';
import 'package:flutter/material.dart';

import 'color_palette.dart';
import 'fonts.dart';

class TextStyles {
  static const TextStyle textStyle1 = TextStyle(
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.primaryTextColor,
    fontSize: 14,
  );

  static const TextStyle textStyle2 = TextStyle(
    fontSize: 12,
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.primaryTextColor,
  );

  static const TextStyle textStyle3 = TextStyle(
    color: ColorPalette.secondaryTextColor,
    fontFamily: Fonts.fontFamily,
    fontSize: 14,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: Fonts.fontFamily,
    fontSize: 14,
    color: ColorPalette.primaryColor,
  );

  static const TextStyle alertDialogTextStyle = TextStyle(
    fontSize: 14,
    color: ColorPalette.primaryTextColor,
    fontFamily: Fonts.fontFamily,
    fontWeight: FontWeight.bold,
  );
}
