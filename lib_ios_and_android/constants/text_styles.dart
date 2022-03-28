import 'package:flutter/material.dart';

import 'color_palette.dart';
import 'fonts.dart';

class TextStyles {
  static const recipientTextStyle = TextStyle(
    color: ColorPalette.primaryTextColor,
    fontFamily: Fonts.fontFamily,
    fontSize: 14,
  );

  static const senderTextStyle = TextStyle(
    color: ColorPalette.secondaryTextColor,
    fontFamily: Fonts.fontFamily,
    fontSize: 14,
  );

  static const primaryTextStyle = TextStyle(
    color: ColorPalette.primaryTextColor,
    fontSize: 12,
    fontFamily: Fonts.fontFamily,
  );
}
