import 'package:address_search_field/address_search_field.dart';
import 'package:final_project_yroz/providers/physical_store.dart';
import 'package:final_project_yroz/providers/stores.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:final_project_yroz/widgets/image_input.dart';
import 'package:final_project_yroz/widgets/multi_select.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../dummy_data.dart';

class OpenPhysicalStoreScreen extends StatefulWidget {
  static const routeName = '/open-physical-store';
  static List<String> _selectedItems = [];
  static TimeOfDay _sunday_open = TimeOfDay(hour: 7, minute: 15);
  static TimeOfDay _sunday_close = TimeOfDay(hour: 7, minute: 15);
  static TimeOfDay _monday_open = TimeOfDay(hour: 7, minute: 15);
  static TimeOfDay _monday_close = TimeOfDay(hour: 7, minute: 15);
  static TimeOfDay _tuesday_open = TimeOfDay(hour: 7, minute: 15);
  static TimeOfDay _tuesday_close = TimeOfDay(hour: 7, minute: 15);
  static TimeOfDay _wednesday_open = TimeOfDay(hour: 7, minute: 15);
  static TimeOfDay _wednesday_close = TimeOfDay(hour: 7, minute: 15);
  static TimeOfDay _thursday_open = TimeOfDay(hour: 7, minute: 15);
  static TimeOfDay _thursday_close = TimeOfDay(hour: 7, minute: 15);
  static TimeOfDay _friday_open = TimeOfDay(hour: 7, minute: 15);
  static TimeOfDay _friday_close = TimeOfDay(hour: 7, minute: 15);
  static TimeOfDay _saturday_open = TimeOfDay(hour: 7, minute: 15);
  static TimeOfDay _saturday_close = TimeOfDay(hour: 7, minute: 15);
  static TextEditingController _controller = TextEditingController();

  @override
  _OpenPhysicalStoreScreenState createState() =>
      _OpenPhysicalStoreScreenState();
}

