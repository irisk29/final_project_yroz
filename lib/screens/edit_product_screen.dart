import 'dart:io';

import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  ProductDTO? product;

  EditProductScreen(this.product);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  XFile? _pickedImage = null;

  ProductDTO? _editedProduct = ProductDTO(
      id: '',
      name: '',
      price: 0,
      description: '',
      imageUrl: '',
      category: '',
      storeID: '',
      imageFromPhone: null);

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _editedProduct = widget.product;
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _selectImage(XFile pickedImage) {
    _pickedImage = pickedImage;
    setState(() {});
  }

  void _unselectImage() {
    _pickedImage = null;
    setState(() {});
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
      Navigator.of(context).pop(_editedProduct);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    void _exitWithoutSavingDialog() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Are your sure?'),
          content: Text("You are about to exit without saving your changes."),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(ctx).pop();
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _exitWithoutSavingDialog(),
        ),
        toolbarHeight: deviceSize.height * 0.1,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Edit Product',
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.delete,
            ),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(deviceSize.width * 0.03),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    ImageInput(
                        _selectImage, _unselectImage, _pickedImage, false),
                    TextFormField(
                      initialValue: _editedProduct!.name,
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = ProductDTO(
                            name: value!,
                            price: _editedProduct!.price,
                            description: _editedProduct!.description,
                            imageUrl: _editedProduct!.imageUrl,
                            id: _editedProduct!.id,
                            category: '',
                            storeID: '',
                            imageFromPhone: _pickedImage == null
                                ? null
                                : File(_pickedImage!.path));
                      },
                    ),
                    TextFormField(
                      initialValue: _editedProduct!.price.toString(),
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a price.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than zero.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = ProductDTO(
                            name: _editedProduct!.name,
                            price: double.parse(value!),
                            description: _editedProduct!.description,
                            imageUrl: _editedProduct!.imageUrl,
                            id: _editedProduct!.id,
                            category: '',
                            storeID: '',
                            imageFromPhone: _pickedImage == null
                                ? null
                                : File(_pickedImage!.path));
                      },
                    ),
                    TextFormField(
                      initialValue: _editedProduct!.description,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a description.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = ProductDTO(
                            name: _editedProduct!.name,
                            price: _editedProduct!.price,
                            description: value!,
                            imageUrl: _editedProduct!.imageUrl,
                            id: _editedProduct!.id,
                            category: '',
                            storeID: '',
                            imageFromPhone: _pickedImage == null
                                ? null
                                : File(_pickedImage!.path));
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
