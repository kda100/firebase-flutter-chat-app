import 'package:flutter/material.dart';

import '../constants/color_palette.dart';
import '../constants/fonts.dart';

enum PhoneScreenSize {
  Large,
  Medium,
  Small,
}

class UIUtil {
  static UIUtil? _uiUtil;
  final PhoneScreenSize _phoneScreenSize;
  double? _textSize;
  double? _iconSize;
  double? _maxChatItemWidth;
  final double _maxChatItemHeight = 150;

  UIUtil._({required PhoneScreenSize phoneScreenSize})
      : _phoneScreenSize = phoneScreenSize;

  factory UIUtil(BuildContext context) {
    if (_uiUtil == null) {
      final double height = MediaQuery.of(context).size.height;
      final double width = MediaQuery.of(context).size.width;
      if (height < 667 && width < 320) {
        _uiUtil = UIUtil._(phoneScreenSize: PhoneScreenSize.Small);
      } else if (height < 812 && width < 375) {
        _uiUtil = UIUtil._(phoneScreenSize: PhoneScreenSize.Medium);
      } else {
        _uiUtil = UIUtil._(phoneScreenSize: PhoneScreenSize.Large);
      }
    }
    return _uiUtil!;
  }

  double get textSize {
    if (_textSize == null) {
      if (_phoneScreenSize == PhoneScreenSize.Small) {
        _textSize = 12;
      } else if (_phoneScreenSize == PhoneScreenSize.Medium) {
        _textSize = 14;
      } else {
        _textSize = 16;
      }
    }
    return _textSize!;
  }

  double get iconSize {
    if (_iconSize == null) {
      if (_phoneScreenSize == PhoneScreenSize.Small) {
        _iconSize = 25;
      } else if (_phoneScreenSize == PhoneScreenSize.Medium) {
        _iconSize = 28;
      } else {
        _iconSize = 32;
      }
    }
    return _iconSize!;
  }

  double get maxChatItemWidth {
    if (_maxChatItemWidth == null) {
      if (_phoneScreenSize == PhoneScreenSize.Small) {
        _maxChatItemWidth = 170;
      } else if (_phoneScreenSize == PhoneScreenSize.Medium) {
        _maxChatItemWidth = 200;
      } else {
        _maxChatItemWidth = 230;
      }
    }
    return _maxChatItemWidth!;
  }

  double get maxChatItemHeight => _maxChatItemHeight;

  TextStyle get textStyle1 => TextStyle(
        fontFamily: Fonts.fontFamily,
        color: ColorPalette.primaryTextColor,
        fontSize: textSize,
      );

  TextStyle get textStyle2 => TextStyle(
        fontSize: textSize - 2,
        fontFamily: Fonts.fontFamily,
        color: ColorPalette.primaryTextColor,
      );

  TextStyle get textStyle3 => TextStyle(
        color: ColorPalette.secondaryTextColor,
        fontFamily: Fonts.fontFamily,
        fontSize: textSize,
      );

  TextStyle get buttonTextStyle => TextStyle(
        fontFamily: Fonts.fontFamily,
        fontSize: textSize,
        color: ColorPalette.primaryColor,
      );

  TextStyle get actionLabelTextStyle => TextStyle(
        fontFamily: Fonts.fontFamily,
        fontSize: textSize + 2,
        color: ColorPalette.primaryColor,
      );

  TextStyle get alertDialogTextStyle => TextStyle(
        fontSize: textSize,
        color: ColorPalette.primaryTextColor,
        fontFamily: Fonts.fontFamily,
        fontWeight: FontWeight.bold,
      );
}
