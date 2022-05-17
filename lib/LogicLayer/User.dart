import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
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
import 'package:final_project_yroz/screens/auth_screen.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
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
  String eWalletBalance;
  StoreOwnerState? storeOwnerState;
  List<ShoppingBagDTO> bagInStores;
  bool hideStoreOwnerOptions;

  User(this.email, this.name)
      : favoriteStores = <Tuple2<String, bool>>[],
        creditCards = <String>[],
        bagInStores = <ShoppingBagDTO>[],
        eWalletBalance = "0.0",
        hideStoreOwnerOptions = true {}

  User.withNull()
      : favoriteStores = <Tuple2<String, bool>>[],
        creditCards = <String>[],
        bagInStores = <ShoppingBagDTO>[],
        eWalletBalance = "0.0",
        hideStoreOwnerOptions = true {}

  User.fromModel(UserModel model)
      : favoriteStores = <Tuple2<String, bool>>[],
        creditCards = <String>[],
        bagInStores = <ShoppingBagDTO>[],
        eWalletBalance = "0.0",
        hideStoreOwnerOptions = true {
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
      this.bagInStores = [];
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<void> userFromModel(UserModel model) async {
    try {
      this.creditCards = model.creditCards == null
          ? []
          : jsonDecode(model.creditCards!).cast<String>();
      this.id = model.id;
      this.email = model.email;
      this.name = model.name;
      this.imageUrl = model.imageUrl;
      this.eWallet = model.eWallet;
      this.eWalletBalance = await getEWalletBalance();
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

  Future<ResultInterface> signIn(
      AuthProvider authProvider, BuildContext context) async {
    try {
      Tuple2<UserModel?, bool> currUser =
          await UserAuthenticator().signIn(authProvider);
      bool isSignedIn = currUser.item1 != null;
      if (isSignedIn) {
        if (!currUser.item2 && !currUser.item1!.isLoggedIn) {
          notifyListeners();
          return new Failure(
              "You are already logged-in in another device, please sign out.");
        }
        userFromModel(currUser.item1!);
        if (currUser.item2) //this is a new user - first time signed in
        {
          await createEWallet();
        }
      } else {
        //becuase we do not allow 2 devices at the same time for 1 user, the social login succeeds, but our app
        //rejects the authentication, therefore we need to sign out the user from the social network
        await Amplify.Auth.signOut(
            options: SignOutOptions(globalSignOut: true));
        if (currUser.item2)
          return new Failure(
              "You are already logged-in in another device, please sign out.");
        return new Failure("", 1);
      }
      notifyListeners();
      Navigator.of(context).pushNamed(TabsScreen.routeName);
    } catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      //await Amplify.Auth.signOut();
      return new Failure("Something went wrong, please try again later...");
    }
    return new Ok("User logged in");
  }

  void signOut(BuildContext context) async {
    try {
      await UserAuthenticator().signOut();
      notifyListeners();
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
      });
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
      if (!res.getTag()) {
        OnlineStoreModel online = res.getValue();
        await StoreStorageProxy().deleteOnlineStore(online.id);
        return res; //failure
      }
      var tuple =
          (res.getValue() as Tuple2); //<online store model, store owner id>
      this.storeOwnerState =
          new StoreOwnerState(tuple.item2, () => notifyListeners());

      this.storeOwnerState!.setOnlineStoreFromModel(tuple.item1);
      String storeID = tuple.item1.id;
      var accountRes = await _createStoreAccount(storeID);
      if (!accountRes.getTag()) {
        FLog.error(text: accountRes.getMessage());
        await StoreStorageProxy()
            .deleteStore(storeID, true); //revert open action
        this.storeOwnerState = null;
        return accountRes;
      }
      var bankAccountRes = await this.storeOwnerState!.addStoreBankAccount(
          storeID,
          bankAccountDTO.bankName,
          bankAccountDTO.branchNumber,
          bankAccountDTO.bankAccount);
      if (!bankAccountRes.getTag()) {
        FLog.error(text: bankAccountRes.getMessage());
        await InternalPaymentGateway().deleteStoreAccount(storeID);
        await StoreStorageProxy()
            .deleteStore(storeID, true); //revert open action
        this.storeOwnerState = null;
        return bankAccountRes;
      }
      this.storeOwnerState!.createPurchasesSubscription();
      notifyListeners();
      return new Ok("opened online store", tuple.item1.id);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure(
          "Something went wrong, please try again later...", null);
    }
  }

  Future<ResultInterface> openPhysicalStore(
      StoreDTO store, BankAccountDTO bankAccountDTO) async {
    try {
      var res = await StoreStorageProxy().openPhysicalStore(store);
      if (!res.getTag()) {
        PhysicalStoreModel physical = res.getValue();
        await StoreStorageProxy().deletePhysicalStore(physical.id);
        return res; //failure
      }
      var tuple =
          (res.getValue() as Tuple2); //<physical store model, store owner id>
      this.storeOwnerState =
          new StoreOwnerState(tuple.item2, () => notifyListeners());

      this.storeOwnerState!.setPhysicalStore(tuple.item1);
      String storeID = tuple.item1.id;
      var accountRes = await _createStoreAccount(storeID);
      if (!accountRes.getTag()) {
        FLog.error(text: accountRes.getMessage());
        await StoreStorageProxy()
            .deleteStore(storeID, false); //revert open action
        this.storeOwnerState = null;
        return accountRes;
      }
      var bankAccount = await this.storeOwnerState!.addStoreBankAccount(
          storeID,
          bankAccountDTO.bankName,
          bankAccountDTO.branchNumber,
          bankAccountDTO.bankAccount);
      if (!bankAccount.getTag()) {
        FLog.error(text: bankAccount.getMessage());
        await StoreStorageProxy()
            .deleteStore(storeID, false); //revert open action
        this.storeOwnerState = null;
        return bankAccount;
      }
      this.storeOwnerState!.createPurchasesSubscription();
      notifyListeners();
      return new Ok("opened physical store", storeID);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure(
          "Something went wrong, please try again later...", null);
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
      return new Failure(
          "Something went wrong, please try again later...", null);
    }
  }

  Future<ResultInterface> updateOnlineStore(OnlineStoreDTO store) async {
    try {
      var res = await StoreStorageProxy().updateOnlineStore(store);
      if (!res.getTag()) return res; //failure

      this.storeOwnerState!.setOnlineStoreFromModel(res.getValue());
      notifyListeners();
      return res;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure(
          "Something went wrong, please try again later...", null);
    }
  }

  Future<ResultInterface> deleteStore(String id, bool isOnline) async {
    try {
      var res = await StoreStorageProxy().deleteStore(id, isOnline);
      if (!res.getTag()) return res; //failure

      this.favoriteStores.removeWhere(
          (element) => element.item1 == id && element.item2 == isOnline);
      await UsersStorageProxy().removeFavoriteStore(id, isOnline);

      this.storeOwnerState = null;
      _deleteStoreAccount(id);
      notifyListeners();
      return res;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure(
          "Something went wrong, please try again later...", null);
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
      return new Failure(
          "Something went wrong, please try again later...", null);
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
      return new Failure(
          "Something went wrong, please try again later...", null);
    }
  }

  Future<void> _updateFavoriteAfterConvert(String id) async {
    var res =
        this.favoriteStores.firstWhereOrNull((element) => element.item1 == id);
    if (res == null) return;
    this.favoriteStores.removeWhere((element) => element.item1 == id);
    this.favoriteStores.add(new Tuple2(id, true));
    await UsersStorageProxy().removeFavoriteStore(id, false);
    await UsersStorageProxy().addFavoriteStore(id, true);
  }

  Future<ResultInterface> convertPhysicalStoreToOnline(
      StoreDTO physicalStore) async {
    try {
      var res = await StoreStorageProxy().convertPhysicalStoreToOnline(
          physicalStore, this.storeOwnerState!.lastTimeViewedPurchases);
      if (!res.getTag()) {
        print(res.getMessage());
        return res;
      }
      Tuple2<OnlineStoreModel, String> retVal = res.getValue();
      this.storeOwnerState!.setOnlineStoreFromModel(retVal.item1);
      this.storeOwnerState!.physicalStore = null;
      this.storeOwnerState!.createPurchasesSubscription();
      await _updateFavoriteAfterConvert(retVal.item1.id);
      notifyListeners();
      return new Ok("Upgraded Physical Store Succssefully", retVal.item1.id);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure("Something went wrong, please try again later...");
    }
  }

  Future<ResultInterface> addFavoriteStore(
      String storeID, bool isOnline) async {
    try {
      var res = await UsersStorageProxy().addFavoriteStore(storeID, isOnline);
      if (!res.getTag()) {
        FLog.error(text: res.getMessage());
        return res;
      }
      this.favoriteStores = res.getValue();
      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
    return new Ok("Added store $storeID to favorites", storeID);
  }

  Future<ResultInterface> removeFavoriteStore(
      String storeID, bool isOnline) async {
    try {
      var res =
          await UsersStorageProxy().removeFavoriteStore(storeID, isOnline);
      if (!res.getTag()) {
        FLog.error(text: res.getMessage());
        return res;
      }
      this.favoriteStores = res.getValue();
      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
    return new Ok("Removed store $storeID to favorites", storeID);
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
      await updateShoppingBag(res.getValue());

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

  Future<void> updateShoppingBag(ShoppingBagModel? shoppingBag) async {
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
        FLog.error(text: internalRes.getMessage());
        return internalRes;
      }
      String creditCardToken = internalRes.getValue()!;
      var res = await UsersStorageProxy().addCreditCardToken(creditCardToken);
      if (!res.getTag()) {
        FLog.error(text: res.getMessage());
        return res;
      }
      this.creditCards = res.getValue();
      notifyListeners();
      return new Ok("added new credit card successfully", creditCardToken);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure("Something went wrong, please try again later...");
    }
  }

  Future<ResultInterface> removeCreditCardToken(String token) async {
    try {
      var internalRes =
          await InternalPaymentGateway().removeUserCreditCard(this.id!, token);
      if (!internalRes.getTag()) {
        print(internalRes.getMessage());
        return internalRes;
      }
      var res = await UsersStorageProxy().removeCreditCardToken(token);
      if (!res.getTag()) {
        print(res.getMessage());
        return res;
      }
      this.creditCards = res.getValue();
      notifyListeners();
      return new Ok("removed credit card successfully", token);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure("Something went wrong, please try again later...");
    }
  }

  Future<void> createEWallet() async {
    try {
      var createWalletRes =
          await InternalPaymentGateway().createUserAccount(this.id!);
      if (!createWalletRes.getTag()) {
        FLog.error(text: createWalletRes.getMessage());
        return;
      }
      var res =
          await UsersStorageProxy().saveEWallet(createWalletRes.getValue()!);
      if (!res.getTag()) {
        FLog.error(text: res.getMessage());
        return;
      }
      this.eWallet = res.getValue();
      notifyListeners();
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  Future<ResultInterface> _createStoreAccount(String storeID) async {
    //after the user creates a store, we only create an account for it
    var storeAccountRes =
        await InternalPaymentGateway().createStoreAccount(storeID);
    if (!storeAccountRes.getTag()) {
      print(storeAccountRes.getMessage());
      return storeAccountRes;
    }
    notifyListeners();
    return new Ok(
        "Created store account succssefully", storeAccountRes.getValue());
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

  Future<ResultInterface> editStoreBankAccount(
      BankAccountDTO bankAccountDTO) async {
    if (this.storeOwnerState != null) {
      final res =
          await this.storeOwnerState!.editStoreBankAccount(bankAccountDTO);
      if (res.getTag()) notifyListeners();
      return res;
    }
    return Failure("The user does not have a store");
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
      if (this.eWallet == null) return "0";
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
      double cashBackAmount,
      double creditAmount,
      ShoppingBagDTO shoppingBagDTO) async {
    try {
      var res = await InternalPaymentGateway().makePayment(
          shoppingBagDTO.userId,
          shoppingBagDTO.onlineStoreID,
          this.eWallet!,
          creditCardToken,
          cashBackAmount.toString(),
          creditAmount.toString());
      if (!res.getTag()) {
        print(res.getMessage());
        return res;
      }
      this.eWalletBalance = await getEWalletBalance();
      await clearShoppingBagInStore(shoppingBagDTO.onlineStoreID);
      //
      await PurchaseStorageProxy().savePurchase(res.getValue()!, this.id!,
          shoppingBagDTO.onlineStoreID, shoppingBagDTO.products);
      return new Ok("Purchase was successful", res.getValue());
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return Failure("Something went wrong, please try again later...");
    }
  }

  Future<ResultInterface> makePaymentPhysicalStore(String creditCardToken,
      double cashBackAmount, double creditAmount, String storeID) async {
    try {
      var res = await InternalPaymentGateway().makePayment(
          this.id!,
          storeID,
          this.eWallet!,
          creditCardToken,
          cashBackAmount.toString(),
          creditAmount.toString());
      if (!res.getTag()) {
        print(res.getMessage());
        return res;
      }
      this.eWalletBalance = await getEWalletBalance();
      await PurchaseStorageProxy()
          .savePurchase(res.getValue()!, this.id!, storeID, null);
      return new Ok("Purchase was successful", res.getValue());
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return Failure("Something went wrong, please try again later...");
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
