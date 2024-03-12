import "dart:io";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_firebase_listin/authentication/components/show_snackbar.dart";
import "package:flutter_firebase_listin/storage/models/image_custom_info.dart";
import "package:flutter_firebase_listin/storage/services/storage_services.dart";
import "package:flutter_firebase_listin/storage/widgets/source_modal_widget.dart";
import "package:image_picker/image_picker.dart";

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  String? urlPhoto;
  List<ImageCustomInfo> photoList = [];

  final StorageServices _storageServices = StorageServices();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Photo"),
        actions: [
          IconButton(
            onPressed: () {
              uploadImage();
            },
            icon: const Icon(Icons.upload),
          ),
          IconButton(
            onPressed: () {
              refresh();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            (urlPhoto != null)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(64),
                    child: Image.network(
                      urlPhoto!,
                      height: 128,
                      width: 128,
                      fit: BoxFit.cover,
                    ),
                  )
                : const CircleAvatar(
                    radius: 64,
                    child: Icon(Icons.person),
                  ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Divider(
                color: Colors.black38,
              ),
            ),
            const Text("Image List",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(photoList.length, (index) {
                    ImageCustomInfo imageInfo = photoList[index];
                    return ListTile(
                        onTap: () {
                          selectImage(imageInfo);
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(imageInfo.urlDownload,
                              height: 48, width: 48, fit: BoxFit.cover),
                        ),
                        title: Text(imageInfo.name),
                        subtitle: Text(imageInfo.size),
                        trailing: IconButton(
                          onPressed: () {
                            deleteImage(imageInfo);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ));
                  }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  uploadImage() {
    ImagePicker imagePicker = ImagePicker();
    showSourceModalWidget(context: context).then((bool? value) {
      ImageSource source = ImageSource.gallery;

      if (value != null) {
        if (value) {
          source = ImageSource.gallery;
        } else {
          source = ImageSource.camera;
        }

        imagePicker
            .pickImage(
                source: source,
                maxHeight: 2000,
                maxWidth: 2000,
                imageQuality: 50)
            .then((XFile? image) {
          if (image != null) {
            _storageServices
                .upload(
                    file: File(image.path), fileName: DateTime.now().toString())
                .then((urlDownload) {
              setState(() {
                urlPhoto = urlDownload;
                refresh();
              });
            });
          } else {
            showSnackBar(context: context, message: "No image selected");
          }
        });
      }
    });
  }

  refresh() {
    setState(() {
      urlPhoto = _firebaseAuth.currentUser!.photoURL;
    });
    _storageServices.listAllFiles().then((List<ImageCustomInfo> listFilesInfo) {
      setState(() {
        photoList = listFilesInfo;
      });
    });
  }

  selectImage(ImageCustomInfo imageInfo) {
    _firebaseAuth.currentUser!.updatePhotoURL(imageInfo.urlDownload);
    setState(() {
      urlPhoto = imageInfo.urlDownload;
    });
  }

  deleteImage(ImageCustomInfo imageInfo) {
    _storageServices.deleteByRef(imageInfo: imageInfo).then((value) {
      if (urlPhoto == imageInfo.urlDownload) {
        urlPhoto = null;
      }
      refresh();
    });
  } 
}
