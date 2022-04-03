import 'package:flutter/material.dart';

///enum to depict different sizes of mobile devices

enum PhoneScreenSize {
  Large,
  Medium,
  Small,
}

///UI utilities class containing information on ui element sizes depending on the screen size available.
///larger screen sizes have bigger default sizes.

class UIUtil {
  static UIUtil? _uiUtil;
  final PhoneScreenSize _phoneScreenSize;
  double? _iconSize;
  double? _maxChatItemWidth;
  final double _maxChatItemHeight = 150;

  UIUtil._({required PhoneScreenSize phoneScreenSize})
      : _phoneScreenSize = phoneScreenSize;

  /// UI Util is a singleton class.
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
}
