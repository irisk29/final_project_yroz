import 'dart:io';

import 'package:address_search_field/address_search_field.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/tutorial_screen.dart';
import 'package:final_project_yroz/widgets/bank_account_form.dart';
import 'package:final_project_yroz/widgets/image_input.dart';
import 'package:final_project_yroz/widgets/store_preview.dart';
import 'package:final_project_yroz/widgets/terms.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:im_stepper/stepper.dart';
import 'package:tuple/tuple.dart';

import '../LogicLayer/Secret.dart';
import '../LogicLayer/SecretLoader.dart';
import '../dummy_data.dart';
import 'add_product_screen.dart';
import 'tabs_screen.dart';

class OpenOnlineStorePipeline extends StatefulWidget {
  static const routeName = '/open-online-store';

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
  _OpenOnlineStorePipelineState createState() {
    return _OpenOnlineStorePipelineState();
  }

  //for test purposes
  Widget wrapWithMaterial(List<NavigatorObserver> nav) => MaterialApp(
        routes: {
          TabsScreen.routeName: (ctx) => TabsScreen().wrapWithMaterial(nav),
          TutorialScreen.routeName: (ctx) => TutorialScreen(),
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

class _OpenOnlineStorePipelineState extends State<OpenOnlineStorePipeline> {
  int _currentStep = 0;

  final destCtrl = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _detailsform = GlobalKey<FormState>();

  late AddressSearchBuilder destinationBuilder;

  XFile? _pickedImage = null;
  OnlineStoreDTO? _editedStore = OnlineStoreDTO(
      id: "",
      name: "",
      phoneNumber: "",
      address: "",
      categories: [],
      operationHours: {
        'sunday': [OpenOnlineStorePipeline._sunday_open, OpenOnlineStorePipeline._sunday_close],
        'monday': [OpenOnlineStorePipeline._monday_open, OpenOnlineStorePipeline._monday_close],
        'tuesday': [OpenOnlineStorePipeline._tuesday_open, OpenOnlineStorePipeline._tuesday_close],
        'wednesday': [OpenOnlineStorePipeline._wednesday_open, OpenOnlineStorePipeline._wednesday_close],
        'thursday': [OpenOnlineStorePipeline._thursday_open, OpenOnlineStorePipeline._thursday_close],
        'friday': [OpenOnlineStorePipeline._friday_open, OpenOnlineStorePipeline._friday_close],
        'saturday': [OpenOnlineStorePipeline._saturday_open, OpenOnlineStorePipeline._saturday_close]
      },
      image: null,
      products: [],
      imageFromPhone: null);

  final List<String> _selectedItems = [];
  final List<ProductDTO> _products = [];

  final bankAccountForm = BankAccountForm();

  late Secret secret;

  var _isInit = true;
  var _isLoading = false;
  var _acceptTerms = false;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      secret = await SecretLoader(secretPath: "assets/secrets.json").load();
      destinationBuilder = AddressSearchBuilder.deft(
          geoMethods: GeoMethods(
            googleApiKey: secret.API_KEY,
            language: 'en',
            countryCode: 'il',
          ),
          controller: OpenOnlineStorePipeline._controller,
          builder: AddressDialogBuilder(),
          onDone: (Address address) => address);
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
    _editedStore!.products = _products;
    try {
      await Provider.of<User>(context, listen: false)
          .openOnlineStore(_editedStore!, bankAccountForm.buildBankAccountDTO()!);
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
    Navigator.of(context).pushReplacementNamed(TutorialScreen.routeName);
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
      initialTime: _editedStore!.operationHours[time.substring(0, time.indexOf('['))]![
          int.parse(time.substring(time.indexOf('[') + 1, time.indexOf(']')))],
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (newTime != null) {
      setState(() {
        _editedStore!.operationHours[time.substring(0, time.indexOf('['))]![
            int.parse(time.substring(time.indexOf('[') + 1, time.indexOf(']')))] = newTime;
      });
    }
  }

  static const productsLimitation = 10;
  void _showAddProduct() async {
    if (_products.length < productsLimitation) {
      final Tuple2<ProductDTO?, OnlineStoreDTO?>? result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddProductScreen(_editedStore)),
      );
      if (result != null && result.item1 != null) {
        setState(() {
          _editedStore = result.item2;
          _products.add(result.item1!);
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            "Store's Products Limitation",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Text("We are Sorry, in this version store can contain up to ${productsLimitation} products only"),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Ok"),
            ),
          ],
        ),
      );
    }
  }

