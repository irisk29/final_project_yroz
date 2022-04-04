import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  final Function onSelectImage;
  final Function onUnselectImage;
  XFile? image;
  bool isStore = true;

  ImageInput(
      this.onSelectImage, this.onUnselectImage, this.image, this.isStore);

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

  Future<void> _takePicture() async {
    final imageFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (imageFile == null) {
      return;
    }
    setState(() {
      _storedImage = imageFile;
    });
    imagePath = imageFile.path;

    widget.onSelectImage(imageFile);
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
    final deviceSize = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: deviceSize.width * 0.4,
          height: deviceSize.height * 0.175,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: _storedImage != null
              ? Image.file(File(imagePath!))
              : Image(
                  image: widget.isStore
                      ? AssetImage('assets/images/default-store.png')
                      : AssetImage('assets/images/default_product.png')),
          alignment: Alignment.center,
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          children: [
            FlatButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Take a Picture'),
              textColor: Theme.of(context).primaryColor,
              onPressed: _takePicture,
            ),
            FlatButton.icon(
              icon: Icon(Icons.image),
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