class _OpenPhysicalStoreScreenState extends State<OpenPhysicalStoreScreen> {
  final destCtrl = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  AddressSearchBuilder destinationBuilder = AddressSearchBuilder.deft(
      geoMethods: GeoMethods(
        googleApiKey: 'AIzaSyAfdPcHbriyq8QOw4hoCMz8sFp3dt8oqHg',
        language: 'en',
        countryCode: 'il',
      ),
      controller: OpenPhysicalStoreScreen._controller,
      builder: AddressDialogBuilder(),
      onDone: (Address address) => address);
  XFile? _pickedImage;
  PhysicalStore? _editedStore = PhysicalStore(
      id: "",
      name: "",
      phoneNumber: "",
      address: "",
      categories: OpenPhysicalStoreScreen._selectedItems,
      operationHours: {
        'sunday': [
          OpenPhysicalStoreScreen._sunday_open,
          OpenPhysicalStoreScreen._sunday_close
        ],
        'monday': [
          OpenPhysicalStoreScreen._monday_open,
          OpenPhysicalStoreScreen._monday_close
        ],
        'tuesday': [
          OpenPhysicalStoreScreen._tuesday_open,
          OpenPhysicalStoreScreen._tuesday_close
        ],
        'wednesday': [
          OpenPhysicalStoreScreen._wednesday_open,
          OpenPhysicalStoreScreen._wednesday_close
        ],
        'thursday': [
          OpenPhysicalStoreScreen._thursday_open,
          OpenPhysicalStoreScreen._thursday_close
        ],
        'friday': [
          OpenPhysicalStoreScreen._friday_open,
          OpenPhysicalStoreScreen._friday_close
        ],
        'saturday': [
          OpenPhysicalStoreScreen._saturday_open,
          OpenPhysicalStoreScreen._saturday_close
        ]
      },
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
    if (_editedStore!.id.isNotEmpty) {
      await Provider.of<Stores>(context, listen: false)
          .updatePhysicalStore(_editedStore!.id, _editedStore!);
    } else {
      try {
        await Provider.of<Stores>(context, listen: false)
            .addPhysicalStore(_editedStore!);
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

  void _showMultiSelect() async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API
    final List<String> _items = DUMMY_CATEGORIES.map((e) => e.title).toList();

    final List<String> results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: _items);
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        OpenPhysicalStoreScreen._selectedItems = results;
        _editedStore = PhysicalStore(
            name: _editedStore!.name,
            phoneNumber: _editedStore!.phoneNumber,
            address: _editedStore!.address,
            categories: results,
            operationHours: _editedStore!.operationHours,
            qrCode: _editedStore!.qrCode,
            image: _editedStore!.image,
            id: '');
      });
    }
  }

  void _selectTime(String time) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _editedStore!
              .operationHours[time.substring(0, time.indexOf('['))]![
          int.parse(time.substring(time.indexOf('[') + 1, time.indexOf(']')))],
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (newTime != null) {
      setState(() {
        _editedStore!.operationHours[time.substring(0, time.indexOf('['))]![
                int.parse(
                    time.substring(time.indexOf('[') + 1, time.indexOf(']')))] =
            newTime;
      });
    }
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
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Store Name'),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        if (value.length < 8) {
                          return 'Should be at least 8 characters long.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedStore = PhysicalStore(
                            name: value!,
                            phoneNumber: _editedStore!.phoneNumber,
                            address: _editedStore!.address,
                            categories: _editedStore!.categories,
                            operationHours: _editedStore!.operationHours,
                            qrCode: _editedStore!.qrCode,
                            image: _editedStore!.image,
                            id: '');
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'phoneNumber'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      controller: _phoneNumberController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a phone Number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedStore = PhysicalStore(
                            name: _editedStore!.name,
                            phoneNumber: value!,
                            address: _editedStore!.address,
                            categories: _editedStore!.categories,
                            operationHours: _editedStore!.operationHours,
                            qrCode: _editedStore!.qrCode,
                            image: _editedStore!.image,
                            id: '');
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Address'),
                      controller: OpenPhysicalStoreScreen._controller,
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => destinationBuilder),
                      onSaved: (value) {
                        _editedStore = PhysicalStore(
                            name: _editedStore!.name,
                            phoneNumber: _editedStore!.phoneNumber,
                            address: value!,
                            categories: _editedStore!.categories,
                            operationHours: _editedStore!.operationHours,
                            qrCode: _editedStore!.qrCode,
                            image: _editedStore!.image,
                            id: '');
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Select Categories'),
                      onPressed: _showMultiSelect,
                    ),
                    Wrap(
                      children: OpenPhysicalStoreScreen._selectedItems
                          .map((e) => Chip(
                                deleteIcon: Icon(
                                  Icons.close,
                                ),
                                onDeleted: () {
                                  setState(() {
                                    OpenPhysicalStoreScreen._selectedItems
                                        .remove(e);
                                  });
                                },
                                label: Text(e),
                              ))
                          .toList(),
                    ),
                    Text('Opening hours:'),
                    Row(
                      children: [
                        Text('Sunday'),
                        ElevatedButton(
                          onPressed: () {
                            _selectTime('sunday[0]');
                          },
                          child: Text(_editedStore!.operationHours['sunday']![0]
                              .format(context)),
                        ),
                        Text('-'),
                        ElevatedButton(
                          onPressed: () {
                            _selectTime('sunday[1]');
                          },
                          child: Text(_editedStore!.operationHours['sunday']![1]
                              .format(context)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Monday'),
                        ElevatedButton(
                          onPressed: () => _selectTime('monday[0]'),
                          child: Text(_editedStore!.operationHours['monday']![0]
                              .format(context)),
                        ),
                        Text('-'),
                        ElevatedButton(
                          onPressed: () => _selectTime('monday[1]'),
                          child: Text(_editedStore!.operationHours['monday']![1]
                              .format(context)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Tuesday'),
                        ElevatedButton(
                          onPressed: () {
                            _selectTime('tuesday[0]');
                          },
                          child: Text(_editedStore!
                              .operationHours['tuesday']![0]
                              .format(context)),
                        ),
                        Text('-'),
                        ElevatedButton(
                          onPressed: () {
                            _selectTime('tuesday[1]');
                          },
                          child: Text(_editedStore!
                              .operationHours['tuesday']![1]
                              .format(context)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Wednesday'),
                        ElevatedButton(
                          onPressed: () {
                            _selectTime('wednesday[0]');
                          },
                          child: Text(_editedStore!
                              .operationHours['wednesday']![0]
                              .format(context)),
                        ),
                        Text('-'),
                        ElevatedButton(
                          onPressed: () {
                            _selectTime('wednesday[1]');
                          },
                          child: Text(_editedStore!
                              .operationHours['wednesday']![1]
                              .format(context)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Thursday'),
                        ElevatedButton(
                          onPressed: () {
                            _selectTime('thursday[1]');
                          },
                          child: Text(_editedStore!
                              .operationHours['thursday']![0]
                              .format(context)),
                        ),
                        Text('-'),
                        ElevatedButton(
                          onPressed: () {
                            _selectTime('thursday[1]');
                          },
                          child: Text(_editedStore!
                              .operationHours['thursday']![1]
                              .format(context)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Friday'),
                        ElevatedButton(
                          onPressed: () {
                            _selectTime('friday[0]');
                          },
                          child: Text(_editedStore!.operationHours['friday']![0]
                              .format(context)),
                        ),
                        Text('-'),
                        ElevatedButton(
                          onPressed: () {
                            _selectTime('friday[1]');
                          },
                          child: Text(_editedStore!.operationHours['friday']![1]
                              .format(context)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Saturday'),
                        ElevatedButton(
                          onPressed: () {
                            _selectTime('saturday[0]');
                          },
                          child: Text(_editedStore!
                              .operationHours['saturday']![0]
                              .format(context)),
                        ),
                        Text('-'),
                        ElevatedButton(
                          onPressed: () {
                            _selectTime('saturday[1]');
                          },
                          child: Text(_editedStore!
                              .operationHours['saturday']![1]
                              .format(context)),
                        ),
                      ],
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
                                  validator: (value) {
                                    if (value!.isEmpty) {
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
                                        name: _editedStore!.name,
                                        phoneNumber: _editedStore!.phoneNumber,
                                        address: _editedStore!.address,
                                        categories: _editedStore!.categories,
                                        operationHours:
                                            _editedStore!.operationHours,
                                        qrCode: _editedStore!.qrCode,
                                        image: value,
                                        id: '');
                                  },
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(height: 1.0),
                    ImageInput(_selectImage, _unselectImage, _pickedImage),
                    const SizedBox(height: 50.0),
                  ],
                ),
              ),
            ),
    );
  }
}
