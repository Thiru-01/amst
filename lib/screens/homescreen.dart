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

class HomeScreen extends StatefulWidget {
  final User? user;
  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  ChatController chatController = Get.find();
  @override
  void initState() {
    chatController.updateStatus(widget.user!.uid, "online");
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        printInfo(info: "Home - resumed");
        chatController.updateStatus(widget.user!.uid, "online");
        chatController.updateLastseen(widget.user!.uid);
        break;

      case AppLifecycleState.paused:
        printInfo(info: "Home - paused");
        chatController.updateStatus(widget.user!.uid, "offline");
        chatController.updateLastseen(widget.user!.uid);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final GoogleLogin googleLogin = Get.put(GoogleLogin());
    GlobalKey<ScaffoldState> scaKey = GlobalKey();
    return Scaffold(
      key: scaKey,
      appBar: homeAppBar(scaKey, widget.user),
      drawer: homeDrawer(googleLogin, widget.user),
      body: SizedBox(
        height: height(context),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .orderBy("lastTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      String uId = snapshot.data!.docs[index].id;
                      if (uId != widget.user!.uid) {
                        Rx<UserModel> model = userModelFromJson(
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>)
                            .obs;

                        String grpId = chatController.getGrpId(
                            widget.user!.uid, model.value.id);
                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                chatController.updateChatter(
                                    widget.user!.uid, model.value.id);

                                Get.to(() => ChatScreen(
                                    currentUID: widget.user, model: model));
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
                                          model.content.contains(
                                                  "https://firebasestorage.googleapis.com/v0/b/amst-88009.appspot.com")
                                              ? "Photo 📷"
                                              : model.content,
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
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return const SizedBox();
            }),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
