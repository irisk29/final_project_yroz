import 'dart:convert';

import 'package:project_demo/DTOs/StroreDTO.dart';
import 'package:project_demo/DataLayer/StoreStorageProxy.dart';
import 'package:project_demo/LogicLayer/DigitalWallet.dart';
import 'package:project_demo/LogicLayer/ShoppingBag.dart';
import 'package:project_demo/LogicLayer/StoreOwnerState.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:project_demo/DataLayer/user_authenticator.dart';
import 'package:project_demo/Result/ResultInterface.dart';
import 'package:project_demo/models/ModelProvider.dart';
import 'package:project_demo/providers/online_store.dart';
import 'package:project_demo/screens/landing_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class User extends ChangeNotifier {
  String email;
  String name;
  List<OnlineStore> favoriteStores;
  List<String> creditCards;
  String imageUrl;
  String bankAccount;
  StoreOwnerState storeOwnerState;
  DigitalWallet digitalWallet;
  List<ShoppingBag> bagInStores;

  bool isSignedIn = false;

  User();
  void userFromModel(UserModel model) {
    this.email = model.email;
    this.name = model.name;
    this.imageUrl = model.imageUrl;
    this.digitalWallet =
        DigitalWallet.digitalWalletFromModel(model.digitalWalletModel);
    //TODO: generate credit card list from json
    this.bankAccount = model.bankAccount;
    //TODO: check if we need the other fields (because we are writing directly to the cloud)
  }

  void signIn(AuthProvider authProvider, BuildContext context) async {
    try {
      var currUser = await UserAuthenticator().signIn(authProvider);
      isSignedIn = currUser != null;
      if (isSignedIn) {
        userFromModel(currUser);
      }
      notifyListeners();
      Navigator.of(context).pushNamed(LandingScreen.routeName, arguments: this);
    } catch (e) {
      throw e;
    }
  }

  void signOut() async {
    try {
      isSignedIn = await UserAuthenticator().signOut();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<ResultInterface> openOnlineStore(StoreDTO store) async {
    var res = await StoreStorageProxy().openOnlineStore(store);
    if (!res.getTag()) return res; //failure
    var tuple =
        (res.getValue() as Tuple2); //<online store model, store owner id>
    if (storeOwnerState == null) {
      //we might alredy have a store, hence it won't be null
      this.storeOwnerState = new StoreOwnerState(tuple.item2);
    }
    this.storeOwnerState.setOnlineStore(tuple.item1);
    return res;
  }

  Future<ResultInterface> openPhysicalStore(StoreDTO store) async {
    var res = await StoreStorageProxy().openPhysicalStore(store);
    if (!res.getTag()) return res; //failure
    var tuple =
        (res.getValue() as Tuple2); //<physical store model, store owner id>
    if (storeOwnerState == null) {
      //we might alredy have a store, hence it won't be null
      this.storeOwnerState = new StoreOwnerState(tuple.item2);
    }
    this.storeOwnerState.setPhysicalStore(tuple.item1);
    return res;
  }
}
