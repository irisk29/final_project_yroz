import 'dart:convert';

import 'package:collection/src/iterable_extensions.dart';
import 'package:f_logs/f_logs.dart';
import 'package:final_project_yroz/DTOs/BankAccountDTO.dart';
import 'package:final_project_yroz/DTOs/CartProductDTO.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/PurchaseHistoryDTO.dart';
import 'package:final_project_yroz/DTOs/ShoppingBagDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/PurchaseStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:final_project_yroz/Result/Failure.dart';
import 'package:final_project_yroz/Result/OK.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:final_project_yroz/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:tuple/tuple.dart';

import 'StoreOwnerState.dart';

class User extends ChangeNotifier {
  String? id;
  String? email;
  String? name;
  List<Tuple2<String, bool>> favoriteStores; //IDs of favorite stores
  List<String> creditCards;
  String? imageUrl;
  String? eWallet;
  StoreOwnerState? storeOwnerState;
  List<ShoppingBagDTO> bagInStores;
  bool hideStoreOwnerOptions;

  bool isSignedIn = false;

  User(this.email, this.name)
      : favoriteStores = <Tuple2<String, bool>>[],
        creditCards = <String>[],
        bagInStores = <ShoppingBagDTO>[],
        hideStoreOwnerOptions = false {}

  User.withNull()
      : favoriteStores = <Tuple2<String, bool>>[],
        creditCards = <String>[],
        bagInStores = <ShoppingBagDTO>[],
        hideStoreOwnerOptions = false {}

