import 'package:final_project_yroz/providers/physical_store.dart';
import 'package:final_project_yroz/providers/stores.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class OpenPhysicalStoreScreen extends StatefulWidget {
  static const routeName = '/open-physical-store';

  @override
  _OpenPhysicalStoreScreenState createState() =>
      _OpenPhysicalStoreScreenState();
}

class _OpenPhysicalStoreScreenState extends State<OpenPhysicalStoreScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  XFile? _pickedImage;
  PhysicalStore? _editedStore = PhysicalStore(
      id: "",
      name: "",
      phoneNumber: "",
      address: "",
      categories: ["Sport"],
      operationHours: {},
      qrCode: "",
      image: null);
  var _initValues = {
    'name': '',
    'phoneNumber': '',
    'address': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final storeId = ModalRoute.of(context)!.settings.arguments as String?;
      if (storeId != null) {
        _editedStore = Provider.of<Stores>(context, listen: false)
            .findPhysicalStoreById(storeId);
        if (_editedStore != null) {
          _initValues = {
            'name': _editedStore!.name,
            'phoneNumber': _editedStore!.phoneNumber,
            'address': _editedStore!.address,
          };
          _imageUrlController.text = _editedStore!.image.toString();
        }
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
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
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedStore!.id != null) {
      await Provider.of<Stores>(context, listen: false)
          .updatePhysicalStore(_editedStore.id, _editedStore);
    } else {
      try {
        await Provider.of<Stores>(context, listen: false)
            .addPhysicalStore(_editedStore);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text(error.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Open Store',
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
                    TextFormField(
                      initialValue: _initValues['name'],
                      decoration: InputDecoration(labelText: 'Store Name'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value.';
                        }
                        if (value.length < 8) {
                          return 'Should be at least 8 characters long.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedStore = PhysicalStore(
                            name: value,
                            phoneNumber: _editedStore.phoneNumber,
                            address: _editedStore.address,
                            categories: _editedStore.categories,
                            operationHours: _editedStore.operationHours,
                            qrCode: _editedStore.qrCode,
                            image: _editedStore.image);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['phoneNumber'],
                      decoration: InputDecoration(labelText: 'phoneNumber'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a phone Number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedStore = PhysicalStore(
                            name: _editedStore.name,
                            phoneNumber: value,
                            address: _editedStore.address,
                            categories: _editedStore.categories,
                            operationHours: _editedStore.operationHours,
                            qrCode: _editedStore.qrCode,
                            image: _editedStore.image);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['address'],
                      decoration: InputDecoration(labelText: 'Address'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter an address.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedStore = PhysicalStore(
                            name: _editedStore.name,
                            phoneNumber: _editedStore.phoneNumber,
                            address: value,
                            categories: _editedStore.categories,
                            operationHours: _editedStore.operationHours,
                            qrCode: _editedStore.qrCode,
                            image: _editedStore.image);
                      },
                    ),
                    _pickedImage == null
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                width: 100,
                                height: 100,
                                margin: EdgeInsets.only(
                                  top: 8,
                                  right: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                                child: _imageUrlController.text.isEmpty
                                    ? Text('Enter a URL')
                                    : FittedBox(
                                        child: Image.network(
                                          _imageUrlController.text,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  decoration:
                                      InputDecoration(labelText: 'Image URL'),
                                  keyboardType: TextInputType.url,
                                  textInputAction: TextInputAction.done,
                                  controller: _imageUrlController,
                                  focusNode: _imageUrlFocusNode,
                                  onFieldSubmitted: (_) {
                                    _saveForm();
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter an image URL.';
                                    }
                                    if (!value.startsWith('http') &&
                                        !value.startsWith('https')) {
                                      return 'Please enter a valid URL.';
                                    }
                                    if (!value.endsWith('.png') &&
                                        !value.endsWith('.jpg') &&
                                        !value.endsWith('.jpeg')) {
                                      return 'Please enter a valid image URL.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _editedStore = PhysicalStore(
                                        name: _editedStore.name,
                                        phoneNumber: _editedStore.phoneNumber,
                                        address: _editedStore.address,
                                        categories: _editedStore.categories,
                                        operationHours:
                                            _editedStore.operationHours,
                                        qrCode: _editedStore.qrCode,
                                        image: value);
                                  },
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(height: 1.0),
                    ImageInput(_selectImage, _unselectImage),
                    const SizedBox(height: 50.0),
                  ],
                ),
              ),
            ),
    );
  }
}
