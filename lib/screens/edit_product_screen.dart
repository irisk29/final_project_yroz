import 'dart:io';

import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuple/tuple.dart';

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

  ProductDTO? _editedProduct;

  XFile? _pickedImage;
  String? _imageUrl;

  var _isInit = true;
  var _isLoading = false;
  var _formChanged;

  @override
  void initState() {
    _formChanged = false;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _editedProduct = widget.product;
      _pickedImage = _editedProduct!.imageFromPhone != null
          ? XFile(_editedProduct!.imageFromPhone!.path)
          : null;
      _imageUrl = _editedProduct!.imageUrl;
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
    _imageUrl = null;
    _formChanged = true;
    setState(() {});
  }

  void _unselectImage() {
    _pickedImage = null;
    _imageUrl = null;
    _formChanged = true;
    setState(() {});
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
      _editedProduct!.imageUrl = _imageUrl;
      Navigator.of(context).pop(Tuple2(_editedProduct, false));
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _exitWithoutSavingDialog() {
    if (_formChanged) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Are your sure?'),
          content: Text("You are about to exit without saving your changes."),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: _isLoading
                ? Container()
                : IconButton(
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
                  Navigator.of(context).pop(Tuple2(_editedProduct, true));
                },
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
                        ImageInput(_selectImage, _unselectImage, _imageUrl,
                            _pickedImage, false),
                        TextFormField(
                          initialValue: _editedProduct!.name,
                          decoration: InputDecoration(labelText: 'Title'),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a value.';
                            }
                            if (double.tryParse(value) != null) {
                              return 'Product name can not be a number';
                            }
                            if (value.length > 40) {
                              return 'Can be max 40 characters long.';
                            }
                            return null;
                          },
                          onChanged: (_) => _formChanged = true,
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
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
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
                            if (double.parse(value).toStringAsFixed(2).length >
                                9) {
                              return 'Price too large, please enter a smaller price.';
                            }
                            return null;
                          },
                          onChanged: (_) => _formChanged = true,
                          onSaved: (value) {
                            _editedProduct = ProductDTO(
                                name: _editedProduct!.name,
                                price: double.parse(
                                    double.parse(value!).toStringAsFixed(2)),
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
                            if (value.length > 60) {
                              return 'Can be max 60 characters long.';
                            }
                            return null;
                          },
                          onChanged: (_) => _formChanged = true,
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
          bottomSheet: Container(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key("save"),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  primary: Theme.of(context).primaryColor),
              child: Container(
                width: deviceSize.width * 0.3,
                margin: const EdgeInsets.all(12),
                child: const Text(
                  'Save',
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: _saveForm,
            ),
          ),
        ),
      ),
    );
  }
}
