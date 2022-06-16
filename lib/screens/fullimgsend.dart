import 'dart:io';
import 'package:amst/model/usermodel.dart';
import 'package:amst/service/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class FullImgSender extends StatelessWidget {
  final XFile path;
  final User? user;
  final String grpId;
  final String peerId;
  final UserModel model;
  const FullImgSender(
      {super.key,
      required this.path,
      this.user,
      required this.grpId,
      required this.peerId,
      required this.model});

  @override
  Widget build(BuildContext context) {
    ChatController chatController = Get.find();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(path.name),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: Image.file(File(path.path)).image,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            chatController.sendImage(
                user: user,
                grpId: grpId,
                peerId: peerId,
                path: path.path,
                context: context,
                model: model);
          },
          child: const Icon(
            Icons.send,
            color: Colors.white,
          )),
    );
  }
}
