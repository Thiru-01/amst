import 'dart:convert';
import 'dart:io';

import 'package:amst/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:amst/model/messagemodel.dart';
import 'package:amst/model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

willPop() {}

class ChatController extends GetxController {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  RxString imgaePath = ''.obs;
  Future updateFirestore(
      {required String collectionPath,
      required String docs,
      required Map<String, dynamic> toUpdate}) async {
    await firebaseFirestore
        .collection(collectionPath)
        .doc(docs)
        .update(toUpdate);
  }

  String getGrpId(String currentId, String peerId) {
    if (currentId.hashCode <= peerId.hashCode) {
      return '$currentId-$peerId';
    } else {
      return '$peerId-$currentId';
    }
  }

  Stream<QuerySnapshot> getChatStream(String grpIp, int limit) {
    return firebaseFirestore
        .collection("message")
        .doc(grpIp)
        .collection(grpIp)
        .orderBy("timestamp", descending: true)
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastChat(String grpId) {
    return firebaseFirestore
        .collection('message')
        .doc(grpId)
        .collection(grpId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  void sendMessage(String text, String grpId, String peerId, String currentId,
      UserModel model, User? user) {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    updateTimeStamp(user!.uid);
    DocumentReference documentReference = firebaseFirestore
        .collection("message")
        .doc(grpId)
        .collection(grpId)
        .doc(timeStamp);
    MessageModel messageModel = MessageModel(
      idFrom: currentId,
      idTo: peerId,
      timestamp: timeStamp,
      content: text,
      type: "text",
    );
    firebaseFirestore.runTransaction((transaction) async {
      transaction.set(documentReference, messageModel.toJson());
    }).whenComplete(() async {
      try {
        UserModel? peer;
        QuerySnapshot rawData =
            await FirebaseFirestore.instance.collection("users").get();
        for (var element in rawData.docs) {
          UserModel model =
              userModelFromJson(element.data() as Map<String, dynamic>);
          if (model.id == peerId) {
            peer = model;
          }
        }
        printInfo(info: "peer curr: $currentId");
        printInfo(info: "Peer: ${peer!.chattingWith}");
        if (currentId != peer.chattingWith) {
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'key=$pushMessageKey',
              },
              body: jsonEncode(
                <String, dynamic>{
                  "to": model.messageToken,
                  'notification': <String, dynamic>{
                    'body': '${user.displayName}: $text',
                    'title': "AmSt",
                  },
                },
              ));
        }
      } catch (e) {
        printInfo(info: e.toString());
      }
    });
  }

  void updateTimeStamp(
    String uid,
  ) {
    firebaseFirestore
        .collection('users')
        .doc(uid)
        .update({"lastTime": DateTime.now().microsecondsSinceEpoch});
  }

  void updateChatter(String uID, String peerId) {
    firebaseFirestore
        .collection('users')
        .doc(uID)
        .update({"chattingWith": peerId});
  }

  Stream<DocumentSnapshot> getUser(String id) {
    return firebaseFirestore.collection('users').doc(id).snapshots();
  }

  void updateAbout(String id, String about) {
    firebaseFirestore.collection('users').doc(id).update({"about": about});
  }

  Future<void> uploadImage(
      String path, String id, String about, context) async {
    updateAbout(id, about);
    var task = await firebaseStorage.ref("dp/").putFile(File(path));
    firebaseFirestore
        .collection('users')
        .doc(id)
        .update({"photoUrl": await task.ref.getDownloadURL()});
    Navigator.pop(context);
  }

  void sendImage(
      {required User? user,
      required String grpId,
      required String peerId,
      required String path,
      required UserModel model}) async {
    var task = await firebaseStorage.ref("$grpId/").putFile(File(path));
    String pathS = await task.ref.getDownloadURL();
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    updateTimeStamp(user!.uid);
    DocumentReference documentReference = firebaseFirestore
        .collection("message")
        .doc(grpId)
        .collection(grpId)
        .doc(timeStamp);
    MessageModel messageModel = MessageModel(
      idFrom: user.uid,
      idTo: peerId,
      timestamp: timeStamp,
      content: pathS,
      type: "image",
    );
    firebaseFirestore.runTransaction((transaction) async {
      transaction.set(documentReference, messageModel.toJson());
    }).whenComplete(() async {
      try {
        UserModel? peer;
        QuerySnapshot rawData =
            await FirebaseFirestore.instance.collection("users").get();
        for (var element in rawData.docs) {
          UserModel model =
              userModelFromJson(element.data() as Map<String, dynamic>);
          if (model.id == peerId) {
            peer = model;
          }
        }
        if (user.uid != peer!.chattingWith) {
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'key=$pushMessageKey',
              },
              body: jsonEncode(
                <String, dynamic>{
                  "to": model.messageToken,
                  'notification': <String, dynamic>{
                    'body': '${user.displayName}: Photo 📷',
                    'title': "AmSt",
                  },
                },
              ));
        }
      } catch (e) {
        printInfo(info: e.toString());
      }
    });
  }
}
