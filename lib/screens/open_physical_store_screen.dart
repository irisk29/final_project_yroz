import 'dart:async';
import 'dart:io';

import 'package:address_search_field/address_search_field.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:final_project_yroz/widgets/bank_account_form.dart';
import 'package:final_project_yroz/widgets/image_input.dart';
import 'package:final_project_yroz/widgets/snake_bar.dart';
import 'package:final_project_yroz/widgets/store_preview.dart';
import 'package:final_project_yroz/widgets/terms.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:im_stepper/stepper.dart';
import 'package:final_project_yroz/widgets/opening_hours.dart';
import 'package:tuple/tuple.dart';

import '../LogicLayer/Secret.dart';
import '../LogicLayer/SecretLoader.dart';
import '../LogicModels/OpeningTimes.dart';
import '../dummy_data.dart';
import 'tutorial_screen.dart';

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

  static Openings openings = Openings(days: [
    new OpeningTimes(
        day: "Sunday",
        closed: false,
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Monday",
        closed: false,
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Tuesday",
        closed: false,
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Wednesday",
        closed: false,
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Thursday",
        closed: false,
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Friday",
        closed: false,
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Saturday",
        closed: false,
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
  ]);

  @override
  _OpenPhysicalStorePipelineState createState() {
    return _OpenPhysicalStorePipelineState();
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

class _OpenPhysicalStorePipelineState extends State<OpenPhysicalStorePipeline> {
  int _currentStep = 0;

  final destCtrl = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _detailsform = GlobalKey<FormState>();

  late AddressSearchBuilder destinationBuilder;

  XFile? _pickedImage = null;
  StoreDTO? _editedStore = StoreDTO(
      id: "",
      name: "",
      phoneNumber: "",
      address: "",
      categories: [],
      operationHours: OpenPhysicalStorePipeline.openings,
      qrCode: "",
      image: null,
      imageFromPhone: null);

  final List<String> _selectedItems = [];

  late Secret secret;

  final bankAccountForm = BankAccountForm();

  var _isInit = true;
  var _isLoading = false;
  var _bankLoading = false;
  var _acceptTerms = false;
  var _categorySelected = true;
  var _formChanged;
  var internet_conn = "";

  @override
  void initState() {
    _formChanged = false;
    openingHours = OpeningHours(OpenPhysicalStorePipeline.openings.clone(), () => _formChanged = true);
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
          controller: OpenPhysicalStorePipeline._controller,
          builder: AddressDialogBuilder(),
          onDone: (Address address) => address);
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
    _editedStore!.categories = _selectedItems;
    _editedStore!.operationHours = openingHours.saveOpenHours();
    try {
      final res = await Provider.of<User>(context, listen: false)
          .openPhysicalStore(_editedStore!, bankAccountForm.buildBankAccountDTO()!)
          .timeout(new Duration(minutes: 15));
      if (res.getTag())
        Navigator.of(context).pushReplacementNamed(TutorialScreen.routeName);
      else {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Store Opening Error'),
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
    } on TimeoutException catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Internet Connection Error'),
          content: Text("Please check your internet connectivity. Your store was not created."),
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
                      ImageInput(_selectImage, _unselectImage, null, _pickedImage, true),
                      TextFormField(
                        key: const Key('storeName'),
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Store Name'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a value.';
                          }
                          if (value.length > 40) {
                            return 'Can be max 40 characters long.';
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
                              id: '',
                              imageFromPhone: _pickedImage == null ? null : File(_pickedImage!.path));
                        },
                      ),
                      IntlPhoneField(
                        key: const Key('phoneNumber'),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                        ),
                        controller: _phoneNumberController,
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
                              id: '',
                              imageFromPhone: _pickedImage == null ? null : File(_pickedImage!.path));
                        },
                      ),
                      TextFormField(
                        key: const Key('storeAddress'),
                        decoration: InputDecoration(labelText: 'Address'),
                        controller: OpenPhysicalStorePipeline._controller,
                        onTap: () => showDialog(context: context, builder: (context) => destinationBuilder),
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
                              id: '',
                              imageFromPhone: _pickedImage == null ? null : File(_pickedImage!.path));
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
                  onChanged: (isChecked) => _itemChange(DUMMY_CATEGORIES[index].title, isChecked!),
                ),
              ),
            ),
            SizedBox(
              height: deviceSize.height * 0.075,
              child: Center(
                child: _categorySelected
                    ? ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: _selectedItems
                            .map((e) => Padding(
                                padding: EdgeInsets.only(right: deviceSize.width * 0.01, left: deviceSize.width * 0.01),
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
                      )
                    : Text(
                        "Please select at least one category",
                        style: TextStyle(color: Theme.of(context).errorColor),
                      ),
              ),
            )
          ],
        );
      case 2:
        return openingHours;
      case 3:
        return _bankLoading
            ? SizedBox(height: deviceSize.height * 0.625, child: Center(child: CircularProgressIndicator()))
            : bankAccountForm;
      case 4:
        return SizedBox(
          height: deviceSize.height * 0.65,
          child: Column(
            children: [
              StorePreview(false, _editedStore!.name, _editedStore!.address, _pickedImage, null,
                  _editedStore!.phoneNumber, openingHours.saveOpenHours(), null, true)
            ],
          ),
        );
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

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!_acceptTerms) {
        showDialog(context: context, builder: (ctx) => Terms());
        _acceptTerms = true;
      }
    });

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
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
                'Open Physical Store',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          body: _isLoading
              ? Align(
                  alignment: Alignment.center,
                  child: ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      Center(
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
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    child: SizedBox(
                      height: deviceSize.height * 0.85,
                      child: Column(
                        children: [
                          IconStepper(
                            icons: [
                              Icon(Icons.info),
                              Icon(Icons.tag),
                              Icon(Icons.access_time),
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
                          !_bankLoading
                              ? Expanded(
                                  child: Align(
                                    alignment: FractionalOffset.bottomCenter,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _currentStep > 0
                                            ? Padding(
                                                padding: EdgeInsets.only(left: deviceSize.width * 0.025),
                                                child: CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: Theme.of(context).primaryColor,
                                                  child: IconButton(
                                                    color: Colors.black54,
                                                    onPressed: cancel,
                                                    icon: Icon(Icons.arrow_back),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        Padding(
                                          padding: EdgeInsets.only(right: deviceSize.width * 0.025),
                                          child: CircleAvatar(
                                            radius: 25,
                                            backgroundColor: Theme.of(context).primaryColor,
                                            child: IconButton(
                                              key: const Key("continue_button"),
                                              color: Colors.black54,
                                              onPressed: () async => await continued(context),
                                              icon: Icon(_currentStep < 4 ? Icons.arrow_forward : Icons.done),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  continued(BuildContext context) async {
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
        setState(() => _bankLoading = true);
        final res = await bankAccountForm.saveForm(context);
        setState(() => _bankLoading = false);
        if (res) setState(() => _currentStep += 1);
        break;
      case 4:
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
