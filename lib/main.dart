import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';

import 'constants/fonts.dart';
import 'constants/text_styles.dart';
import 'providers/chat_provider.dart';
import 'package:firebase_chat_app/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'constants/color_palette.dart';
import 'constants/strings.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    FirebaseFlutterChatApp(),
  );
}

class FirebaseFlutterChatApp extends StatelessWidget {
  MaterialApp buildMaterialApp({
    required BuildContext context,
    required Widget home,
  }) {
    return MaterialApp(
      title: Strings.appName,
      theme: ThemeData(
        fontFamily: Fonts.fontFamily,
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ColorPalette.primaryColor,
              secondary: ColorPalette.accentColor,
              background: ColorPalette.primaryBackgroundColor,
            ),
        primaryColor: ColorPalette.primaryColor,
        primaryColorDark: ColorPalette.darkPrimaryColor,
        primaryColorLight: ColorPalette.lightPrimaryColor,
        dialogTheme: DialogTheme(
          backgroundColor: ColorPalette.primaryBackgroundColor,
        ),
        backgroundColor: ColorPalette.primaryBackgroundColor,
        cardTheme: CardTheme(
          color: ColorPalette.primaryBackgroundColor,
          elevation: 10,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: ColorPalette.primaryColor,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: ColorPalette.primaryBackgroundColor,
        ),
        appBarTheme: AppBarTheme(
          color: ColorPalette.darkPrimaryColor,
          titleTextStyle: TextStyles.secondaryHeaderTextStyle,
        ),
        iconTheme: IconThemeData(
          color: ColorPalette.primaryIconColor,
        ),
        scaffoldBackgroundColor: ColorPalette.primaryBackgroundColor,
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [
        const Locale('en'),
      ],
      home: home,
    );
  }

  CupertinoApp buildCupertinoApp({
    required Widget home,
  }) {
    return CupertinoApp(
      home: home,
      theme: CupertinoThemeData(
        primaryColor: ColorPalette.primaryColor,
        barBackgroundColor: ColorPalette.darkPrimaryColor,
        scaffoldBackgroundColor: ColorPalette.primaryBackgroundColor,
        textTheme: CupertinoTextThemeData(
          primaryColor: ColorPalette.primaryTextColor,
          navActionTextStyle: TextStyles.primaryHeaderTextStyle,
          navTitleTextStyle: TextStyles.secondaryHeaderTextStyle.copyWith(
            fontWeight: FontWeight.normal,
          ),
          textStyle: TextStyles.primaryTextStyle.copyWith(fontSize: 14),
          actionTextStyle: TextStyles.secondaryTextStyle,
        ),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [
        const Locale('en'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = ChangeNotifierProvider<ChatProvider>(
      create: (context) => ChatProvider(),
      child: ChatScreen(), //displays chat screen.
    );

    return KeyboardDismissOnTap(
      //Keyboard dismisses on tap anywhere in app.
      child: Platform.isIOS
          ? buildCupertinoApp(home: home)
          : buildMaterialApp(
              home: home,
              context: context,
            ),
    );
  }
}
