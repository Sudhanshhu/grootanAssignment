import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:grootan_test/models/user_detail_model.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String destination, Uint8List file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(file);
    } on FirebaseException {
      return null;
    }
  }

  static Future<void> uploadUserStatus(UserModel userModel) async {
    return FirebaseFirestore.instance.collection("users").doc("").update({
      "userDetail": FieldValue.arrayUnion([userModel.toMap()])
    });
  }
}
