import 'dart:io';

import 'package:address_search_field/address_search_field.dart';
import 'package:final_project_yroz/DTOs/BankAccountDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:final_project_yroz/widgets/image_input.dart';
import 'package:final_project_yroz/widgets/store_preview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:im_stepper/stepper.dart';

import '../dummy_data.dart';

class OpenPhysicalStorePipeline extends StatefulWidget {
  static const routeName = '/open-physical-store';

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

  //User? user;

  @override
  _OpenPhysicalStorePipelineState createState() =>
      _OpenPhysicalStorePipelineState();
}

class _OpenPhysicalStorePipelineState extends State<OpenPhysicalStorePipeline> {
  int _currentStep = 0;

  final destCtrl = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
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
  XFile? _pickedImage = null;
  StoreDTO? _editedStore = StoreDTO(
      id: "",
      name: "",
      phoneNumber: "",
      address: "",
      categories: [],
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
      image: null,
      imageFromPhone: null);

  final List<String> _selectedItems = [];

  String? accountNumber;
  String? bankName;
  String? branchNumber;
  OutlineInputBorder? border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final _bankAccountForm = GlobalKey<FormState>();

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // final user = ModalRoute.of(context)!.settings.arguments as User?;
      // widget.user = user;
    }
    _isInit = false;
    super.didChangeDependencies();
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
    _editedStore!.categories = _selectedItems;
    try {
      await Provider.of<User>(context, listen: false)
          .openPhysicalStore(_editedStore!, new BankAccountDTO(this.bankName!, this.branchNumber!, this.accountNumber!));
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

  Widget? currentStepWidget() {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            const Text(
              'Enter Store Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _detailsform,
                child: Column(
                  children: <Widget>[
                    ImageInput(
                        _selectImage, _unselectImage, _pickedImage, true),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Store Name'),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        if (value.length < 2) {
                          return 'Should be at least 2 characters long.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedStore = StoreDTO(
                            name: value!,
                            phoneNumber: _editedStore!.phoneNumber,
                            address: _editedStore!.address,
                            categories: _editedStore!.categories,
                            operationHours: _editedStore!.operationHours,
                            qrCode: _editedStore!.qrCode,
                            image: _editedStore!.image,
                            id: '',
                            imageFromPhone: _pickedImage == null
                                ? null
                                : File(_pickedImage!.path));
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
                        _editedStore = StoreDTO(
                            name: _editedStore!.name,
                            phoneNumber: value!,
                            address: _editedStore!.address,
                            categories: _editedStore!.categories,
                            operationHours: _editedStore!.operationHours,
                            qrCode: _editedStore!.qrCode,
                            image: _editedStore!.image,
                            id: '',
                            imageFromPhone: _pickedImage == null
                                ? null
                                : File(_pickedImage!.path));
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Address'),
                      controller: OpenPhysicalStorePipeline._controller,
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => destinationBuilder),
                      onSaved: (value) {
                        _editedStore = StoreDTO(
                            name: _editedStore!.name,
                            phoneNumber: _editedStore!.phoneNumber,
                            address: value!,
                            categories: _editedStore!.categories,
                            operationHours: _editedStore!.operationHours,
                            qrCode: _editedStore!.qrCode,
                            image: _editedStore!.image,
                            id: '',
                            imageFromPhone: _pickedImage == null
                                ? null
                                : File(_pickedImage!.path));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            const Text(
              'Select Store Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          controlAffinity: ListTileControlAffinity.leading,
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
        );
      case 2:
        return Column(
          children: [
            const Text(
              'Select Store Opening Hours',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
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
            ),
          ],
        );
      case 3:
        return Column(
          children: <Widget>[
            const Text(
              "Store's Bank Account Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Form(
                  key: _bankAccountForm,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                          initialValue: "",
                          decoration: InputDecoration(
                            labelText: 'BANK NAME',
                            hintStyle: const TextStyle(color: Colors.black),
                            labelStyle: const TextStyle(color: Colors.black),
                            focusedBorder: border,
                            enabledBorder: border,
                          ),
                          onSaved: (value) {
                            bankName = value;
                          }),
                      TextFormField(
                        initialValue: "",
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Colors.black),
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: border,
                          enabledBorder: border,
                          labelText: 'BRANCH NUMBER',
                          hintText: 'XXX',
                        ),
                        validator: (value) {
                          if (value == null || value.length != 3) {
                            return "Invalid Branch Number";
                          }
                          return null;
                        },
                        onSaved: (value) => branchNumber = value,
                      ),
                      TextFormField(
                        initialValue: "",
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Colors.black),
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: border,
                          enabledBorder: border,
                          labelText: 'ACCOUNT NUMBER',
                          hintText: 'XXXXXXXXX',
                        ),
                        validator: (value) {
                          if (value == null || value.length != 9) {
                            return "Invalid Account Number";
                          }
                          return null;
                        },
                        onSaved: (value) => accountNumber = value,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      case 4:
        return StorePreview(
            false,
            _editedStore!.name,
            _editedStore!.address,
            _pickedImage,
            _editedStore!.phoneNumber,
            _editedStore!.operationHours);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Open Physical Store',
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: Column(
                children: [
                  IconStepper(
                    icons: [
                      Icon(Icons.info),
                      Icon(Icons.tag),
                      Icon(Icons.access_time),
                      Icon(Icons.account_balance_wallet_outlined),
                      Icon(Icons.store),
                    ],
                    // activeStep property set to activeStep variable defined above.
                    activeStep: _currentStep,
                    steppingEnabled: false,
                    enableStepTapping: false,
                    enableNextPreviousButtons: false,
                    activeStepColor: Theme.of(context).primaryColor,
                    // This ensures step-tapping updates the activeStep.
                    onStepReached: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                  ),
                  currentStepWidget()!,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: cancel,
                              child: Text('Prev'),
                            ),
                            ElevatedButton(
                              onPressed: continued,
                              child: Text('Next'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  continued() {
    switch (_currentStep) {
      case 0:
        if (_detailsform.currentState!.validate()) {
          _detailsform.currentState!.save();
          setState(() => _currentStep += 1);
        }
        break;
      case 1:
        if (_selectedItems.isNotEmpty) {
          setState(() => _currentStep += 1);
        }
        break;
      case 2:
        setState(() => _currentStep += 1);
        break;
      case 3:
        if (_bankAccountForm.currentState!.validate()) {
          _bankAccountForm.currentState!.save();
          setState(() => _currentStep += 1);
        }
        break;
      case 4:
        _saveForm();
        break;
    }
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }
}
