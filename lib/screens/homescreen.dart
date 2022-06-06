// ignore_for_file: must_be_immutable

import 'package:amst/components/components.dart';
import 'package:amst/constant.dart';
import 'package:amst/model/messagemodel.dart';
import 'package:amst/model/usermodel.dart';
import 'package:amst/screens/chatscreen.dart';
import 'package:amst/service/chat.dart';
import 'package:amst/service/login.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget with WidgetsBindingObserver {
  final User? user;
  HomeScreen({super.key, this.user});
  ChatController chatController = Get.put(ChatController());

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        printInfo(info: "Resumed");
        break;

      case AppLifecycleState.paused:
        printInfo(info: "Pasued");
        break;
      case AppLifecycleState.inactive:
        printInfo(info: "Inactive");
        break;
      case AppLifecycleState.detached:
        chatController.updateChatter(user!.uid, "");
        printInfo(info: "App Detached");
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final GoogleLogin googleLogin = Get.put(GoogleLogin());
    GlobalKey<ScaffoldState> scaKey = GlobalKey();
    return Scaffold(
      key: scaKey,
      appBar: homeAppBar(scaKey, user),
      drawer: homeDrawer(googleLogin, user),
      body: SizedBox(
        height: height(context),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .orderBy("lastTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AnimatedList(
                    initialItemCount: snapshot.data!.docs.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index, animation) {
                      String uId = snapshot.data!.docs[index].id;
                      if (uId != user!.uid) {
                        Rx<UserModel> model = userModelFromJson(
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>)
                            .obs;

                        String grpId =
                            chatController.getGrpId(user!.uid, model.value.id);
                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                chatController.updateChatter(
                                    user!.uid, model.value.id);
                                Get.to(() =>
                                    ChatScreen(currentUID: user, model: model));
                              },
                              leading: SizedBox(
                                height: 50,
                                width: 50,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: model.value.photoUrl,
                                    fadeInDuration: const Duration(),
                                  ),
                                ),
                              ),
                              title: AutoSizeText(
                                model.value.nickname,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: StreamBuilder<QuerySnapshot>(
                                  stream: chatController.getLastChat(grpId),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data!.docs.isNotEmpty) {
                                        MessageModel model =
                                            messageModelFromJson(
                                                snapshot.data!.docs[0].data()
                                                    as Map<String, dynamic>);
                                        return AutoSizeText(
                                          model.content,
                                          style: const TextStyle(
                                            color: Colors.black12,
                                          ),
                                        );
                                      }
                                    }
                                    return AutoSizeText(
                                      model.value.email,
                                      style: const TextStyle(
                                        color: Colors.black12,
                                      ),
                                    );
                                  }),
                            ),
                            const Divider()
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    });
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}
