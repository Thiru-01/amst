import 'package:amst/constant.dart';
import 'package:amst/service/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:get/get.dart';

class SingUpScreen extends StatelessWidget {
  SingUpScreen({super.key});
  final GoogleLogin googleLogin = Get.put(GoogleLogin());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SvgPicture.asset("assets/svg/login.svg"),
            Padding(
              padding: EdgeInsets.only(
                  top: height(context) * 0.08,
                  left: width(context) * 0.15,
                  right: width(context) * 0.15),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(),
                onPressed: () => googleLogin.googleSignUp(),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        FontAwesomeIcons.googlePlusG,
                        color: Colors.red,
                      ),
                      SizedBox(
                        width: width(context) * 0.08,
                      ),
                      const AutoSizeText(
                        "Login with Google",
                        minFontSize: 15,
                        maxFontSize: 18,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
