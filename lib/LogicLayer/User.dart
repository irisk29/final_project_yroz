import 'dart:convert';

import 'package:collection/src/iterable_extensions.dart';
import 'package:f_logs/f_logs.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/ShoppingBagDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/Result/Failure.dart';
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
  List<Tuple2<String, bool>> favoriteStores; //IDs of favorite stores
  List<String> favoriteProducts; //IDs of favorite products
  List<String> creditCards;
  String? imageUrl;
  String? eWallet;
  StoreOwnerState? storeOwnerState;
  DigitalWallet digitalWallet;
  List<ShoppingBagDTO> bagInStores;

  bool isSignedIn = false;

  User(this.email, this.name)
      : favoriteStores = <Tuple2<String, bool>>[],
        favoriteProducts = <String>[],
        creditCards = <String>[],
        bagInStores = <ShoppingBagDTO>[],
        digitalWallet = new DigitalWallet(0) {}

  User.withNull()
      : favoriteStores = <Tuple2<String, bool>>[],
        favoriteProducts = <String>[],
        creditCards = <String>[],
        bagInStores = <ShoppingBagDTO>[],
        digitalWallet = new DigitalWallet(0) {}

  void userFromModel(UserModel model) async {
    try {
      this.id = model.id;
      this.email = model.email;
      this.name = model.name;
      this.imageUrl = model.imageUrl;
      this.eWallet = model.eWallet;
      this.favoriteProducts = model.favoriteProducts == null
          ? []
          : (jsonDecode(model.favoriteProducts!) as List<dynamic>)
              .cast<String>();
      this.favoriteStores = model.favoriteStores == null
          ? []
          : UsersStorageProxy.fromJsonToTupleList(model.favoriteStores!);
      this.storeOwnerState = model.storeOwnerModel == null
          ? null
          : StoreOwnerState.storeOwnerStateFromModel(model.storeOwnerModel!);
      if (model.shoppingBagModels != null) {
        for (ShoppingBagModel shoppingBagModel in model.shoppingBagModels!) {
          var res = await UsersStorageProxy()
              .convertShoppingBagModelToDTO(shoppingBagModel);
          if (!res.getTag()) {
            print(res.getMessage());
            continue;
          }
          this.bagInStores.add(res.getValue());
        }
      } else
        this.bagInStores = [];
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> signIn(AuthProvider authProvider, BuildContext context) async {
    try {
      var currUser = await UserAuthenticator().signIn(authProvider);
      isSignedIn = currUser != null;
      if (isSignedIn) {
        userFromModel(currUser);
      }
      notifyListeners();
      Navigator.of(context).pushNamed(LandingScreen.routeName, arguments: this);
    } catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
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
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<ResultInterface> openOnlineStore(OnlineStoreDTO store) async {
    try {
      var res = await StoreStorageProxy().openOnlineStore(store);
      if (!res.getTag()) return res; //failure
      // TODO: call user.create_store_account_in_api
      // TODO: call user.add_store_bank_account
      var tuple =
          (res.getValue() as Tuple2); //<online store model, store owner id>
      if (storeOwnerState == null) {
        //we might already have a store, hence it won't be null
        this.storeOwnerState = new StoreOwnerState(tuple.item2);
      }
      this.storeOwnerState!.setOnlineStoreFromModel(tuple.item1);
      notifyListeners();
      return res;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure(e.toString(), null);
    }
  }

  Future<ResultInterface> openPhysicalStore(StoreDTO store) async {
    try {
      var res = await StoreStorageProxy().openPhysicalStore(store);
      if (!res.getTag()) return res; //failure
      // TODO: call user.create_store_account_in_api
      // TODO: call user.add_store_bank_account
      var tuple =
          (res.getValue() as Tuple2); //<physical store model, store owner id>
      if (storeOwnerState == null) {
        //we might already have a store, hence it won't be null
        this.storeOwnerState = new StoreOwnerState(tuple.item2);
      }
      this.storeOwnerState!.setPhysicalStore(tuple.item1);
      notifyListeners();
      return res;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure(e.toString(), null);
    }
  }

  Future<ResultInterface> updatePhysicalStore(StoreDTO store) async {
    try {
      var res = await StoreStorageProxy().updatePhysicalStore(store);
      if (!res.getTag()) return res; //failure

      this.storeOwnerState!.setPhysicalStore(res.getValue());
      notifyListeners();
      return res;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure(e.toString(), null);
    }
  }

  Future<ResultInterface> updateOnlineStore(OnlineStoreDTO store) async {
    try {
      var res = await StoreStorageProxy().updateOnlineStore(store);
      if (!res.getTag()) return res; //failure

      this.storeOwnerState!.setOnlineStore(res.getValue());
      notifyListeners();
      return res;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure(e.toString(), null);
    }
  }

  Future<ResultInterface> deleteStore(String id, bool isOnline) async {
    try {
      var res = await StoreStorageProxy().deleteStore(id, isOnline);
      if (!res.getTag()) return res; //failure

      if (isOnline)
        this.storeOwnerState!.onlineStore = null;
      else
        this.storeOwnerState!.physicalStore = null;
      notifyListeners();
      return res;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure(e.toString(), null);
    }
  }

  Future<List<StoreDTO>> getStoresByKeywords(String keywords) async {
    return await StoreStorageProxy().fetchStoresByKeywords(keywords);
  }

  Future<ResultInterface> changeName(String name) async {
    try {
      var res = await UsersStorageProxy().updateUserNameOrUrl(name, "");
      if (!res.getTag()) {
        print(res.getMessage());
        return res;
      }
      this.name = name;
      notifyListeners();
      return res;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure(e.toString(), null);
    }
  }

  Future<ResultInterface> changeImage(String imageUrl) async {
    try {
      var res = await UsersStorageProxy().updateUserNameOrUrl("", imageUrl);
      if (!res.getTag()) {
        print(res.getMessage());
        return res;
      }
      this.imageUrl = imageUrl;
      notifyListeners();
      return res;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure(e.toString(), null);
    }
  }

  Future<void> convertPhysicalStoreToOnline(StoreDTO physicalStore) async {
    try {
      var res = await StoreStorageProxy()
          .convertPhysicalStoreToOnlineStore(physicalStore);
      if (!res.getTag()) {
        print(res.getMessage());
        return;
      }
      Tuple2<OnlineStoreModel, String> retVal = res.getValue();
      this.storeOwnerState = new StoreOwnerState(retVal.item2);
      this.storeOwnerState!.setOnlineStoreFromModel(retVal.item1);
      this.storeOwnerState!.physicalStore = null;

      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> addFavoriteProduct(String prodID) async {
    try {
      var res = await UsersStorageProxy().addFavoriteProduct(prodID);
      if (!res.getTag()) {
        print(res.getMessage());
        return;
      }
      this.favoriteProducts = res.getValue();
      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> removeFavoriteProduct(String prodID) async {
    try {
      var res = await UsersStorageProxy().removeFavoriteProduct(prodID);
      if (!res.getTag()) {
        print(res.getMessage());
        return;
      }
      this.favoriteProducts = res.getValue();
      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> addFavoriteStore(String storeID, bool isOnline) async {
    try {
      var res = await UsersStorageProxy().addFavoriteStore(storeID, isOnline);
      if (!res.getTag()) {
        print(res.getMessage());
        return;
      }
      this.favoriteStores = res.getValue();
      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> removeFavoriteStore(String storeID, bool isOnline) async {
    try {
      var res =
          await UsersStorageProxy().removeFavoriteStore(storeID, isOnline);
      if (!res.getTag()) {
        print(res.getMessage());
        return;
      }
      this.favoriteStores = res.getValue();
      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> addProductToShoppingBag(
      ProductDTO productDTO, double quantity, String storeID) async {
    try {
      var res = await UsersStorageProxy().addProductToShoppingBag(
          productDTO, storeID, quantity, this.id!); // <product, shopping bag>
      if (!res.getTag()) {
        print(res.getMessage());
        return;
      }
      updateShoppingBag(res.getValue());

      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> removeProductFromShoppingBag(
      ProductDTO productDTO, String storeID) async {
    try {
      var res = await UsersStorageProxy()
          .removeProductFromShoppingBag(productDTO, storeID, this.id!);
      if (!res.getTag()) {
        print(res.getMessage());
        return;
      }
      updateShoppingBag(res.getValue());

      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> updateProductQuantityInBag(
      ProductDTO productDTO, String storeID, double newQuantity) async {
    try {
      var res = await UsersStorageProxy().updateProductQuantityInBag(
          productDTO, storeID, newQuantity, this.id!);
      if (!res.getTag()) {
        print(res.getMessage());
        return;
      }

      var shoppingBag = this.bagInStores.firstWhere(
          (element) =>
              element.onlineStoreID == storeID && element.userId == this.id,
          orElse: null);
      if (shoppingBag == null) {
        print("No such shopping bag in store $storeID for user ${this.id}");
        return;
      }
      var shoppingBagCopy = shoppingBag;
      var cartDTO = UsersStorageProxy()
          .convertStoreProductToCartProduct(productDTO, newQuantity);
      shoppingBagCopy.removeProduct(productDTO.id);
      shoppingBagCopy.addProduct(cartDTO);

      this.bagInStores.remove(shoppingBag);
      this.bagInStores.add(shoppingBagCopy);

      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> clearShoppingBagInStore(String storeID) async {
    try {
      var res =
          await UsersStorageProxy().clearShoppingBagInStore(storeID, this.id!);
      if (!res.getTag()) {
        print(res.getMessage());
        return;
      }

      this.bagInStores.removeWhere((element) =>
          element.onlineStoreID == storeID && element.userId == this.id!);
      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> clearAllUserShoppingBags() async {
    await UsersStorageProxy().clearAllShoppingBag(this.id!);
  }

  void updateShoppingBag(ShoppingBagModel? shoppingBag) async {
    try {
      if (shoppingBag == null) {
        this.bagInStores = [];
        return;
      }
      var convertRes =
          await UsersStorageProxy().convertShoppingBagModelToDTO(shoppingBag);
      if (!convertRes.getTag()) {
        print(convertRes.getMessage());
        return;
      }
      ShoppingBagDTO shoppingBagDTO = convertRes.getValue();
      if (!this.bagInStores.contains(shoppingBagDTO))
        this.bagInStores.add(shoppingBagDTO);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<ShoppingBagDTO?> getCurrShoppingBag(String storeID) async {
    try {
      var res =
          await UsersStorageProxy().getCurrentShoppingBag(storeID, this.id!);
      if (!res.getTag()) {
        print(res.getMessage());
        return null;
      }
      return res.getValue();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return null;
    }
  }

  ShoppingBagDTO? getShoppingBag(String storeID) {
    return bagInStores
        .firstWhereOrNull((element) => element.onlineStoreID == storeID);
  }

  Future<void> addCreditCardToken(String token) async {
    var res = await UsersStorageProxy().addCreditCardToken(token);
    if (!res.getTag()) {
      print(res.getMessage());
      return;
    }
    this.creditCards = res.getValue();
    notifyListeners();
  }

  Future<void> removeCreditCardToken(String token) async {
    var res = await UsersStorageProxy().removeCreditCardToken(token);
    if (!res.getTag()) {
      print(res.getMessage());
      return;
    }
    this.creditCards = res.getValue();
    notifyListeners();
  }

  Future<void> createEWallet(String eWallet) async {
    var res = await UsersStorageProxy().saveEWallet(eWallet);
    if (!res.getTag()) {
      print(res.getMessage());
      return;
    }
    this.eWallet = res.getValue();
    notifyListeners();
  }
}
