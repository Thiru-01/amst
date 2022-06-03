import 'package:amst/model/messagemodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

willPop() {}

class ChatController extends GetxController {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

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

  void sendMessage(String text, String grpId, String peerId, String currentId) {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
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
        type: "text");
    firebaseFirestore.runTransaction((transaction) async {
      transaction.set(documentReference, messageModel.toJson());
    });
  }

  void updateChatter(String uID, String peerId) {
    firebaseFirestore
        .collection('users')
        .doc(uID)
        .update({"chattingWith": peerId});
  }
}
