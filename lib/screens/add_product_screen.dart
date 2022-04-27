import 'dart:io';

import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:final_project_yroz/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../LogicLayer/User.dart';
import 'open_online_store_screen.dart';

class AddProductScreen extends StatefulWidget {
  static const routeName = '/add-product';

  @override
  _AddProductScreenState createState() => _AddProductScreenState();

  //for test purposes
  Widget wrapWithMaterial(List<NavigatorObserver> nav) => MaterialApp(
        routes: {
          TabsScreen.routeName: (ctx) => TabsScreen().wrapWithMaterial(nav),
          OpenOnlineStorePipeline.routeName: (ctx) =>
              OpenOnlineStorePipeline().wrapWithMaterial(nav),
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

  ProductDTO? _editedProduct = ProductDTO(
      id: '',
      name: '',
      price: 0,
      description: '',
      imageUrl: null,
      category: '',
      storeID: '',
      imageFromPhone: null);
  XFile? _pickedImage = null;

  var _isLoading = false;
  var _formChanged;

  @override
  void initState() {
    _formChanged = false;
    super.initState();
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
      Navigator.of(context).pop(_editedProduct);
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

    return GestureDetector(
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
              'Add Product',
              style: const TextStyle(fontSize: 22),
            ),
          ),
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
                      ImageInput(_selectImage, _unselectImage, null,
                          _pickedImage, false),
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
                          if (double.tryParse(value) != null) {
                            return 'Product name can not be a number';
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
                        key: const Key('price'),
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        maxLength: 10,
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
                          return null;
                        },
                        onChanged: (_) => _formChanged = true,
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
    );
  }
}
