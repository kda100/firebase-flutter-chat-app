import 'dart:async';
import 'dart:io';
import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:firebase_chat_app/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';

import 'constants/color_palette.dart';
import 'constants/fonts.dart';

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
    final home = ChangeNotifierProvider<ChatProvider>(
      create: (_) => ChatProvider(),
      child: ChatScreen(),
    );
    return KeyboardDismissOnTap(
      //Keyboard dismisses on tap anywhere in app.
      child: Platform.isIOS
          ? CupertinoApp(
              home: home,
              theme: CupertinoThemeData(
                primaryColor: ColorPalette.primaryColor,
                barBackgroundColor: ColorPalette.darkPrimaryColor,
                scaffoldBackgroundColor: ColorPalette.primaryBackgroundColor,
                textTheme: CupertinoTextThemeData(
                  primaryColor: ColorPalette.primaryTextColor,
                  navTitleTextStyle: TextStyle(
                    fontFamily: Fonts.fontFamily,
                    color: ColorPalette.secondaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textStyle: TextStyle(
                    fontFamily: Fonts.fontFamily,
                    color: ColorPalette.primaryTextColor,
                    fontSize: 14,
                  ),
                  actionTextStyle: TextStyle(
                    fontFamily: Fonts.fontFamily,
                    fontSize: 16,
                    color: ColorPalette.primaryColor,
                  ),
                ),
              ),
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              supportedLocales: [
                const Locale('en'),
              ],
            )
          : MaterialApp(
              home: home,
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
                  titleTextStyle: TextStyle(
                    fontFamily: Fonts.fontFamily,
                    color: ColorPalette.secondaryTextColor,
                    fontSize: 18,
                  ),
                ),
                iconTheme: IconThemeData(
                  color: ColorPalette.primaryIconColor,
                ),
                textTheme: TextTheme(
                  bodyText2: TextStyle(
                    fontFamily: Fonts.fontFamily,
                    color: ColorPalette.primaryTextColor,
                    fontSize: 14,
                  ),
                ),
                scaffoldBackgroundColor: ColorPalette.primaryBackgroundColor,
              ),
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              supportedLocales: [
                const Locale('en'),
              ],
            ),
    );
  }
}
