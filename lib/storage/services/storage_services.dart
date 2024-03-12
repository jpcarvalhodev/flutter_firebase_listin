import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_firebase_listin/storage/models/image_custom_info.dart';

class StorageServices {
  String pathServices = FirebaseAuth.instance.currentUser!.uid;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String> upload({required File file, required String fileName}) async {
    await _firebaseStorage.ref("$pathServices/$fileName.png").putFile(file);
    String url = await _firebaseStorage
        .ref("$pathServices/$fileName.png")
        .getDownloadURL();
    await _firebaseAuth.currentUser!.updatePhotoURL(url);
    return url;
  }

  Future<String> getDownloadUrlByFileName({required String fileName}) async {
    return await _firebaseStorage
        .ref("$pathServices/$fileName.png")
        .getDownloadURL();
  }

  Future<List<ImageCustomInfo>> listAllFiles() async {
    ListResult result = await _firebaseStorage.ref(pathServices).listAll();
    List<Reference> listReference = result.items;

    List<ImageCustomInfo> listFiles = [];
    for (Reference reference in listReference) {
      String urlDownload = await reference.getDownloadURL();
      String name = reference.name;
      FullMetadata metadata = await reference.getMetadata();
      int? size = metadata.size;
      String sizeString = "No size data";
      if (size != null) {
        sizeString = "${size / 1024} Kb";
      }
      listFiles.add(ImageCustomInfo(
          urlDownload: urlDownload, name: name, size: sizeString, ref: reference));
    }
    return listFiles;
  }

  Future<void> deleteByRef({required ImageCustomInfo imageInfo}) async {
    if (_firebaseAuth.currentUser!.photoURL != null) {
      if (_firebaseAuth.currentUser!.photoURL! == imageInfo.urlDownload) {
        await _firebaseAuth.currentUser!.updatePhotoURL(null);
      }
    }
    return await imageInfo.ref.delete();
  }
}
