import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

import 'package:path_provider/path_provider.dart' as syspaths;

class ImageInput extends StatefulWidget {
  final Function onSelectImage;

  final Function onUnselectImage;

  ImageInput(this.onSelectImage, this.onUnselectImage);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  XFile _storedImage;
  String imagePath;

  Future<void> _takePicture() async {
    final imageFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (imageFile == null) {
      return;
    }
    setState(() {
      _storedImage = imageFile;
    });
    imagePath = imageFile.path;
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    //final fileName = path.basename(imageFile.path);
    final savedImage = await imageFile.saveTo('${appDir.path}/$imagePath');
    widget.onSelectImage(savedImage);
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
              ? Image.file(File(imagePath))
              : Text(
                  'No Image Taken',
                  textAlign: TextAlign.center,
                ),
          alignment: Alignment.center,
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          children: [
            FlatButton.icon(
              icon: Icon(Icons.camera),
              label: Text('Take Picture'),
              textColor: Theme.of(context).primaryColor,
              onPressed: _takePicture,
            ),
            FlatButton.icon(
              icon: Icon(Icons.cancel),
              label: Text('Cancel Picture'),
              textColor: Theme.of(context).primaryColor,
              onPressed: _cancelPicture,
            ),
          ],
        )
      ],
    );
  }
}
