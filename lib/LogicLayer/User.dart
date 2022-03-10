import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/models/OnlineStoreModel.dart';
import 'package:final_project_yroz/models/UserModel.dart';
import 'package:final_project_yroz/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:tuple/tuple.dart';

import 'DigitalWallet.dart';
import 'ShoppingBag.dart';
import 'StoreOwnerState.dart';

class User extends ChangeNotifier {
  String? email;
  String? name;
  List<StoreDTO> favoriteStores;
  List<String> creditCards;
  String? imageUrl;
  String? bankAccount;
  StoreOwnerState? storeOwnerState;
  DigitalWallet digitalWallet;
  List<ShoppingBag> bagInStores;

  bool isSignedIn = false;

  User(this.email, this.name)
      : favoriteStores = <StoreDTO>[],
        creditCards = <String>[],
        bagInStores = <ShoppingBag>[],
        digitalWallet = new DigitalWallet(0) {}

  User.withNull()
      : favoriteStores = <StoreDTO>[],
        creditCards = <String>[],
        bagInStores = <ShoppingBag>[],
        digitalWallet = new DigitalWallet(0) {}

  void userFromModel(UserModel model) {
    this.email = model.email;
    this.name = model.name;
    this.imageUrl = model.imageUrl;
    this.digitalWallet = DigitalWallet.digitalWalletFromModel(model.digitalWalletModel!);
    //TODO: generate credit card list from json
    this.bankAccount = model.bankAccount;
    //TODO: check if we need the other fields (because we are writing directly to the cloud)
    this.storeOwnerState =
        model.storeOwnerModel == null ? null : StoreOwnerState.storeOwnerStateFromModel(model.storeOwnerModel!);
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

  void signOut(BuildContext context) async {
    try {
      isSignedIn = await UserAuthenticator().signOut();
      Navigator.pop(context);
      Navigator.of(context).pushReplacementNamed(LandingScreen.routeName);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<ResultInterface> openOnlineStore(OnlineStoreDTO store) async {
    var res = await StoreStorageProxy().openOnlineStore(store);
    if (!res.getTag()) return res; //failure
    var tuple = (res.getValue() as Tuple2); //<online store model, store owner id>
    if (storeOwnerState == null) {
      //we might already have a store, hence it won't be null
      this.storeOwnerState = new StoreOwnerState(tuple.item2);
    }
    this.storeOwnerState!.setOnlineStore(tuple.item1);
    notifyListeners();
    return res;
  }

  Future<ResultInterface> openPhysicalStore(StoreDTO store) async {
    var res = await StoreStorageProxy().openPhysicalStore(store);
    if (!res.getTag()) return res; //failure
    var tuple = (res.getValue() as Tuple2); //<physical store model, store owner id>
    if (storeOwnerState == null) {
      //we might already have a store, hence it won't be null
      this.storeOwnerState = new StoreOwnerState(tuple.item2);
    }
    this.storeOwnerState!.setPhysicalStore(tuple.item1);
    notifyListeners();
    return res;
  }

  Future<ResultInterface> updatePhysicalStore(StoreDTO store) async {
    var res = await StoreStorageProxy().updatePhysicalStore(store);
    if (!res.getTag()) return res; //failure

    this.storeOwnerState!.setPhysicalStore(res.getValue());
    notifyListeners();
    return res;
  }

  Future<ResultInterface> updateOnlineStore(StoreDTO store) async {
    var res = await StoreStorageProxy().updateOnlineStore(store);
    if (!res.getTag()) return res; //failure

    this.storeOwnerState!.setOnlineStore(res.getValue());
    notifyListeners();
    return res;
  }

  Future<ResultInterface> deleteStore(String id, bool isOnline) async {
    var res = await StoreStorageProxy().deleteStore(id, isOnline);
    if (!res.getTag()) return res; //failure

    if (isOnline)
      this.storeOwnerState!.onlineStore = null;
    else
      this.storeOwnerState!.physicalStore = null;
    notifyListeners();
    return res;
  }

  Future<List<StoreDTO>> getStoresByKeywords(String keywords) async {
    return await StoreStorageProxy().fetchStoresByKeywords(keywords);
  }

  Future<ResultInterface> changeName(String name) async {
    var res = await UsersStorageProxy().updateUserNameOrUrl(name, "");
    notifyListeners();
    return res;
  }

  Future<ResultInterface> changeImage(String imageUrl) async {
    var res = await UsersStorageProxy().updateUserNameOrUrl("", imageUrl);
    notifyListeners();
    return res;
  }

  Future<void> convertPhysicalStoreToOnline(StoreDTO physicalStore) async {
    var res = await StoreStorageProxy().convertPhysicalStoreToOnlineStore(physicalStore);
    if (!res.getTag()) {
      print(res.getMessage());
      return;
    }
    Tuple2<OnlineStoreModel, String> retVal = res.getValue();
    this.storeOwnerState = new StoreOwnerState(retVal.item2);
    this.storeOwnerState!.setOnlineStore(retVal.item1);
    this.storeOwnerState!.physicalStore = null;

    notifyListeners();
  }
}