  void userFromModel(UserModel model) async {
    try {
      this.creditCards = model.creditCards == null
          ? []
          : jsonDecode(model.creditCards!).cast<String>();
      this.id = model.id;
      this.email = model.email;
      this.name = model.name;
      this.imageUrl = model.imageUrl;
      this.eWallet = model.eWallet;
      this.hideStoreOwnerOptions = model.hideStoreOwnerOptions;
      this.favoriteStores = model.favoriteStores == null
          ? []
          : UsersStorageProxy.fromJsonToTupleList(model.favoriteStores!);
      this.storeOwnerState = model.storeOwnerModel == null
          ? null
          : StoreOwnerState.storeOwnerStateFromModel(
              model.storeOwnerModel!, () => notifyListeners());
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
      Tuple2<UserModel?, bool> currUser =
          await UserAuthenticator().signIn(authProvider);
      isSignedIn = currUser.item1 != null;
      if (isSignedIn) {
        userFromModel(currUser.item1!);
        if (currUser.item2) //this is a new user - first time signed in
        {
          await createEWallet();
        }
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

  void toggleStoreOwnerViewOption() {
    this.hideStoreOwnerOptions = !this.hideStoreOwnerOptions;
    UsersStorageProxy().saveStoreOwnerViewOption(this.hideStoreOwnerOptions);
    notifyListeners();
  }

  Future<ResultInterface> openOnlineStore(
      OnlineStoreDTO store, BankAccountDTO bankAccountDTO) async {
    try {
      var res = await StoreStorageProxy().openOnlineStore(store);
      if (!res.getTag()) return res; //failure
      var tuple =
          (res.getValue() as Tuple2); //<online store model, store owner id>
      if (storeOwnerState == null) {
        //we might already have a store, hence it won't be null
        this.storeOwnerState =
            new StoreOwnerState(tuple.item2, () => notifyListeners());
      }
      this.storeOwnerState!.setOnlineStoreFromModel(tuple.item1);
      String storeID = tuple.item1.id;
      await _createStoreAccount(storeID);
      await this.storeOwnerState!.addStoreBankAccount(
          storeID,
          bankAccountDTO.bankName,
          bankAccountDTO.branchNumber,
          bankAccountDTO.bankAccount);
      this.storeOwnerState!.createPurchasesSubscription();
      notifyListeners();
      return new Ok("opened online store", tuple.item1.id);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure(e.toString(), null);
    }
  }

  Future<ResultInterface> openPhysicalStore(
      StoreDTO store, BankAccountDTO bankAccountDTO) async {
    try {
      var res = await StoreStorageProxy().openPhysicalStore(store);
      if (!res.getTag()) return res; //failure
      var tuple =
          (res.getValue() as Tuple2); //<physical store model, store owner id>
      if (storeOwnerState == null) {
        //we might already have a store, hence it won't be null
        this.storeOwnerState =
            new StoreOwnerState(tuple.item2, () => notifyListeners());
      }
      this.storeOwnerState!.setPhysicalStore(tuple.item1);
      String storeID = tuple.item1.id;
      await _createStoreAccount(storeID);
      await this.storeOwnerState!.addStoreBankAccount(
          storeID,
          bankAccountDTO.bankName,
          bankAccountDTO.branchNumber,
          bankAccountDTO.bankAccount);
      this.storeOwnerState!.createPurchasesSubscription();
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

      this.storeOwnerState = null;
      _deleteStoreAccount(id);
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
      var res =
          await StoreStorageProxy().convertPhysicalStoreToOnline(physicalStore);
      if (!res.getTag()) {
        print(res.getMessage());
        return;
      }
      Tuple2<OnlineStoreModel, String> retVal = res.getValue();
      this.storeOwnerState =
          new StoreOwnerState(retVal.item2, () => notifyListeners());
      this.storeOwnerState!.setOnlineStoreFromModel(retVal.item1);
      this.storeOwnerState!.physicalStore = null;

      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> convertOnlineStoreToPhysical(OnlineStoreDTO onlineStore) async {
    try {
      var res =
          await StoreStorageProxy().convertOnlineStoreToPhysical(onlineStore);
      if (!res.getTag()) {
        print(res.getMessage());
        return;
      }
      Tuple2<PhysicalStoreModel, String> retVal = res.getValue();
      this.storeOwnerState =
          new StoreOwnerState(retVal.item2, () => notifyListeners());
      this.storeOwnerState!.setPhysicalStore(retVal.item1);
      this.storeOwnerState!.onlineStore = null;

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

  void addProductToShoppingBagLocally(
      String storeID, CartProductDTO cartProductDTO) {
    ShoppingBagDTO? shoppingBagDTO = getShoppingBag(storeID);
    if (shoppingBagDTO == null) {
      FLog.error(text: "No shopping bag was found");
      return;
    }
    shoppingBagDTO.addProduct(cartProductDTO);
    notifyListeners();
  }

  void decreaseProductQuantityLocally(String storeID, String cartProdID) {
    ShoppingBagDTO? shoppingBagDTO = getShoppingBag(storeID);
    if (shoppingBagDTO == null) {
      FLog.error(text: "No shopping bag was found");
      return;
    }
    shoppingBagDTO.decreaseProductQuantity(cartProdID);
    notifyListeners();
  }

  Future<void> removeProductFromShoppingBag(
      String cartProductID, String storeID) async {
    try {
      ShoppingBagDTO? shoppingBagDTO = getShoppingBag(storeID);
      if (shoppingBagDTO == null) {
        FLog.error(text: "No shopping bag was found");
        return;
      }
      shoppingBagDTO.removeProduct(cartProductID);
      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> updateOrCreateCartProduct(
      ProductDTO productDTO, String storeID, double newQuantity) async {
    try {
      var res = await UsersStorageProxy().updateOrCreateCartProduct(
          productDTO, storeID, newQuantity, this.id!);
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

  Future<void> saveShoppingBag(String storeID) async {
    try {
      var shoppingBags =
          this.bagInStores.where((element) => element.onlineStoreID == storeID);
      if (shoppingBags.isNotEmpty && shoppingBags.first.bagSize() > 0) {
        var saveRes =
            await UsersStorageProxy().saveShoppingBag(shoppingBags.first);
        if (saveRes.getTag()) {
          shoppingBags.first.id = saveRes.getValue();
        }
      } else {
        await UsersStorageProxy().clearShoppingBagInStore(storeID, this.id!);
      }
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
        FLog.error(text: convertRes.getMessage());
        return;
      }
      ShoppingBagDTO shoppingBagDTO = convertRes.getValue();
      if (!this.bagInStores.contains(shoppingBagDTO)) {
        this.bagInStores.add(shoppingBagDTO);
      } else {
        //update
        this.bagInStores.removeWhere((element) =>
            element.userId == shoppingBag.usermodelID &&
            element.onlineStoreID == shoppingBag.onlineStoreID);
        this.bagInStores.add(shoppingBagDTO);
      }
      notifyListeners();
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

  Future<ResultInterface> addCreditCard(String cardNumber, String expireDate,
      String cvv, String cardHolder) async {
    try {
      var internalRes = await InternalPaymentGateway()
          .addUserCreditCard(this.id!, cardNumber, expireDate, cvv, cardHolder);
      if (!internalRes.getTag()) {
        print(internalRes.getMessage());
        return internalRes;
      }
      String creditCardToken = internalRes.getValue()!;
      var res = await UsersStorageProxy().addCreditCardToken(creditCardToken);
      if (!res.getTag()) {
        print(res.getMessage());
        return res;
      }
      this.creditCards = res.getValue();
      notifyListeners();
      return new Ok("added new credit card successfully");
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure(e.toString());
    }
  }

  Future<void> removeCreditCardToken(String token) async {
    try {
      var internalRes =
          await InternalPaymentGateway().removeUserCreditCard(this.id!, token);
      if (!internalRes.getTag()) {
        print(internalRes.getMessage());
        return;
      }
      var res = await UsersStorageProxy().removeCreditCardToken(token);
      if (!res.getTag()) {
        print(res.getMessage());
        return;
      }
      this.creditCards = res.getValue();
      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> createEWallet() async {
    try {
      var createWalletRes =
          await InternalPaymentGateway().createUserAccount(this.id!);
      if (!createWalletRes.getTag()) {
        print(createWalletRes.getMessage());
        return;
      }
      var res =
          await UsersStorageProxy().saveEWallet(createWalletRes.getValue()!);
      if (!res.getTag()) {
        print(res.getMessage());
        return;
      }
      this.eWallet = res.getValue();
      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> _createStoreAccount(String storeID) async {
    //after the user creates a store, we only create an account for it
    var storeAccountRes =
        await InternalPaymentGateway().createStoreAccount(storeID);
    if (!storeAccountRes.getTag()) {
      print(storeAccountRes.getMessage());
      return;
    }
    notifyListeners();
  }

  Future<void> _deleteStoreAccount(String storeID) async {
    //for when deleting a store
    var storeAccountRes =
        await InternalPaymentGateway().deleteStoreAccount(storeID);
    if (!storeAccountRes.getTag()) {
      print(storeAccountRes.getMessage());
      return;
    }
    notifyListeners();
  }

  Future<Map<String, Map<String, dynamic>>> getUserCreditCardDetails() async {
    try {
      var res = await InternalPaymentGateway()
          .userCreditCardDetails(this.id!, this.creditCards);
      if (!res.getTag()) {
        print(res.getMessage());
        return {};
      }
      FLog.info(text: "Credit cards details: ${res.getValue()}");
      return res.getValue()!;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return {};
    }
  }

  Future<void> editStoreBankAccount(BankAccountDTO bankAccountDTO) async {
    if (this.storeOwnerState != null) {
      await this.storeOwnerState!.editStoreBankAccount(bankAccountDTO);
      notifyListeners();
    }
  }

  Future<BankAccountDTO?> getStoreBankAccountDetails() async {
    if (this.storeOwnerState != null) {
      final bankAccountDetails =
          await storeOwnerState!.getStoreBankAccountDetails();
      return bankAccountDetails;
    }
    return null;
  }

  Future<String> getEWalletBalance() async {
    try {
      var res = await InternalPaymentGateway()
          .eWalletBalance(this.id!, this.eWallet!);
      if (!res.getTag()) {
        print(res.getMessage());
        return "";
      }
      return res.getValue()!;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return "";
    }
  }

  Future<ResultInterface> makePaymentOnlineStore(
      String creditCardToken,
      String cashBackAmount,
      String creditAmount,
      ShoppingBagDTO shoppingBagDTO) async {
    try {
      var res = await InternalPaymentGateway().makePayment(
          shoppingBagDTO.userId,
          shoppingBagDTO.onlineStoreID,
          this.eWallet!,
          creditCardToken,
          cashBackAmount,
          creditAmount);
      if (!res.getTag()) {
        print(res.getMessage());
        return res;
      }
      await clearShoppingBagInStore(shoppingBagDTO.onlineStoreID);
      await PurchaseStorageProxy().savePurchase(res.getValue()!, this.id!,
          shoppingBagDTO.onlineStoreID, shoppingBagDTO.products);
      return new Ok("Purchase was succsseful", res.getValue());
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return Failure(e.toString());
    }
  }

  Future<ResultInterface> makePaymentPhysicalStore(String creditCardToken,
      String cashBackAmount, String creditAmount, String storeID) async {
    try {
      var res = await InternalPaymentGateway().makePayment(this.id!, storeID,
          this.eWallet!, creditCardToken, cashBackAmount, creditAmount);
      if (!res.getTag()) {
        print(res.getMessage());
        return res;
      }

      await PurchaseStorageProxy()
          .savePurchase(res.getValue()!, this.id!, storeID, null);
      return new Ok("Purchase was successful", res.getValue());
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return Failure(e.toString());
    }
  }

  Future<List<PurchaseHistoryDTO>> getSuccssefulPurchaseHistoryForUserInRange(
      DateTime start, DateTime end) async {
    try {
      var res = await InternalPaymentGateway()
          .getPurchaseHistory(start, end, userId: this.id!, succeeded: true);
      if (!res.getTag()) {
        print(res.getMessage());
        return [];
      }
      FLog.info(text: "Got users purchases: ${res.getValue()}");
      List<Map<String, Object>> purchases = res.getValue()!;
      var purchasesDTO =
          purchases.map((e) => PurchaseHistoryDTO.fromJson(e)).toList();
      return purchasesDTO;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return [];
    }
  }

  Future<List<CartProductDTO>> getProductsInPurchaseHistory(
      String transactionID) async {
    try {
      var res = await PurchaseStorageProxy().getPurchaseProduct(transactionID);
      if (!res.getTag()) {
        print(res.getMessage());
        return [];
      }
      return res.getValue()!;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return [];
    }
  }
}
