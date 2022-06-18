import 'package:amst/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLogin {
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? currentUser;
  GoogleSignInAccount get user => currentUser!;

  Future googleSingOut() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
  }

  Future googleSignUp() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return;
    }
    currentUser = googleUser;
    final googleAuth = await googleUser.authentication;
    final String? messToken = await firebaseMessaging.getToken();
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    final User? user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    if (user != null) {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: user.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isEmpty) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nickname': user.displayName,
          'photoUrl': user.photoURL,
          'id': user.uid,
          "email": user.email,
          "messageToken": messToken!,
          "chattingWith": '',
          "lastTime": '0',
          'about': '',
          'time': DateTime.now().millisecondsSinceEpoch.toString(),
          'status': 'online'
        });
      }
    }
  }
}
