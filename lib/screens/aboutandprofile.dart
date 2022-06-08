import 'dart:io';
import 'package:amst/constant.dart';
import 'package:amst/controllers/imagecontroller.dart';
import 'package:amst/screens/homescreen.dart';
import 'package:amst/service/chat.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class InfoPage extends StatelessWidget {
  final User? user;
  const InfoPage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    ImageController imageController = Get.put(ImageController());
    ChatController chatController = Get.find();
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                SvgPicture.asset('assets/svg/info.svg'),
                Positioned(
                  bottom: 0,
                  left: MediaQuery.of(context).size.width / 2.8,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user!.photoURL!,
                      imageBuilder: (context, imageProvider) {
                        return GestureDetector(
                          onTap: () async {
                            XFile? file = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (file != null) {
                              imageController.makePath(file.path);
                            }
                          },
                          child: Obx(() => Container(
                                height: MediaQuery.of(context).size.width * 0.3,
                                width: MediaQuery.of(context).size.width * 0.3,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image:
                                        imageController.imagepath.value.isEmpty
                                            ? DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover)
                                            : DecorationImage(
                                                image: Image.file(File(
                                                        imageController
                                                            .imagepath.value))
                                                    .image,
                                                fit: BoxFit.cover)),
                                child: Center(
                                  child: Icon(
                                    FontAwesomeIcons.plus,
                                    color: primarySwatch.shade100,
                                    size:
                                        MediaQuery.of(context).size.width * 0.1,
                                  ),
                                ),
                              )),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: imageController.textController.value,
                decoration: InputDecoration(
                    filled: false,
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: primarySwatch.shade300, width: 1)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: primarySwatch.shade300, width: 1)),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: primarySwatch, width: 2)),
                    hintText: 'About your self',
                    hintStyle: const TextStyle(
                      color: primarySwatch,
                    )),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.03,
                  bottom: MediaQuery.of(context).size.height * 0.08,
                  left: 8,
                  right: 8),
              child: AutoSizeText(
                "Let's have a great fun with AmSt. Privacy is the main thing don't worry about it. \nEnjoy it !",
                textAlign: TextAlign.center,
                maxFontSize: 20,
                minFontSize: 18,
                style: TextStyle(color: primarySwatch.shade500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                      onPressed: () async {
                        if (imageController.textController.value.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: primarySwatch.shade100,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20))),
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: const [
                                  Icon(
                                    FontAwesomeIcons.ban,
                                    color: Colors.red,
                                  ),
                                  AutoSizeText(
                                      "Please give some details in about !",
                                      style: TextStyle(color: primarySwatch))
                                ],
                              )));
                        } else {
                          if (imageController.imagepath.isEmpty) {
                            showLoaderDialog(context);
                            chatController.updateAbout(user!.uid,
                                imageController.textController.value.text);
                            Navigator.pop(context);
                            Get.off(() => HomeScreen(
                                  user: user,
                                ));
                          } else {
                            showLoaderDialog(context);
                            await chatController.uploadImage(
                                imageController.imagepath.value,
                                user!.uid,
                                imageController.textController.value.text,
                                context);
                            Get.off(() => HomeScreen(
                                  user: user,
                                ));
                          }
                        }
                      },
                      child: const Text("AmSt"))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
