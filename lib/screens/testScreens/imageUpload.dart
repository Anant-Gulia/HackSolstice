import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io' as io;

class image_upload extends StatefulWidget {
  const image_upload({Key? key}) : super(key: key);

  @override
  State<image_upload> createState() => _image_uploadState();
}

class _image_uploadState extends State<image_upload> {
  String imageURL = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("upload image"),
        backgroundColor: Colors.black,
        elevation: 0.0,
      ),
      body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              IconButton(onPressed: () async {
                ImagePicker imagePicker = ImagePicker();
                XFile? file = await imagePicker.pickImage(source: ImageSource.camera, imageQuality: 50);
                print('${file?.path}');
                String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
                Reference referenceRoot = FirebaseStorage.instance.ref();
                Reference referenceDirImages = referenceRoot.child('images');
                Reference referenceImageToUpload = referenceDirImages.child('${uniqueFileName}');


                try{
                  await referenceImageToUpload.putFile(io.File(file!.path));
                  var take = await referenceImageToUpload.getDownloadURL();
                  setState(() async {
                    imageURL = take;
                  });
                  print(imageURL);
                }
                catch(error){
                  print(error);
                }

              }, icon: Icon(Icons.camera_alt))

            ],
          )
      ),
    );
  }
}
