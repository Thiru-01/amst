import 'package:amst/constant.dart';
import 'package:amst/model/messagemodel.dart';
import 'package:amst/model/usermodel.dart';
import 'package:amst/screens/imageviewer.dart';
import 'package:amst/service/chat.dart';
import 'package:amst/service/login.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

Drawer homeDrawer(GoogleLogin googleLogin, User? user) {
  ChatController chatController = Get.find();
  return Drawer(
      backgroundColor: primarySwatch.shade100,
      child: StreamBuilder<DocumentSnapshot>(
          stream: chatController.firebaseFirestore
              .collection('users')
              .doc(user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserModel userModel = userModelFromJson(
                  snapshot.data!.data() as Map<String, dynamic>);

              return Column(
                children: [
                  DrawerHeader(
                      child: Center(
                    child: ClipOval(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.3,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: CachedNetworkImage(
                          imageUrl: userModel.photoUrl,
                          imageBuilder: ((context, imageProvider) {
                            return CircleAvatar(
                              backgroundImage: imageProvider,
                            );
                          }),
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
                      userModel.nickname,
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
                      userModel.email,
                      minFontSize: 14,
                      maxFontSize: 16,
                      style: TextStyle(
                        color: primarySwatch.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AutoSizeText(
                          "About",
                          minFontSize: 18,
                          maxFontSize: 20,
                          style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: AutoSizeText(
                            userModel.about,
                            textAlign: TextAlign.right,
                            minFontSize: 14,
                            maxFontSize: 16,
                            style: TextStyle(
                              color: primarySwatch.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: OutlinedButton(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text("Sign Out"),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(FontAwesomeIcons.arrowRightFromBracket),
                          ],
                        ),
                        onPressed: () {
                          chatController.updateChatter(user.uid, "");
                          googleLogin.googleSingOut();
                        },
                      ),
                    ),
                  )),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "Version: 1.1",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                ],
              );
            }
            return const SizedBox.shrink();
          }));
}

AppBar homeAppBar(GlobalKey<ScaffoldState> scaKey, User? user) {
  ChatController chatController = Get.find();
  return AppBar(
    backgroundColor: primarySwatch.shade50,
    centerTitle: true,
    elevation: 0,
    leading: GestureDetector(
        onTap: () => scaKey.currentState!.openDrawer(),
        child: StreamBuilder<DocumentSnapshot>(
            stream: chatController.firebaseFirestore
                .collection('users')
                .doc(user!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CachedNetworkImage(
                  imageUrl: (snapshot.data!.data()
                      as Map<String, dynamic>)["photoUrl"],
                  cacheKey: "profile",
                  imageBuilder: ((context, imageProvider) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: primarySwatch,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundImage: imageProvider,
                        ),
                      ),
                    );
                  }),
                );
              }
              return const SizedBox.shrink();
            })),
    title: Text(
      "Message".toUpperCase(),
      style: const TextStyle(color: primarySwatch, letterSpacing: 2),
    ),
  );
}

AppBar chatAppBar(
  BuildContext context,
  UserModel model,
  String uID,
  ChatController controller,
) {
  return AppBar(
    backgroundColor: primarySwatch.shade50,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(
        FontAwesomeIcons.arrowLeft,
        color: primarySwatch,
      ),
      onPressed: () {
        controller.updateChatter(uID, "");
        Get.back();
      },
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
            StreamBuilder<DocumentSnapshot<UserModel>>(
              stream: controller.firebaseFirestore
                  .collection('users')
                  .doc(model.id)
                  .withConverter<UserModel>(
                      fromFirestore: (snapshot, options) =>
                          userModelFromJson(snapshot.data()!),
                      toFirestore: (value, options) => value.toJson())
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasData && snap.data != null) {
                  return AutoSizeText(
                    snap.data!.data()!.status == 'online'
                        ? "Online"
                        : getTimeStamp(snap.data!.data()!.onTime),
                    maxFontSize: 12,
                    minFontSize: 10,
                    style: TextStyle(color: primarySwatch.shade400),
                  );
                }
                return const SizedBox.shrink();
              },
            )
          ],
        )
      ],
    ),
  );
}

