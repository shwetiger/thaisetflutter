// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:thai2dlive/models/chat_msg.dart';
import 'package:thai2dlive/models/chat_user.dart';
import 'package:thai2dlive/pages/user_ph_login.dart';
import 'package:thai2dlive/utils/message_handel.dart';
import '../pages/chat.dart';

class LoginProvider with ChangeNotifier, DiagnosticableTreeMixin {
  var userRef = FirebaseFirestore.instance.collection(chatUserCollection);
  var msgRef = FirebaseFirestore.instance.collection(chatMessageCollection);

  bool _isloading = false;
  bool get isloading => _isloading;

  List<ChatMessage> get msgs => _msgs;
  List<ChatMessage> _msgs = [];

  Future<void> logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  Future<void> sendMessage(BuildContext context, ChatMessage msg) async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      msgRef.add(msg.toJson()).then((DocumentReference doc) {
        doc.update({
          "id": doc.id,
          "createdAt": FieldValue.serverTimestamp(),
        });
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const UserPhLoginScreen(),
        ),
      );
    }
    notifyListeners();
  }

  Future<bool> register(BuildContext context, String vId, String vCode,
      ChatUser userModel) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: vId,
        smsCode: vCode,
      );
      final User user = (await _auth.signInWithCredential(credential)).user;

      if (user != null) {
        userModel.id = user.uid;

        await FirebaseFirestore.instance
            .collection(chatUserCollection)
            .doc(user.uid)
            .get()
            .then((value) async {
          if (value.exists) {
            await FirebaseFirestore.instance
                .collection(chatUserCollection)
                .doc(user.uid)
                .update({
              "createdAt": userModel.createdAt,
              "fcmtoken": userModel.fcmtoken,
              "id": userModel.id,
              "imageUrl": userModel.imageUrl,
              "name": userModel.name,
              "phoneNo": userModel.phoneNo
            });
          } else {
            await FirebaseFirestore.instance
                .collection(chatUserCollection)
                .doc(user.uid)
                .set(userModel.toJson())
                .then((value) {});
          }
        });

        notifyListeners();
        return true;
      } else {
        notifyListeners();
        return false;
      }
    } catch (e) {
      MessageHandel.showErrSnackbar(
          "Failed to sign in :" + e.toString(), context, 5);
      return false;
    }
  }
}
