import 'package:address_search_field/address_search_field.dart';
import 'package:final_project_yroz/providers/physical_store.dart';
import 'package:final_project_yroz/providers/stores.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:final_project_yroz/widgets/multi_select.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../dummy_data.dart';

class OpenPhysicalStorePipeline extends StatefulWidget {
  static const routeName = '/open-physical-store';
  static List<String> _selectedItems = [];
  static TimeOfDay _sunday_open = TimeOfDay(hour: 7, minute: 0);
  static TimeOfDay _sunday_close = TimeOfDay(hour: 23, minute: 59);
  static TimeOfDay _monday_open = TimeOfDay(hour: 7, minute: 0);
  static TimeOfDay _monday_close = TimeOfDay(hour: 23, minute: 59);
  static TimeOfDay _tuesday_open = TimeOfDay(hour: 7, minute: 0);
  static TimeOfDay _tuesday_close = TimeOfDay(hour: 23, minute: 59);
  static TimeOfDay _wednesday_open = TimeOfDay(hour: 7, minute: 0);
  static TimeOfDay _wednesday_close = TimeOfDay(hour: 23, minute: 59);
  static TimeOfDay _thursday_open = TimeOfDay(hour: 7, minute: 0);
  static TimeOfDay _thursday_close = TimeOfDay(hour: 23, minute: 59);
  static TimeOfDay _friday_open = TimeOfDay(hour: 7, minute: 0);
  static TimeOfDay _friday_close = TimeOfDay(hour: 23, minute: 59);
  static TimeOfDay _saturday_open = TimeOfDay(hour: 7, minute: 0);
  static TimeOfDay _saturday_close = TimeOfDay(hour: 23, minute: 59);
  static TextEditingController _controller = TextEditingController();

  @override
  _OpenPhysicalStorePipelineState createState() =>
      _OpenPhysicalStorePipelineState();
}

class _OpenPhysicalStorePipelineState extends State<OpenPhysicalStorePipeline> {
  int _currentStep = 0;

  final destCtrl = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _detailsform = GlobalKey<FormState>();

  AddressSearchBuilder destinationBuilder = AddressSearchBuilder.deft(
      geoMethods: GeoMethods(
        googleApiKey: 'AIzaSyAfdPcHbriyq8QOw4hoCMz8sFp3dt8oqHg',
        language: 'en',
        countryCode: 'il',
      ),
      controller: OpenPhysicalStorePipeline._controller,
      builder: AddressDialogBuilder(),
      onDone: (Address address) => address);
  XFile? _pickedImage;
  PhysicalStore? _editedStore = PhysicalStore(
      id: "",
      name: "",
      phoneNumber: "",
      address: "",
      categories: OpenPhysicalStorePipeline._selectedItems,
      operationHours: {
        'sunday': [
          OpenPhysicalStorePipeline._sunday_open,
          OpenPhysicalStorePipeline._sunday_close
        ],
        'monday': [
          OpenPhysicalStorePipeline._monday_open,
          OpenPhysicalStorePipeline._monday_close
        ],
        'tuesday': [
          OpenPhysicalStorePipeline._tuesday_open,
          OpenPhysicalStorePipeline._tuesday_close
        ],
        'wednesday': [
          OpenPhysicalStorePipeline._wednesday_open,
          OpenPhysicalStorePipeline._wednesday_close
        ],
        'thursday': [
          OpenPhysicalStorePipeline._thursday_open,
          OpenPhysicalStorePipeline._thursday_close
        ],
        'friday': [
          OpenPhysicalStorePipeline._friday_open,
          OpenPhysicalStorePipeline._friday_close
        ],
        'saturday': [
          OpenPhysicalStorePipeline._saturday_open,
          OpenPhysicalStorePipeline._saturday_close
        ]
      },
      qrCode: "",
      image: null);
  var _initValues = {
    'name': '',
    'phoneNumber': '',
    'address': '',
  };
  final List<String> _selectedItems = [];
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

