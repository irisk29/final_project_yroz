import 'dart:io';

import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:final_project_yroz/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../LogicLayer/User.dart';
import 'open_online_store_screen.dart';

class AddProductScreen extends StatefulWidget {
  static const routeName = '/add-product';

  OnlineStoreDTO? _editedStore;

  AddProductScreen(OnlineStoreDTO? editedStore) {
    this._editedStore = editedStore;
  }

  @override
  _AddProductScreenState createState() => _AddProductScreenState();

  //for test purposes
  Widget wrapWithMaterial(List<NavigatorObserver> nav) => MaterialApp(
    routes: {
      TabsScreen.routeName: (ctx) => TabsScreen().wrapWithMaterial(nav),
      OpenOnlineStorePipeline.routeName: (ctx) => OpenOnlineStorePipeline().wrapWithMaterial(nav),
    },
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: User("test@gmail.com", "test name"),
        ),
      ],
      child: Scaffold(
        body: this,
      ),
    ),
    // This mocked observer will now receive all navigation events
    // that happen in our app.
    navigatorObservers: nav,
  );
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
    setState(() {
      _isLoading = true;
    });

    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
      Navigator.of(context).pop(Tuple2<ProductDTO?, OnlineStoreDTO?>(
          _editedProduct, widget._editedStore));
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _selectImage(XFile pickedImage) {
    _pickedImage = pickedImage;
    setState(() {});
  }

  void _unselectImage() {
    _pickedImage = null;
    setState(() {});
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _exitWithoutSavingDialog(),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Add Product',
          ),
        ),
        actions: <Widget>[
          IconButton(
            key: const Key('save'),
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
                key: const Key('title'),
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
                key: const Key('price'),
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
                key: const Key('description'),
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
