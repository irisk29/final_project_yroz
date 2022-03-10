import 'dart:convert';

import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/ShoppingBagDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/models/OnlineStoreModel.dart';
import 'package:final_project_yroz/models/ShoppingBagModel.dart';
import 'package:final_project_yroz/models/UserModel.dart';
import 'package:final_project_yroz/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:tuple/tuple.dart';

import 'DigitalWallet.dart';
import 'StoreOwnerState.dart';

class User extends ChangeNotifier {
  String? id;
  String? email;
  String? name;
  List<String> favoriteStores; //IDs of favorite stores
  List<String> favoriteProducts; //IDs of favorite products
  List<String> creditCards;
  String? imageUrl;
  String? bankAccount;
  StoreOwnerState? storeOwnerState;
  DigitalWallet digitalWallet;
  List<ShoppingBagDTO> bagInStores;

  bool isSignedIn = false;

  User(this.email, this.name)
      : favoriteStores = <String>[],
        favoriteProducts = <String>[],
        creditCards = <String>[],
        bagInStores = <ShoppingBagDTO>[],
        digitalWallet = new DigitalWallet(0) {}

  User.withNull()
      : favoriteStores = <String>[],
        favoriteProducts = <String>[],
        creditCards = <String>[],
        bagInStores = <ShoppingBagDTO>[],
        digitalWallet = new DigitalWallet(0) {}

  void userFromModel(UserModel model) async {
    this.id = model.id;
    this.email = model.email;
    this.name = model.name;
    this.imageUrl = model.imageUrl;
    this.favoriteProducts =
        model.favoriteProducts == null ? [] : (jsonDecode(model.favoriteProducts!) as List<dynamic>).cast<String>();
    this.favoriteStores =
        model.favoriteStores == null ? [] : (jsonDecode(model.favoriteStores!) as List<dynamic>).cast<String>();
    this.digitalWallet = DigitalWallet.digitalWalletFromModel(model.digitalWalletModel!);
    //TODO: generate credit card list from json
    this.bankAccount = model.bankAccount;
    //TODO: check if we need the other fields (because we are writing directly to the cloud)
    this.storeOwnerState =
        model.storeOwnerModel == null ? null : StoreOwnerState.storeOwnerStateFromModel(model.storeOwnerModel!);
    this.storeOwnerState =
        model.storeOwnerModel == null ? null : StoreOwnerState.storeOwnerStateFromModel(model.storeOwnerModel!);
    if (model.shoppingBagModels != null) {
      for (ShoppingBagModel shoppingBagModel in model.shoppingBagModels!) {
        var res = await UsersStorageProxy().convertShoppingBagModelToDTO(shoppingBagModel);
        if (!res.getTag()) {
          print(res.getMessage());
          continue;
        }
        this.bagInStores.add(res.getValue());
      }
    } else
      this.bagInStores = [];
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

  Future<void> addFavoriteProduct(String prodID) async {
    var res = await UsersStorageProxy().addFavoriteProduct(prodID);
    if (!res.getTag()) {
      print(res.getMessage());
      return;
    }
    this.favoriteProducts = res.getValue();
    notifyListeners();
  }

  Future<void> removeFavoriteProduct(String prodID) async {
    var res = await UsersStorageProxy().removeFavoriteProduct(prodID);
    if (!res.getTag()) {
      print(res.getMessage());
      return;
    }
    this.favoriteProducts = res.getValue();
    notifyListeners();
  }

  Future<void> addFavoriteStore(String storeID, bool isOnline) async {
    var res = await UsersStorageProxy().addFavoriteStore(storeID, isOnline);
    if (!res.getTag()) {
      print(res.getMessage());
      return;
    }
    this.favoriteStores = res.getValue();
    notifyListeners();
  }

  Future<void> removeFavoriteStore(String storeID, bool isOnline) async {
    var res = await UsersStorageProxy().removeFavoriteStore(storeID, isOnline);
    if (!res.getTag()) {
      print(res.getMessage());
      return;
    }
    this.favoriteStores = res.getValue();
    notifyListeners();
  }

  Future<void> addProductToShoppingBag(ProductDTO productDTO, double quantity, String storeID) async {
    var res = await UsersStorageProxy()
        .addProductToShoppingBag(productDTO, storeID, quantity, this.id!); // <product, shopping bag>
    if (!res.getTag()) {
      print(res.getMessage());
      return;
    }
    updateShoppingBag(res.getValue());

    notifyListeners();
  }

  Future<void> removeProductFromShoppingBag(ProductDTO productDTO, String storeID) async {
    var res = await UsersStorageProxy().removeProductFromShoppingBag(productDTO, storeID, this.id!);
    if (!res.getTag()) {
      print(res.getMessage());
      return;
    }
    updateShoppingBag(res.getValue());

    notifyListeners();
  }

  Future<void> updateProductQuantityInBag(ProductDTO productDTO, String storeID, double newQuantity) async {
    var res = await UsersStorageProxy().updateProductQuantityInBag(productDTO, storeID, newQuantity, this.id!);
    if (!res.getTag()) {
      print(res.getMessage());
      return;
    }

    var shoppingBag = this
        .bagInStores
        .firstWhere((element) => element.onlineStoreID == storeID && element.userId == this.id, orElse: null);
    if (shoppingBag == null) {
      print("No such shopping bag in store $storeID for user ${this.id}");
      return;
    }

    var cartDTO = UsersStorageProxy().convertStoreProductToCartProduct(productDTO, newQuantity);
    shoppingBag.removeProduct(productDTO.id);
    shoppingBag.addProduct(cartDTO);

    notifyListeners();
  }

  Future<void> clearShoppingBagInStore(String storeID) async {
    var res = await UsersStorageProxy().clearShoppingBagInStore(storeID, this.id!);
    if (!res.getTag()) {
      print(res.getMessage());
      return;
    }

    this.bagInStores.removeWhere((element) => element.onlineStoreID == storeID && element.userId == this.id!);
    notifyListeners();
  }

  Future<void> clearAllUserShoppingBags() async {
    await UsersStorageProxy().clearAllShoppingBag(this.id!);
  }

  void updateShoppingBag(ShoppingBagModel? shoppingBag) async {
    if (shoppingBag == null) this.bagInStores = [];
    var convertRes = await UsersStorageProxy().convertShoppingBagModelToDTO(shoppingBag!);
    if (!convertRes.getTag()) {
      print(convertRes.getMessage());
      return;
    }
    ShoppingBagDTO shoppingBagDTO = convertRes.getValue();
    if (!this.bagInStores.contains(shoppingBagDTO)) this.bagInStores.add(shoppingBagDTO);
  }
}
