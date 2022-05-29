import 'package:amst/constant.dart';
import 'package:amst/screens/homescreen.dart';
import 'package:amst/screens/singupscreen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
              return HomeScreen(
                user: snapshot.data,
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
