import 'dart:async';
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
  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      //Keyboard dismisses on tap anywhere in app.
      child: MaterialApp(
        title: Strings.appName,
        theme: ThemeData(
            fontFamily: "Arvo",
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: ColorPalette.primaryColor,
                  secondary: ColorPalette.accentColor,
                  background: ColorPalette.primaryBackgroundColor,
                ),
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
            appBarTheme: AppBarTheme(color: ColorPalette.darkPrimaryColor),
            iconTheme: IconThemeData(color: ColorPalette.primaryIconColor),
            scaffoldBackgroundColor: ColorPalette.primaryBackgroundColor),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: [
          const Locale('en'),
        ],
        home: ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(),
          child: ChatScreen(), //displays chat screen.
        ),
      ),
    );
  }
}
