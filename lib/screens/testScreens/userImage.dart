import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class UserImage extends StatefulWidget {
  final Function(String imageUrl) onFileChanged;
  const UserImage({Key? key, required this.onFileChanged}) : super(key: key);

  @override
  State<UserImage> createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  final ImagePicker _picker = ImagePicker();
  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      // children: [
      //   if( imageUrl == null)
      //     Icon(Icons.image, size: 60, color: Colors.blue,),
      //
      //   InkWell(
      //     onTap: () => _selectPhoto(),
      //     child: Padding(
      //       padding: EdgeInsets.all(8),
      //       child: Text(imageUrl != null ? 'Change Photo' : 'Select photo'),
      //     ),
      //   )
      //
      // ],
    );
  }
//
// Future _selectPhoto() async {
//   await showModalBottomSheet(context: context, builder: builder) => BottomSheet(builder: (context) => Column(
//     mainAxisAlignment: MainAxisSize.min,
//     children: [
//       ListTile(
//           leading: Icon(Icons.camera),
//           title: Text("Camera"),
//         onTap: () {
//             Navigator.of(context).pop();
//             _pickImage(ImageSource.camera);
//         },
//       ),
//     ],
//
//
//   ) ,onClosing: () {},);
// }

// Future _pickImage() async {
//   final pickedFile = await _picker.pickImage(source: source , imageQuality: 50);
//   if(pickedFile == null){
//     return;
//   }
//    var file = await compressImage(pickedFile.path, 35);
// }

// Future<File> compressImage(String path, int quality) async {
//   final newPath = p.join(
//     (await getTemporaryDirectory()).path,
//     '${(DateTime.now())}.${p.extension(path)}'
//   );
//   final result = await FlutterImageCompress.compressAndGetFile(path, newPath, quality: quality);
//
//   return result;
// }
// Future _uploadFile(String path) async {
//   final ref = storage.FirebaseStorage. instance. ref()
//   .child('inages')
//   .child('${DateTime.now() . toIso8601String() + p.basename (path)}');
//
//   final result = await ref.putFile(File(path));
//   final fileUrl = await result.ref.getDownloadURL();
//
//   setState(() { imageUrl = fileUrl; });
//
//   widget.onFileChanged(fileUrl);
//
//   }
}
