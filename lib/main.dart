import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'DarkMode/ThemeData.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login.dart';
import 'DarkMode/DarkThemeProvider.dart';
import 'package:provider/provider.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    badge: true,
  );
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
    await themeChangeProvider.darkThemePreference.getTheme();
  }
  @override
  Widget build(BuildContext context) {
    return
      ChangeNotifierProvider(
        create: (_) {
          return themeChangeProvider;
        },
    child: Consumer<DarkThemeProvider>(
      builder: (BuildContext context, value, Widget? child) {
        return MaterialApp(
        title: 'INPT Spicy Chat',
        theme: Styles.themeData(themeChangeProvider.darkTheme, context),
        home: LoginScreen(title: 'INPT Spicy Chat'),
        debugShowCheckedModeBanner: false,
      );
    },
      )
      );
  }
}
