import 'package:amst/components/components.dart';
import 'package:amst/constant.dart';
import 'package:amst/model/usermodel.dart';
import 'package:amst/screens/chatscreen.dart';
import 'package:amst/service/login.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  final User? user;
  const HomeScreen({super.key, this.user});

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
            stream: FirebaseFirestore.instance.collection("users").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      String uId = snapshot.data!.docs[index].id;
                      if (uId != user!.uid) {
                        UserModel model = userModelFromJson(
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>);
                        return Column(
                          children: [
                            ListTile(
                              onTap: () => Get.to(() => ChatScreen(
                                  currentUID: user!.uid, model: model)),
                              leading: SizedBox(
                                height: 50,
                                width: 50,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: model.photoUrl,
                                    fadeInDuration: const Duration(),
                                  ),
                                ),
                              ),
                              title: AutoSizeText(
                                model.nickname,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: AutoSizeText(
                                model.email,
                                style: const TextStyle(
                                  color: Colors.black12,
                                ),
                              ),
                            ),
                            const Divider()
                          ],
                        );
                      }
                      return const SizedBox();
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