String getTimeStamp(String stamp) {
  DateFormat dateFormat = DateFormat("EEE:d:hh:mm:ss");
  DateFormat dateFormat2 = DateFormat("MMMM:EEE:d:hh:mm:ss");
  DateTime dateTime =
      Timestamp.fromMillisecondsSinceEpoch(int.parse(stamp)).toDate();
  if (dateTime.day == DateTime.now().day) {
    return "Last seen today ${DateFormat("hh:mm:ss a").format(dateTime)}";
  } else if (dateTime.day == DateTime.now().day - 1) {
    return "Last seen yesterday ${DateFormat("hh:mm:ss a").format(dateTime)}";
  } else if (dateTime.month < DateTime.now().month) {
    return "Last seen ${dateFormat2.format(dateTime)}";
  }
  return "Last seen ${dateFormat.format(dateTime)}";
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

Widget buildItem(
    int index,
    DocumentSnapshot snapshot,
    String currentId,
    String grpId,
    List<QueryDocumentSnapshot> messageList,
    BuildContext context) {
  if (!snapshot.isBlank!) {
    MessageModel messageModel =
        messageModelFromJson(snapshot.data() as Map<String, dynamic>);
    if (messageModel.idFrom == currentId) {
      return messageModel.type == "text"
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EmojiUtil.hasOnlyEmojis(messageModel.content)
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                            child: SizedBox(
                              width: messageModel.content.length == 2
                                  ? 100
                                  : MediaQuery.of(context).size.width - 140,
                              child: GestureDetector(
                                onLongPress: () => Clipboard.setData(
                                    ClipboardData(text: messageModel.content)),
                                child: AutoSizeText(
                                  messageModel.content,
                                  textAlign: TextAlign.right,
                                  maxFontSize: 38,
                                  minFontSize: 34,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                            constraints: BoxConstraints(
                                minWidth: 80,
                                maxWidth:
                                    MediaQuery.of(context).size.width - 140),
                            decoration: BoxDecoration(
                                color: primarySwatch.shade200,
                                borderRadius: BorderRadius.circular(8)),
                            margin: const EdgeInsets.only(
                                bottom: 5, right: 10, top: 5),
                            child: GestureDetector(
                              onLongPress: () => Clipboard.setData(
                                  ClipboardData(text: messageModel.content)),
                              child: AutoSizeText(
                                messageModel.content,
                                textAlign: TextAlign.left,
                                style: const TextStyle(color: primarySwatch),
                              ),
                            ),
                          ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 2, 15, 2),
                  child: showSenderTime(messageModel),
                )
              ],
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => Get.to(
                            () => ImageViewer(url: messageModel.content)),
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: messageModel.content,
                                fit: BoxFit.fill,
                              ),
                            )),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: showSenderTime(messageModel),
                  )
                ],
              ),
            );
    } else {
      return messageModel.type == "text"
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EmojiUtil.hasOnlyEmojis(messageModel.content)
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 15, 8),
                            child: SizedBox(
                              width: messageModel.content.length == 2
                                  ? 100
                                  : MediaQuery.of(context).size.width - 140,
                              child: GestureDetector(
                                onLongPress: () => Clipboard.setData(
                                    ClipboardData(text: messageModel.content)),
                                child: AutoSizeText(
                                  messageModel.content,
                                  maxFontSize: 38,
                                  minFontSize: 34,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 140),
                            decoration: BoxDecoration(
                                color: primarySwatch.shade700,
                                borderRadius: BorderRadius.circular(8)),
                            margin: const EdgeInsets.only(
                                left: 10, bottom: 5, top: 5),
                            child: GestureDetector(
                              onLongPress: () => Clipboard.setData(
                                  ClipboardData(text: messageModel.content)),
                              child: AutoSizeText(
                                messageModel.content,
                                style: TextStyle(color: primarySwatch.shade50),
                              ),
                            ),
                          ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14, top: 2, bottom: 2),
                  child: Text(
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
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(15, 2, 15, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => Get.to(
                            () => ImageViewer(url: messageModel.content)),
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: messageModel.content,
                                fit: BoxFit.fill,
                              ),
                            )),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: showSenderTime(messageModel),
                  )
                ],
              ),
            );
    }
  }
  return const SizedBox.shrink();
}

Text showSenderTime(MessageModel messageModel) {
  return Text(
    DateTime.fromMillisecondsSinceEpoch(int.parse(messageModel.timestamp))
                .day ==
            DateTime.now().day
        ? DateFormat('hh:mm aa').format(DateTime.fromMillisecondsSinceEpoch(
            int.parse(messageModel.timestamp)))
        : DateFormat('dd MMM kk:mm').format(DateTime.fromMillisecondsSinceEpoch(
            int.parse(messageModel.timestamp))),
    style: const TextStyle(fontSize: 6, color: primarySwatch),
  );
}
