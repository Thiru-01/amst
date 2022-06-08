import 'package:amst/constant.dart';
import 'package:amst/model/usermodel.dart';
import 'package:amst/screens/aboutandprofile.dart';
import 'package:amst/screens/homescreen.dart';
import 'package:amst/screens/singupscreen.dart';
import 'package:amst/service/chat.dart';
import 'package:amst/service/notification.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificatinDefiner notifi = NotificatinDefiner();
FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

void makeConfig() async {
  firebaseMessaging.onTokenRefresh.listen((event) {});
  firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  FirebaseMessaging.onMessage.listen((event) {
    notifi.showNotification(event);
  });
}

Future<void> _registerBackgroundNotification(RemoteMessage message) async {
  await Firebase.initializeApp();
  notifi.showNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_registerBackgroundNotification);
  makeConfig();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AmSt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: primarySwatch,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white, width: 0)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white, width: 0)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white, width: 0)),
            fillColor: Colors.white,
            filled: true,
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primarySwatch, width: 1))),
          scaffoldBackgroundColor: primarySwatch.shade50,
          fontFamily: GoogleFonts.inconsolata().fontFamily),
      home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SingUpScreen();
            }
            if (snapshot.hasData) {
              ChatController controller = Get.put(ChatController());
              return StreamBuilder<DocumentSnapshot>(
                stream: controller.getUser(snapshot.data!.uid),
                builder: (context, snapshot2) {
                  if (snapshot2.hasData && snapshot2.data!.data() != null) {
                    UserModel userModel = userModelFromJson(
                        snapshot2.data!.data() as Map<String, dynamic>);
                    if (userModel.about.isEmpty) {
                      return InfoPage(user: snapshot.data);
                    }
                    return HomeScreen(
                      user: snapshot.data,
                    );
                  }
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              );
            }
            return Scaffold(
                body: Center(
                    child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                SizedBox(
                  height: height(context) * 0.02,
                ),
                const AutoSizeText(
                  "Loading...",
                  minFontSize: 20,
                  maxFontSize: 22,
                )
              ],
            )));
          }),
    );
  }
}
