import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart' as syspaths;

class ImageInput extends StatefulWidget {
  final Function onSelectImage;
  final Function onUnselectImage;
  XFile? image;

  ImageInput(this.onSelectImage, this.onUnselectImage, this.image);

  @override
  _ImageInputState createState() => _ImageInputState(image);
}

class _ImageInputState extends State<ImageInput> {
  XFile? _storedImage;
  String? imagePath;

  _ImageInputState(this._storedImage) {
    this._storedImage == null
        ? this.imagePath = null
        : this.imagePath = this._storedImage!.path;
  }

  Future<void> _choosePicture() async {
    final imageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile == null) {
      return;
    }
    setState(() {
      _storedImage = imageFile;
    });
    imagePath = imageFile.path;
    // final appDir = await syspaths.getApplicationDocumentsDirectory();
    // final fileName = path.basename(imageFile.path);
    // final savedImage = await imageFile.saveTo('${appDir.path}/$imagePath');
    widget.onSelectImage(imageFile);
  }

  Future<void> _cancelPicture() async {
    setState(() {
      _storedImage = null;
    });
    widget.onUnselectImage();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: _storedImage != null
              ? Image.file(File(imagePath!))
              : const Image(
                  image: AssetImage('assets/images/default-store.png')),
          alignment: Alignment.center,
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          children: [
            FlatButton.icon(
              icon: Icon(Icons.camera),
              label: Text('Choose Image'),
              textColor: Theme.of(context).primaryColor,
              onPressed: _choosePicture,
            ),
            FlatButton.icon(
              icon: Icon(Icons.cancel),
              label: Text('Cancel Image'),
              textColor: Theme.of(context).primaryColor,
              onPressed: _cancelPicture,
            ),
          ],
        )
      ],
    );
  }
}
