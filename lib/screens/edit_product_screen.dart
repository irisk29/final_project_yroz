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
    imageFromPhone: null
  );

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
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop(_editedProduct);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Product',
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
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    ImageInput(_selectImage, _unselectImage, _pickedImage, false),
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
                            imageFromPhone: _pickedImage == null ? null : File(_pickedImage!.path));
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
                            imageFromPhone: _pickedImage == null ? null : File(_pickedImage!.path));
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
                        if (value.length < 10) {
                          return 'Should be at least 10 characters long.';
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
                          imageFromPhone: _pickedImage == null ? null : File(_pickedImage!.path)
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
