// @dart=2.9
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:thai2dlive/models/chat_user.dart';
import 'package:thai2dlive/utils/message_handel.dart';
import 'package:thai2dlive/utils/validator.dart';
import 'chat.dart';
import 'compress_profile_image.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key key}) : super(key: key);

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _pscaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool isPhoneToken = false;
  String fcmtoken = "";
  ChatUser chatUser = ChatUser();

  bool _isLoading = false;

  @override
  void initState() {
    getUser();

    super.initState();
  }

  void getUser() async {
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseFirestore.instance
          .collection(chatUserCollection)
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get()
          .then((value) {
        chatUser = ChatUser.fromJson(value.data());
        _nameController.text = chatUser.name;
        setState(() {
          photoUrl = chatUser.imageUrl;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _pscaffoldKey,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: mainColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Card(
            margin:
                const EdgeInsets.only(top: 0, bottom: 8, right: 16, left: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              padding: const EdgeInsets.only(
                  left: 16, top: 16, right: 16, bottom: 16),
              alignment: Alignment.center,
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _previewProfileImages(),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        autofocus: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          return Validator.userName(
                              context, val, "User Name", true);
                        },
                        decoration: const InputDecoration(
                          labelText: "User Name",
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                side: BorderSide(
                                  width: 1.0,
                                  color: Theme.of(context).primaryColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: const Text(
                                  "Cancel",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          _isLoading
                              ? Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      side: BorderSide(
                                        width: 1.0,
                                        color: Theme.of(context).primaryColor,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      child: const Text(
                                        "Loading...",
                                      ),
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      side: BorderSide(
                                        width: 1.0,
                                        color: Theme.of(context).primaryColor,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    onPressed: _submiting
                                        ? null
                                        : () async {
                                            if (_formKey.currentState
                                                .validate()) {
                                              chatUser.name =
                                                  _nameController.text.trim();

                                              if (FirebaseAuth
                                                      .instance.currentUser !=
                                                  null) {
                                                User user = FirebaseAuth
                                                    .instance.currentUser;

                                                if (file != null) {
                                                  setState(() {
                                                    _isuploadingPicture = true;
                                                  });

                                                  UploadTask task =
                                                      await CompressProfileImage
                                                          .uploadFile(
                                                              PickedFile(
                                                                  file.path),
                                                              context);
                                                  if (task != null) {
                                                    task.whenComplete(() async {
                                                      chatUser.imageUrl =
                                                          await task
                                                              .snapshot.ref
                                                              .getDownloadURL();
                                                      setState(() {
                                                        _isuploadingPicture =
                                                            false;
                                                      });

                                                      updateUser(context);
                                                    });
                                                  }
                                                } else {
                                                  updateUser(context);
                                                }
                                              }
                                            }
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      child: const Text(
                                        "Save",
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateUser(BuildContext context) async {
    _isLoading = true;
    setState(() {});
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      String uid = FirebaseAuth.instance.currentUser.uid.toString();
      try {
        await FirebaseFirestore.instance
            .collection(chatUserCollection)
            .doc(uid)
            .update({
          "phoneNo": chatUser.phoneNo,
          "name": chatUser.name,
          "imageUrl": chatUser.imageUrl
        });
        var collection = await FirebaseFirestore.instance
            .collection(chatMessageCollection)
            .where('authorId', isEqualTo: uid);
        var querySnapshots = await collection.get();
        for (var snapshot in querySnapshots.docs) {
          var documentID = snapshot.get('id');
          await FirebaseFirestore.instance
              .collection(chatMessageCollection)
              .doc(documentID)
              .update({
            "authorName": chatUser.name,
            "authorPhoto": chatUser.imageUrl
          });
        }
        _isLoading = false;
        setState(() {});
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const ChatScreen(),
            ),
            (route) => false);
        MessageHandel.showMessage(
          context,
          "Successfully Updated",
          "Your user profile is successfully updated.",
        );
      } catch (e) {
        MessageHandel.showErrMessage(
          context,
          "Update fail!",
          "Updating your user profile fail!",
        );
        setState(() {
          _submiting = false;
        });
      }
    }
  }

  String photoUrl;
  bool _submiting = false;
  bool _isuploadingPicture = false;
  XFile file;

  Widget _previewProfileImages() {
    if (file != null || (photoUrl != null && photoUrl != "")) {
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 60),
          height: 120,
          width: 120,
          child: Stack(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: file != null
                      ? FileImage(File(file.path))
                      : CachedNetworkImageProvider(
                          photoUrl,
                          headers: <String, String>{
                            "Access-Control-Allow-Origin": "*",
                          },
                        ),
                  radius: 50,
                ),
              ),
              Positioned(
                top: 80,
                left: 80,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: IconButton(
                      onPressed: _submiting ? null : chooseImage,
                      icon: const Icon(
                        Icons.photo_camera,
                        size: 20,
                        color: Colors.white,
                      )),
                ),
              ),
              _isuploadingPicture
                  ? Container(
                      constraints: const BoxConstraints.expand(
                        //width: MediaQuery.of(context).size.width-50,
                        height: 200,
                      ),
                      child: const SpinKitCubeGrid(
                        color: Colors.white,
                        size: 100,
                      ))
                  : Container(),
            ],
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 60),
          height: 120,
          width: 120,
          child: Stack(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage(
                  "assets/default_user.png",
                ),
                radius: 80,
              ),
              Positioned(
                top: 80,
                left: 80,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: IconButton(
                      onPressed: _submiting ? null : chooseImage,
                      icon: const Icon(
                        Icons.photo_camera,
                        size: 20,
                        color: Colors.white,
                      )),
                ),
              ),
              _isuploadingPicture
                  ? Container(
                      constraints: const BoxConstraints.expand(
                        //width: MediaQuery.of(context).size.width-50,
                        height: 200,
                      ),
                      child: const SpinKitCubeGrid(
                        color: Colors.white,
                        size: 100,
                      ))
                  : Container(),
            ],
          ),
        ),
      );
    }
  }

  chooseImage() async {
    final XFile image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      file = image;
    });
  }
}
