import 'package:flutter/material.dart';

const pushMessageKey =
    "AAAAfzMXAko:APA91bEzMafSh-vzh1zRO5x0owcH1l4OKJQvX5xgbe-4lMacBk_gxO-QMSWcIZuIXrVYIQvi50_jBZYpYzsdtutlSUx1jKMap9KiiwWmfFGyppvavjIb3ICeZUpKcrNlMrkSlT5en_s0";
final RegExp regexEmoji = RegExp(
    r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
const MaterialColor primarySwatch = MaterialColor(
  _bluePrimaryValue,
  <int, Color>{
    50: Color(0xFFfff0e6),
    100: Color(0xFFffe2cc),
    200: Color(0xFFffd3b3),
    300: Color(0xFFffc599),
    400: Color(0xFFffb680),
    500: Color(0xFFffa766),
    600: Color(0xFFff994d),
    700: Color(0xFFff8a33),
    800: Color(0xFFff7c1a),
    900: Color(_bluePrimaryValue),
  },
);
const int _bluePrimaryValue = 0xFFFF6D00;

double height(context) {
  return MediaQuery.of(context).size.height;
}

double width(context) {
  return MediaQuery.of(context).size.width;
}

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    backgroundColor: primarySwatch.shade100,
    content: Row(
      children: [
        const CircularProgressIndicator(),
        Container(
            margin: const EdgeInsets.only(left: 7),
            child: const Text(
              "Creating user !!!",
              style: TextStyle(color: primarySwatch),
            )),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showLoaderSender(BuildContext context) {
  AlertDialog alert = AlertDialog(
    backgroundColor: primarySwatch.shade100,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        Container(
            margin: const EdgeInsets.only(left: 7, top: 7),
            child: const Text(
              "Sending...",
              style: TextStyle(color: primarySwatch),
            )),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
