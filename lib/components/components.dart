import 'package:amst/constant.dart';
import 'package:amst/model/messagemodel.dart';
import 'package:amst/model/usermodel.dart';
import 'package:amst/service/login.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

Drawer homeDrawer(GoogleLogin googleLogin, User? user) {
  return Drawer(
      backgroundColor: primarySwatch.shade100,
      child: Column(
        children: [
          DrawerHeader(
              child: Center(
            child: ClipOval(
              child: SizedBox(
                child: Image(
                  image: CachedNetworkImageProvider(
                    user!.photoURL!,
                    cacheKey: "avatar",
                  ),
                ),
              ),
            ),
          )),
          ListTile(
            title: const AutoSizeText(
              "Name",
              minFontSize: 18,
              maxFontSize: 20,
              style: TextStyle(color: Colors.black),
            ),
            trailing: AutoSizeText(
              user.displayName!,
              minFontSize: 18,
              maxFontSize: 20,
              style: TextStyle(
                  color: primarySwatch.shade700,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2),
            ),
          ),
          ListTile(
            title: const AutoSizeText(
              "Email",
              minFontSize: 18,
              maxFontSize: 20,
              style: TextStyle(color: Colors.black),
            ),
            trailing: AutoSizeText(
              user.email!,
              minFontSize: 14,
              maxFontSize: 16,
              style: TextStyle(
                color: primarySwatch.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: OutlinedButton(
                child: const Text("Sing Out"),
                onPressed: () => googleLogin.googleSingOut(),
              ),
            ),
          )),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Version: 1.0",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        ],
      ));
}

AppBar homeAppBar(GlobalKey<ScaffoldState> scaKey, User? user) {
  return AppBar(
    backgroundColor: primarySwatch.shade50,
    centerTitle: true,
    elevation: 0,
    leading: GestureDetector(
        onTap: () => scaKey.currentState!.openDrawer(),
        child: CachedNetworkImage(
          cacheKey: "avatar",
          imageUrl: user!.photoURL!,
          imageBuilder: ((context, imageProvider) {
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: CircleAvatar(
                backgroundColor: primarySwatch,
                child: CircleAvatar(
                  backgroundImage: imageProvider,
                ),
              ),
            );
          }),
        )),
    title: Text(
      "Message".toUpperCase(),
      style: const TextStyle(color: primarySwatch, letterSpacing: 2),
    ),
  );
}

AppBar chatAppBar(BuildContext context, UserModel model) {
  return AppBar(
    backgroundColor: primarySwatch.shade50,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(
        FontAwesomeIcons.arrowLeft,
        color: primarySwatch,
      ),
      onPressed: () => Get.back(),
    ),
    title: Row(
      children: [
        CachedNetworkImage(
          imageUrl: model.photoUrl,
          imageBuilder: (context, imageProvider) {
            return CircleAvatar(
              radius: 20,
              backgroundColor: primarySwatch,
              child: CircleAvatar(
                backgroundImage: imageProvider,
                radius: 19,
              ),
            );
          },
        ),
        SizedBox(
          width: width(context) * 0.05,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              model.nickname,
              maxFontSize: 14,
              minFontSize: 12,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
            AutoSizeText(
              "Online",
              maxFontSize: 12,
              minFontSize: 10,
              style: TextStyle(color: primarySwatch.shade400),
            )
          ],
        )
      ],
    ),
  );
}

bool isLastMessageRight(
    int index, List<QueryDocumentSnapshot> messageList, String currentId) {
  if ((index > 0 && messageList[index - 1].get("idFrom") != currentId) ||
      index == 0) {
    return true;
  } else {
    return false;
  }
}

Widget buildItem(int index, DocumentSnapshot snapshot, String currentId,
    List<QueryDocumentSnapshot> messageList) {
  if (!snapshot.isBlank!) {
    MessageModel messageModel =
        messageModelFromJson(snapshot.data() as Map<String, dynamic>);
    if (messageModel.idFrom == currentId) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
            width: 200,
            decoration: BoxDecoration(
                color: primarySwatch.shade200,
                borderRadius: BorderRadius.circular(8)),
            margin: EdgeInsets.only(
                bottom:
                    isLastMessageRight(index, messageList, currentId) ? 20 : 10,
                right: 10),
            child: Column(
              children: [
                AutoSizeText(
                  messageModel.content,
                  style: const TextStyle(color: primarySwatch),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(messageModel.timestamp))
                                  .day ==
                              DateTime.now().day
                          ? DateFormat('hh:mm aa').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(messageModel.timestamp)))
                          : DateFormat('dd MMM kk:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(messageModel.timestamp))),
                      style: const TextStyle(fontSize: 6, color: primarySwatch),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      );
    } else {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
            width: 200,
            decoration: BoxDecoration(
                color: primarySwatch.shade700,
                borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.only(left: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  messageModel.content,
                  style: TextStyle(color: primarySwatch.shade50),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(messageModel.timestamp))
                                  .day ==
                              DateTime.now().day
                          ? DateFormat('hh:mm aa').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(messageModel.timestamp)))
                          : DateFormat('dd MMM kk:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(messageModel.timestamp))),
                      style:
                          TextStyle(fontSize: 6, color: primarySwatch.shade50),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      );
    }
  }
  return const SizedBox.shrink();
}
