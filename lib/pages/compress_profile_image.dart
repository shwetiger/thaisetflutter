// @dart=2.9
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class CompressProfileImage {
  static Future<File> compressFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 100,
      minHeight: 200,
      minWidth: 200,
      format: CompressFormat.png,
    );
    return result;
  }

  static Future<UploadTask> uploadFile(
      PickedFile file, BuildContext context) async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file was selected'),
      ));
      return null;
    }

    var dateTime = DateTime.now();
    var dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);

    UploadTask uploadTask;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('profile/${FirebaseAuth.instance.currentUser.uid}')
        .child(dateFormat.toString() + "_" + "userphoto.png");
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = dir.absolute.path + "/temp.png";
    File compressedFile =
        await CompressProfileImage.compressFile(File(file.path), targetPath);
    final metadata = SettableMetadata(
        contentType: 'image/png',
        customMetadata: {'picked-file-path': file.path});

    if (kIsWeb) {
      uploadTask = ref.putData(await file.readAsBytes(), metadata);
    } else {
      // uploadTask = ref.putFile(File(file.path), metadata);
      uploadTask = ref.putFile(File(compressedFile.path), metadata);
    }

    return Future.value(uploadTask);
  }
}
