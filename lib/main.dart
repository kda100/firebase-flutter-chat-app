import 'dart:async';
import 'package:firebase_chat_app/providers/chat_provider.dart';
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
    MyPtApp(),
  );
}

class MyPtApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: MaterialApp(
        title: Strings.appName,
        theme: ThemeData(
            fontFamily: "Arvo",
            colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: ColorPalette.primaryColor,
                secondary: ColorPalette.accentColor,
                background: ColorPalette.backGroundColor),
            primaryColor: ColorPalette.primaryColor,
            primaryColorDark: ColorPalette.darkPrimaryColor,
            primaryColorLight: ColorPalette.lightPrimaryColor,
            textTheme: TextTheme(
              headline1: TextStyle(
                  color: ColorPalette.primaryTextColor,
                  fontWeight: FontWeight.bold),
              bodyText1: TextStyle(
                color: ColorPalette.primaryTextColor,
              ),
              bodyText2: TextStyle(
                color: ColorPalette.secondaryTextColor,
              ),
            ),
            dialogTheme: DialogTheme(
              backgroundColor: ColorPalette.backGroundColor,
            ),
            backgroundColor: ColorPalette.backGroundColor,
            cardTheme: CardTheme(
              color: ColorPalette.backGroundColor,
              elevation: 10,
            ),
            progressIndicatorTheme: ProgressIndicatorThemeData(
              color: ColorPalette.primaryColor,
            ),
            bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: ColorPalette.backGroundColor,
            ),
            appBarTheme: AppBarTheme(color: ColorPalette.darkPrimaryColor),
            iconTheme: IconThemeData(color: ColorPalette.primaryIconColor),
            scaffoldBackgroundColor: ColorPalette.backGroundColor),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: [
          const Locale('en'),
        ],
        home: ChangeNotifierProvider(
            create: (context) => ChatProvider(), child: ChatScreen()),
      ),
    );
  }
}
