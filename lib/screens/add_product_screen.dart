import 'dart:io';

import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuple/tuple.dart';

class AddProductScreen extends StatefulWidget {
  static const routeName = '/add-product';

  OnlineStoreDTO? _editedStore;

  AddProductScreen(OnlineStoreDTO? editedStore) {
    this._editedStore = editedStore;
  }

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
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
      // final productId = ModalRoute.of(context)!.settings.arguments as String?;
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
    Navigator.of(context).pop(Tuple2<ProductDTO?, OnlineStoreDTO?>(_editedProduct, widget._editedStore));
  }

  void _selectImage(XFile pickedImage) {
    _pickedImage = pickedImage;
    setState(() {});
  }

  void _unselectImage() {
    _pickedImage = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Product',
        ),
        actions: <Widget>[
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
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                textInputAction: TextInputAction.done,
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