  // This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
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
        OpenPhysicalStorePipeline._selectedItems = results;
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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: Stepper(
                type: StepperType.horizontal,
                physics: ScrollPhysics(),
                currentStep: _currentStep,
                onStepTapped: (step) => tapped(step),
                onStepContinue: continued,
                onStepCancel: cancel,
                steps: <Step>[
                  Step(
                    title: new Text('Store Details'),
                    content: Form(
                      key: _detailsform,
                      child: Column(
                        children: <Widget>[
                          const Text(
                            'Enter Store Details',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextFormField(
                            controller: _nameController,
                            decoration:
                                InputDecoration(labelText: 'Store Name'),
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
                            decoration:
                                InputDecoration(labelText: 'phoneNumber'),
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
                            controller: OpenPhysicalStorePipeline._controller,
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
                        ],
                      ),
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep >= 0
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                  Step(
                    title: new Text('Categories'),
                    content: Column(
                      children: [
                        const Text(
                          'Select Store Categories',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        SingleChildScrollView(
                          child: ListBody(
                            children: DUMMY_CATEGORIES
                                .map((e) => e.title)
                                .toList()
                                .map((item) => CheckboxListTile(
                                      value: _selectedItems.contains(item),
                                      title: Text(item),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      onChanged: (isChecked) =>
                                          _itemChange(item, isChecked!),
                                    ))
                                .toList(),
                          ),
                        ),
                        Wrap(
                          children: _selectedItems
                              .map((e) => Chip(
                                    deleteIcon: Icon(
                                      Icons.close,
                                    ),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedItems.remove(e);
                                      });
                                    },
                                    label: Text(e),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep >= 1
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                  Step(
                    title: new Text('Opening Hours'),
                    content: Column(
                      children: [
                        const Text(
                          'Select Store Opening Hours',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sunday'),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _selectTime('sunday[0]');
                                  },
                                  child: Text(_editedStore!
                                      .operationHours['sunday']![0]
                                      .format(context)),
                                ),
                                Text('-'),
                                ElevatedButton(
                                  onPressed: () {
                                    _selectTime('sunday[1]');
                                  },
                                  child: Text(_editedStore!
                                      .operationHours['sunday']![1]
                                      .format(context)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Monday'),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _selectTime('monday[0]'),
                                  child: Text(_editedStore!
                                      .operationHours['monday']![0]
                                      .format(context)),
                                ),
                                Text('-'),
                                ElevatedButton(
                                  onPressed: () => _selectTime('monday[1]'),
                                  child: Text(_editedStore!
                                      .operationHours['monday']![1]
                                      .format(context)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tuesday'),
                            Row(
                              children: [
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
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Wednesday'),
                            Row(
                              children: [
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
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Thursday'),
                            Row(
                              children: [
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
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Friday'),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _selectTime('friday[0]');
                                  },
                                  child: Text(_editedStore!
                                      .operationHours['friday']![0]
                                      .format(context)),
                                ),
                                Text('-'),
                                ElevatedButton(
                                  onPressed: () {
                                    _selectTime('friday[1]');
                                  },
                                  child: Text(_editedStore!
                                      .operationHours['friday']![1]
                                      .format(context)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Saturday'),
                            Row(
                              children: [
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
                          ],
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep >= 2
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                ],
              ),
            ),
    );
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    switch (_currentStep) {
      case 0:
        if (_detailsform.currentState!.validate()) {
          _detailsform.currentState!.save();
          _currentStep < 3 ? setState(() => _currentStep += 1) : null;
        }
        break;
      case 1:
        if (_selectedItems.isNotEmpty) {
          _currentStep < 3 ? setState(() => _currentStep += 1) : null;
        }
        break;
      case 2:
        _currentStep < 3 ? setState(() => _currentStep += 1) : null;
        break;
      case 3:
        _saveForm();
        break;
    }
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }
}
