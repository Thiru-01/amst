import 'package:amst/components/components.dart';
import 'package:amst/constant.dart';
import 'package:amst/model/usermodel.dart';
import 'package:amst/service/chat.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  final User? currentUID;
  final Rx<UserModel> model;
  const ChatScreen({super.key, required this.currentUID, required this.model});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  ChatController chatController = Get.find();
  TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();
  int _limit = 20;
  final int _limtIncrease = 20;
  List<QueryDocumentSnapshot> messagelist = [];
  String groupId = '';
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    groupId =
        chatController.getGrpId(widget.currentUID!.uid, widget.model.value.id);
    scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        printInfo(info: "Resumed");
        chatController.updateChatter(
            widget.currentUID!.uid, widget.model.value.id);
        break;

      case AppLifecycleState.paused:
        printInfo(info: "Pasued");
        chatController.updateChatter(widget.currentUID!.uid, "");
        break;
      case AppLifecycleState.inactive:
        printInfo(info: "Inactive");
        break;
      case AppLifecycleState.detached:
        printInfo(info: "App Detached");
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addObserver(this);
    super.dispose();
    chatController.updateChatter(widget.currentUID!.uid, "");
  }

  _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        _limit <= messagelist.length) {
      setState(() {
        _limit += _limtIncrease;
      });
    }
  }

  void onSendMessage(String content) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatController.sendMessage(content, groupId, widget.model.value.id,
          widget.currentUID!.uid, widget.model.value, widget.currentUID);
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: "Please enter message",
          backgroundColor: primarySwatch.shade300,
          gravity: ToastGravity.BOTTOM,
          textColor: primarySwatch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: chatAppBar(
          context, widget.model.value, widget.currentUID!.uid, chatController),
      body: WillPopScope(
          onWillPop: willPop(),
          child: Stack(
            children: [
              Column(
                children: [
                  chatWidget(),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            padding: const EdgeInsets.all(10),
                            child: InkWell(
                              child: const Icon(
                                FontAwesomeIcons.plus,
                                color: primarySwatch,
                              ),
                              onTap: () {},
                            ),
                          ),
                          Flexible(
                              child: SizedBox(
                            child: TextField(
                              controller: textEditingController,
                              enableSuggestions: true,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 15, right: 15, top: 5, bottom: 5),
                                hintText: "Type the message",
                              ),
                            ),
                          )),
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            child: OutlinedButton(
                              child: const Icon(
                                Icons.send,
                                color: primarySwatch,
                              ),
                              onPressed: () =>
                                  onSendMessage(textEditingController.text),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          )),
    );
  }

  Flexible chatWidget() {
    return Flexible(
        child: groupId.isNotEmpty
            ? StreamBuilder<QuerySnapshot>(
                stream: chatController.getChatStream(groupId, _limit),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    messagelist = snapshot.data!.docs;
                    if (messagelist.isNotEmpty) {
                      return ListView.builder(
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        controller: scrollController,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return buildItem(index, snapshot.data!.docs[index],
                              widget.currentUID!.uid, messagelist, context);
                        },
                      );
                    } else {
                      return Center(
                        child: AutoSizeText(
                          maxFontSize: 15,
                          minFontSize: 13,
                          "Start New Convensation !",
                          style: TextStyle(
                              color: primarySwatch.shade500,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}
