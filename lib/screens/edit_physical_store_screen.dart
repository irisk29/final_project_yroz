import 'package:address_search_field/address_search_field.dart';
import 'package:final_project_yroz/DTOs/BankAccountDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:final_project_yroz/screens/edit_online_store_screen.dart';
import 'package:final_project_yroz/screens/manage_physical_store_screen.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:final_project_yroz/widgets/image_input.dart';
import 'package:final_project_yroz/widgets/store_preview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:im_stepper/stepper.dart';
import 'package:tuple/tuple.dart';

import '../LogicLayer/Secret.dart';
import '../LogicLayer/SecretLoader.dart';
import '../LogicModels/OpeningTimes.dart';
import '../dummy_data.dart';
import '../widgets/opening_hours.dart';

class EditPhysicalStorePipeline extends StatefulWidget {
  static const routeName = '/edit-physical-store';

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
  _EditPhysicalStorePipelineState createState() {
    return _EditPhysicalStorePipelineState();
  }

  //for test purposes
  Widget wrapWithMaterial(List<NavigatorObserver> nav, UserModel user) =>
      MaterialApp(
        routes: {
          TabsScreen.routeName: (ctx) => TabsScreen().wrapWithMaterial(nav),
        },
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: User.fromModel(user),
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

class _EditPhysicalStorePipelineState extends State<EditPhysicalStorePipeline> {
  int _currentStep = 0;

  final destCtrl = TextEditingController();
  final _detailsform = GlobalKey<FormState>();

  late AddressSearchBuilder destinationBuilder;
  XFile? _pickedImage = null;
  StoreDTO? _editedStore;

  final List<String> _selectedItems = [];

  late Secret secret;

  var _isInit = true;
  var _isLoading = false;
  var _categorySelected = true;
  var _formChanged;

  @override
  void initState() {
    _formChanged = false;
    _editedStore = Provider.of<User>(context, listen: false)
        .storeOwnerState!
        .physicalStore;
    openingHours = OpeningHours(_editedStore!.operationHours);
    super.initState();
  }

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
          controller: EditPhysicalStorePipeline._controller,
          builder: AddressDialogBuilder(),
          onDone: (Address address) => address);
      _editedStore = Provider.of<User>(context, listen: false)
          .storeOwnerState!
          .physicalStore;
      _selectedItems.addAll(_editedStore!.categories);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _selectImage(XFile pickedImage) {
    _pickedImage = pickedImage;
    _formChanged = true;
    setState(() {});
  }

  void _unselectImage() {
    _pickedImage = null;
    _formChanged = true;
    setState(() {});
  }

  late OpeningHours openingHours;

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    if (_editedStore!.id.isNotEmpty) {
      _editedStore!.categories = _selectedItems;
      _editedStore!.operationHours = openingHours.saveOpenHours();
      final res = await Provider.of<User>(context, listen: false)
          .updatePhysicalStore(_editedStore!);
      if (res.getTag()){
        SnackBar snackBar = SnackBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          behavior: SnackBarBehavior.floating,
          content: const Text('Changed successfully!', textAlign: TextAlign.center),
          width: MediaQuery.of(context).size.width * 0.5,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pop();
      }
      else {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Edit Store Error'),
            content: Text(res.getMessage()),
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
  }

  // This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.insert(0, itemValue);
        _categorySelected = true;
      } else {
        _selectedItems.remove(itemValue);
      }
      _formChanged = true;
    });
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
            Container(
              height: deviceSize.height * 0.625,
              child: Padding(
                padding: EdgeInsets.all(deviceSize.width * 0.03),
                child: Form(
                  key: _detailsform,
                  child: Column(
                    children: <Widget>[
                      ImageInput(
                          _selectImage, _unselectImage, _pickedImage, true),
                      TextFormField(
                        key: const Key('storeName'),
                        initialValue: _editedStore!.name,
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
                        onChanged: (_) => _formChanged = true,
                        onSaved: (value) {
                          _editedStore = StoreDTO(
                              name: value!,
                              phoneNumber: _editedStore!.phoneNumber,
                              address: _editedStore!.address,
                              categories: _editedStore!.categories,
                              operationHours: _editedStore!.operationHours,
                              qrCode: _editedStore!.qrCode,
                              image: _editedStore!.image,
                              id: _editedStore!.id);
                        },
                      ),
                      IntlPhoneField(
                        key: const Key('phoneNumber'),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                        ),
                        initialValue: _editedStore!.phoneNumber.substring(4),
                        initialCountryCode: 'IL',
                        onChanged: (phone) {
                          _formChanged = true;
                          print(phone.completeNumber);
                        },
                        onSaved: (value) {
                          _editedStore = StoreDTO(
                              name: _editedStore!.name,
                              phoneNumber: value!.completeNumber,
                              address: _editedStore!.address,
                              categories: _editedStore!.categories,
                              operationHours: _editedStore!.operationHours,
                              qrCode: _editedStore!.qrCode,
                              image: _editedStore!.image,
                              id: _editedStore!.id);
                        },
                      ),
                      TextFormField(
                        key: const Key('storeAddress'),
                        initialValue: _editedStore!.address,
                        decoration: InputDecoration(labelText: 'Address'),
                        onTap: () => showDialog(
                            context: context,
                            builder: (context) => destinationBuilder),
                        onChanged: (_) => _formChanged = true,
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
                              name: _editedStore!.name,
                              phoneNumber: _editedStore!.phoneNumber,
                              address: value!,
                              categories: _editedStore!.categories,
                              operationHours: _editedStore!.operationHours,
                              qrCode: _editedStore!.qrCode,
                              image: _editedStore!.image,
                              id: _editedStore!.id);
                        },
                      ),
                    ],
                  ),
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
              height: deviceSize.height * 0.55,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: DUMMY_CATEGORIES.length,
                itemBuilder: (context, index) => CheckboxListTile(
                  key: Key("store_category_$index"),
                  value: _selectedItems.contains(DUMMY_CATEGORIES[index].title),
                  title: Text(DUMMY_CATEGORIES[index].title),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) =>
                      _itemChange(DUMMY_CATEGORIES[index].title, isChecked!),
                ),
              ),
            ),
            _categorySelected
                ? SizedBox(
                    height: deviceSize.height * 0.075,
                    child: Center(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: _selectedItems
                            .map((e) => Padding(
                                padding: EdgeInsets.only(
                                    right: deviceSize.width * 0.01,
                                    left: deviceSize.width * 0.01),
                                child: Chip(
                                  deleteIcon: Icon(
                                    Icons.close,
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedItems.remove(e);
                                      _formChanged = true;
                                    });
                                  },
                                  label: Text(e),
                                )))
                            .toList(),
                      ),
                    ),
                  )
                : Text(
                    "Please select at least one category",
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
          ],
        );
      case 2:
        return openingHours;
      case 3:
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
    final deviceSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => _exitWithoutSavingDialog(),
          ),
          toolbarHeight: deviceSize.height * 0.1,
          title: Text(
            'Edit Store',
            style: const TextStyle(
              fontSize: 22,
            ),
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    height: deviceSize.height * 0.85,
                    child: Column(
                      children: [
                        IconStepper(
                          icons: [
                            Icon(Icons.info),
                            Icon(Icons.tag),
                            Icon(Icons.access_time),
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
                              padding:
                                  EdgeInsets.all(deviceSize.height * 0.025),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _currentStep > 0
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              left: deviceSize.width * 0.025),
                                          child: CircleAvatar(
                                            radius: 25,
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            child: IconButton(
                                              color: Colors.black54,
                                              onPressed: cancel,
                                              icon: Icon(Icons.arrow_back),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: deviceSize.width * 0.025),
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: IconButton(
                                        key: const Key("continue_button"),
                                        color: Colors.black54,
                                        onPressed: continued,
                                        icon: Icon(_currentStep < 3
                                            ? Icons.arrow_forward
                                            : Icons.done),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
          setState(() {
            _categorySelected = true;
            _currentStep += 1;
          });
        } else {
          setState(() {
            _categorySelected = false;
          });
        }
        break;
      case 2:
        setState(() => _currentStep += 1);
        break;
      case 3:
        _saveForm();
        break;
    }
  }

  cancel() {
    _currentStep > 0
        ? setState(() {
            _categorySelected = true;
            _currentStep -= 1;
          })
        : null;
  }
}