  Widget? currentStepWidget(Size deviceSize) {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            const Text(
              'Enter Store Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(height: 0),
            Padding(
              padding: EdgeInsets.all(deviceSize.width * 0.03),
              child: Form(
                key: _detailsform,
                child: Column(
                  children: <Widget>[
                    ImageInput(_selectImage, _unselectImage, _pickedImage, true),
                    TextFormField(
                      key: const Key('storeName'),
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
                      onChanged: (value) {
                        _editedStore = OnlineStoreDTO(
                            name: value,
                            phoneNumber: _editedStore!.phoneNumber,
                            address: _editedStore!.address,
                            categories: _editedStore!.categories,
                            operationHours: _editedStore!.operationHours,
                            image: _editedStore!.image,
                            id: '',
                            products: _editedStore!.products,
                            imageFromPhone: _pickedImage == null ? null : File(_pickedImage!.path));
                      },
                      onSaved: (value) {
                        _editedStore = OnlineStoreDTO(
                            name: value!,
                            phoneNumber: _editedStore!.phoneNumber,
                            address: _editedStore!.address,
                            categories: _editedStore!.categories,
                            operationHours: _editedStore!.operationHours,
                            image: _editedStore!.image,
                            id: '',
                            products: _editedStore!.products,
                            imageFromPhone: _pickedImage == null ? null : File(_pickedImage!.path));
                      },
                    ),
                    TextFormField(
                      key: const Key('phoneNumber'),
                      decoration: InputDecoration(labelText: 'phoneNumber'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      controller: _phoneNumberController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a phone Number.';
                        }
                        if (!value.startsWith('+') || value.length < 6) {
                          return 'invalid phone number.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _editedStore = OnlineStoreDTO(
                            name: _editedStore!.name,
                            phoneNumber: value,
                            address: _editedStore!.address,
                            categories: _editedStore!.categories,
                            operationHours: _editedStore!.operationHours,
                            image: _editedStore!.image,
                            id: '',
                            products: _editedStore!.products,
                            imageFromPhone: _pickedImage == null ? null : File(_pickedImage!.path));
                      },
                      onSaved: (value) {
                        _editedStore = OnlineStoreDTO(
                            name: _editedStore!.name,
                            phoneNumber: value!,
                            address: _editedStore!.address,
                            categories: _editedStore!.categories,
                            operationHours: _editedStore!.operationHours,
                            image: _editedStore!.image,
                            id: '',
                            products: _editedStore!.products,
                            imageFromPhone: _pickedImage == null ? null : File(_pickedImage!.path));
                      },
                    ),
                    TextFormField(
                      key: const Key('storeAddress'),
                      decoration: InputDecoration(labelText: 'Address'),
                      controller: OpenOnlineStorePipeline._controller,
                      onTap: () => showDialog(context: context, builder: (context) => destinationBuilder),
                      onSaved: (value) {
                        _editedStore = OnlineStoreDTO(
                            name: _editedStore!.name,
                            phoneNumber: _editedStore!.phoneNumber,
                            address: value!,
                            categories: _editedStore!.categories,
                            operationHours: _editedStore!.operationHours,
                            image: _editedStore!.image,
                            id: '',
                            products: _editedStore!.products,
                            imageFromPhone: _pickedImage == null ? null : File(_pickedImage!.path));
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
            Divider(height: 0),
            Container(
              height: deviceSize.height * 0.5,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: DUMMY_CATEGORIES.length,
                itemBuilder: (context, index) => CheckboxListTile(
                  key: Key("store_category_$index"),
                  value: _selectedItems.contains(DUMMY_CATEGORIES[index].title),
                  title: Text(DUMMY_CATEGORIES[index].title),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) => _itemChange(DUMMY_CATEGORIES[index].title, isChecked!),
                ),
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
            Divider(height: 0),
            Padding(
              padding: EdgeInsets.all(deviceSize.width * 0.03),
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
                            child: Text(_editedStore!.operationHours['sunday']![0].format(context)),
                          ),
                          Text('-'),
                          ElevatedButton(
                            onPressed: () {
                              _selectTime('sunday[1]');
                            },
                            child: Text(_editedStore!.operationHours['sunday']![1].format(context)),
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
                            child: Text(_editedStore!.operationHours['monday']![0].format(context)),
                          ),
                          Text('-'),
                          ElevatedButton(
                            onPressed: () => _selectTime('monday[1]'),
                            child: Text(_editedStore!.operationHours['monday']![1].format(context)),
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
                            child: Text(_editedStore!.operationHours['tuesday']![0].format(context)),
                          ),
                          Text('-'),
                          ElevatedButton(
                            onPressed: () {
                              _selectTime('tuesday[1]');
                            },
                            child: Text(_editedStore!.operationHours['tuesday']![1].format(context)),
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
                            child: Text(_editedStore!.operationHours['wednesday']![0].format(context)),
                          ),
                          Text('-'),
                          ElevatedButton(
                            onPressed: () {
                              _selectTime('wednesday[1]');
                            },
                            child: Text(_editedStore!.operationHours['wednesday']![1].format(context)),
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
                            child: Text(_editedStore!.operationHours['thursday']![0].format(context)),
                          ),
                          Text('-'),
                          ElevatedButton(
                            onPressed: () {
                              _selectTime('thursday[1]');
                            },
                            child: Text(_editedStore!.operationHours['thursday']![1].format(context)),
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
                            child: Text(_editedStore!.operationHours['friday']![0].format(context)),
                          ),
                          Text('-'),
                          ElevatedButton(
                            onPressed: () {
                              _selectTime('friday[1]');
                            },
                            child: Text(_editedStore!.operationHours['friday']![1].format(context)),
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
                            child: Text(_editedStore!.operationHours['saturday']![0].format(context)),
                          ),
                          Text('-'),
                          ElevatedButton(
                            onPressed: () {
                              _selectTime('saturday[1]');
                            },
                            child: Text(_editedStore!.operationHours['saturday']![1].format(context)),
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
          children: [
            ElevatedButton(
              key: const Key('add_product'),
              child: const Text('Add Product'),
              onPressed: _showAddProduct,
            ),
            Wrap(
              children: _products
                  .map((e) => Chip(
                        deleteIcon: Icon(
                          Icons.close,
                        ),
                        onDeleted: () {
                          setState(() {
                            _products.remove(e);
                          });
                        },
                        label: Text(e.name),
                      ))
                  .toList(),
            ),
          ],
        );
      case 4:
        return bankAccountForm;
      case 5:
        return StorePreview(true, _editedStore!.name, _editedStore!.address, _pickedImage, _editedStore!.phoneNumber,
            _editedStore!.operationHours);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!_acceptTerms) {
        showDialog(context: context, builder: (ctx) => Terms());
        _acceptTerms = true;
      }
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: deviceSize.height * 0.1,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Open Online Store',
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        body: _isLoading
            ? Align(
              alignment: Alignment.center,
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [Center(
                  child: SizedBox(
                    height: deviceSize.height * 0.8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Container(
                          width: deviceSize.width * 0.6,
                          child: Text("We are opening your store, it might take a few seconds...",
                              textAlign: TextAlign.center),
                        )
                      ],
                    ),
                  ),
                ),
                ]
              ),
            )
            : ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [Container(
                  child: SizedBox(
                    height: deviceSize.height * 0.8,
                    child: Column(
                      children: [
                        IconStepper(
                          icons: [
                            Icon(Icons.info),
                            Icon(Icons.tag),
                            Icon(Icons.access_time),
                            Icon(Icons.add_shopping_cart_rounded),
                            Icon(Icons.account_balance),
                            Icon(Icons.storefront),
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
                        currentStepWidget(deviceSize)!,
                        Expanded(
                          child: Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.all(deviceSize.height * 0.025),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _currentStep > 0
                                      ? CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Theme.of(context).primaryColor,
                                          child: IconButton(
                                            color: Colors.black54,
                                            onPressed: cancel,
                                            icon: Icon(Icons.arrow_back),
                                          ),
                                        )
                                      : Container(),
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Theme.of(context).primaryColor,
                                    child: IconButton(
                                      key: const Key("continue_button"),
                                      color: Colors.black54,
                                      onPressed: continued,
                                      icon: Icon(_currentStep < 5 ? Icons.arrow_forward : Icons.done),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
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
        setState(() => _currentStep += 1);
        break;
      case 4:
        if (bankAccountForm.saveForm()) setState(() => _currentStep += 1);
        break;
      case 5:
        _saveForm();
        break;
    }
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }
}
