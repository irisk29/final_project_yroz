import 'dart:convert';
import 'package:collection/src/iterable_extensions.dart';

import 'package:f_logs/f_logs.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:final_project_yroz/DTOs/CartProductDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/DTOs/ShoppingBagDTO.dart';
import 'package:final_project_yroz/Result/Failure.dart';
import 'package:final_project_yroz/Result/OK.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:tuple/tuple.dart';

class UsersStorageProxy {
  static final UsersStorageProxy _singleton = UsersStorageProxy._internal();

  factory UsersStorageProxy() {
    return _singleton;
  }

  UsersStorageProxy._internal();

  Future<Tuple2<UserModel, bool>> createUser(
      String email, String name, String imageUrl) async {
    List<UserModel> users = await Amplify.DataStore.query(UserModel.classType,
        where: UserModel.EMAIL.eq(email));

    if (users.isEmpty) //no such user in the DB
    {
      UserModel userModel = UserModel(
          email: email,
          name: name,
          imageUrl: imageUrl,
          hideStoreOwnerOptions: true,
          isLoggedIn: true);
      await Amplify.DataStore.save(userModel);
      print("Created user and saved to DB");
      FLog.info(text: "Created user with id ${userModel.id}");
      return Tuple2<UserModel, bool>(userModel, true);
    }
    var user = users.first;
    var fullUser = await createFullUser(user, name, imageUrl);
    return Tuple2<UserModel, bool>(fullUser, false);
  }

  Future<UserModel> createFullUser(
      UserModel user, String name, String? imageUrl) async {
    var resStoreOwner = await getStoreOwnerState(user.email);
    StoreOwnerModel? storeOwner =
        resStoreOwner.getTag() ? resStoreOwner.getValue() : null;
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(
        ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID.eq(user.id));

    UserModel fullUser = user.copyWith(
        id: user.id,
        email: user.email,
        name: name,
        imageUrl: imageUrl,
        creditCards: user.creditCards,
        eWallet: user.eWallet,
        shoppingBagModels: shoppingBags,
        storeOwnerModel: storeOwner,
        userModelStoreOwnerModelId: storeOwner == null ? "" : storeOwner.id,
        isLoggedIn: !user.isLoggedIn);
    FLog.info(text: "Fetched existing user");
    if (!user.isLoggedIn) //only save if the user wasn't logged in already
      await Amplify.DataStore.save(fullUser);
    return fullUser;
  }

  Future<UserModel?> getUser(String email) async {
    List<UserModel> users = await Amplify.DataStore.query(UserModel.classType,
        where: UserModel.EMAIL.eq(email));

    //return users.isEmpty ? null : await createFullUser(users.first, users.first.name, users.first.imageUrl);
    return users.isEmpty ? null : users.first;
  }

  Future<UserModel?> fetchFullUser(String email) async {
    List<UserModel> users = await Amplify.DataStore.query(UserModel.classType,
        where: UserModel.EMAIL.eq(email));

    if (users.isEmpty) return null;
    UserModel user = users.first;

    var resStoreOwner = await getStoreOwnerState(user.email);
    StoreOwnerModel? storeOwner =
        resStoreOwner.getTag() ? resStoreOwner.getValue() : null;
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(
        ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID.eq(user.id));

    UserModel fullUser = user.copyWith(
        id: user.id,
        email: user.email,
        name: user.name,
        imageUrl: user.imageUrl,
        creditCards: user.creditCards,
        eWallet: user.eWallet,
        shoppingBagModels: shoppingBags,
        storeOwnerModel: storeOwner,
        userModelStoreOwnerModelId: storeOwner == null ? "" : storeOwner.id,
        isLoggedIn: user.isLoggedIn);
    FLog.info(text: "Fetched full user");
    return fullUser;
  }

  Future<void> logoutUser() async {
    String emailCurrUser = UserAuthenticator().getCurrentUserId();
    var user = await getUser(emailCurrUser);
    if (user == null) {
      print("current user model is null, user's email: " + emailCurrUser);
      FLog.error(text: "No such user - $emailCurrUser");
      return null;
    }
    var u = user.copyWith(isLoggedIn: false);
    await Amplify.DataStore.save(u);
  }

  Future<void> saveStoreOwnerViewOption(bool hide) async {
    String emailCurrUser = UserAuthenticator().getCurrentUserId();
    var user = await getUser(emailCurrUser);
    if (user == null) {
      print("current user model is null, user's email: " + emailCurrUser);
      FLog.error(text: "No such user - $emailCurrUser");
      return null;
    }
    user = user.copyWith(hideStoreOwnerOptions: hide);
    await Amplify.DataStore.save(user);
  }

  Future<String?> getStoreOwnerStateId() async {
    String emailCurrUser = UserAuthenticator().getCurrentUserId();
    UserModel? currUser = await getUser(emailCurrUser);
    if (currUser == null) {
      print("current user model is null, user's email: " + emailCurrUser);
      FLog.error(text: "No such user - $emailCurrUser");
      return null;
    }
    return currUser.userModelStoreOwnerModelId;
  }

  Future<ResultInterface> getStoreOwnerState(String emailCurrUser) async {
    UserModel? currUser = await getUser(emailCurrUser);
    if (currUser == null) {
      FLog.error(text: "No such user - $emailCurrUser");
      return new Failure("current user model is null", emailCurrUser);
    }
    List<StoreOwnerModel> storeOwners = await Amplify.DataStore.query(
        StoreOwnerModel.classType,
        where: StoreOwnerModel.ID.eq(currUser.userModelStoreOwnerModelId));
    if (storeOwners.isEmpty) {
      FLog.warning(
          text:
              "The current user $emailCurrUser does not have store owner state");
      return new Failure("There is no store owner state", null);
    }
    var storeOwner = storeOwners.first;
    var onlinestore = await StoreStorageProxy()
        .fetchOnlineStore(storeOwner.storeOwnerModelOnlineStoreModelId);
    var physicalstore = await StoreStorageProxy()
        .fetchPhysicalStore(storeOwner.storeOwnerModelPhysicalStoreModelId);

    var fullStoreOwner = storeOwner.copyWith(
      onlineStoreModel: onlinestore,
      physicalStoreModel: physicalstore,
      storeOwnerModelPhysicalStoreModelId:
          physicalstore == null ? null : physicalstore.id,
      storeOwnerModelOnlineStoreModelId:
          onlinestore == null ? null : onlinestore.id,
    );
    return new Ok("Got store owner succssefully", fullStoreOwner);
  }

  Future<ResultInterface> updateUserNameOrUrl(
      String newName, String newImageUrl) async {
    var user = await getUser(UserAuthenticator().getCurrentUserId());
    if (user == null) {
      FLog.error(
          text: "No such user - ${UserAuthenticator().getCurrentUserId()}");
      return new Failure("No user was found", null);
    }
    var nameUpdate = newName.isEmpty ? user.name : newName;
    var urlUpdate = newImageUrl.isEmpty ? user.imageUrl : newImageUrl;
    var fullUser = await createFullUser(user, nameUpdate, urlUpdate);
    await Amplify.DataStore.save(fullUser);
    FLog.info(
        text: "new name $newName or new image url $newImageUrl was updated");
    return new Ok(
        "new name $newName or new image url $newImageUrl was updated", user.id);
  }

  static String toJsonFromTupleList(List<Tuple2<String, bool>> tuples) {
    List list = tuples
        .map(
          (e) => {
            '1': e.item1,
            '2': e.item2,
          },
        )
        .toList();

    String json = JsonEncoder.withIndent('  ').convert(list);
    return json;
  }

  static List<Tuple2<String, bool>> fromJsonToTupleList(String json) {
    List<dynamic> newList = jsonDecode(json) as List<dynamic>;

    final newTuples = newList
        .map(
          (e) => Tuple2<String, bool>(
            e['1'],
            e['2'],
          ),
        )
        .toList();

    return newTuples;
  }

  Future<ResultInterface> addFavoriteStore(
      String storeID, bool isOnline) async {
    var user = await getUser(UserAuthenticator().getCurrentUserId());
    if (user == null) {
      FLog.error(
          text: "No such user - ${UserAuthenticator().getCurrentUserId()}");
      return new Failure("No user was found", null);
    }
    var favoriteStores = user.favoriteStores;
    if (favoriteStores != null) {
      List<Tuple2<String, bool>> fav =
          fromJsonToTupleList(user.favoriteStores!);
      if (fav.isNotEmpty) {
        if (fav.firstWhereOrNull((element) => element.item1 == storeID) !=
            null) {
          FLog.error(text: "The store $storeID is already a favorite");
          return new Failure(
              "The store $storeID is already a favorite", storeID);
        }
      }
      fav.add(Tuple2<String, bool>(storeID, isOnline));
      var updatedUser = user.copyWith(
        favoriteStores: toJsonFromTupleList(fav),
      );
      await Amplify.DataStore.save(updatedUser);
      FLog.info(text: "Added succssefully store $storeID to user's favorite");
      return new Ok(
          "Added succssefully store $storeID to user's favorite", fav);
    }
    var updatedUser = user.copyWith(
      favoriteStores:
          toJsonFromTupleList([Tuple2<String, bool>(storeID, isOnline)]),
    );
    await Amplify.DataStore.save(updatedUser);
    FLog.info(text: "Added succssefully store $storeID to user's favorite");
    return new Ok("Added succssefully store $storeID to user's favorite",
        [Tuple2<String, bool>(storeID, isOnline)]);
  }

  Future<ResultInterface> removeFavoriteStore(
      String storeID, bool isOnline) async {
    var user = await getUser(UserAuthenticator().getCurrentUserId());
    if (user == null) {
      FLog.error(
          text: "No such user - ${UserAuthenticator().getCurrentUserId()}");
      return new Failure("No user was found", null);
    }
    var favoriteStores = user.favoriteStores;
    if (favoriteStores != null) {
      List<Tuple2<String, bool>> fav =
          fromJsonToTupleList(user.favoriteStores!);
      if (fav.firstWhereOrNull((element) => element.item1 == storeID) == null) {
        FLog.error(text: "The store $storeID is not a favorite");
        return new Failure("The store $storeID is not a favorite", storeID);
      }
      fav.removeWhere((element) => element.item1 == storeID);
      var updatedUser = user.copyWith(
        favoriteStores: toJsonFromTupleList(fav),
      );
      await Amplify.DataStore.save(updatedUser);
      FLog.info(
          text: "Removed succssefully store $storeID from user's favorite");
      return new Ok(
          "Removed succssefully store $storeID from user's favorite", fav);
    }
    FLog.error(
        text: "There is no favorite stores list from current user ${user.id}");
    return Failure(
        "There is no favorite stores list from current user ${user.id}", null);
  }

  Future<ResultInterface> addProductToShoppingBag(ProductDTO productDTO,
      String storeID, double quantity, String userID) async {
    var shoppingBagRes =
        await getOrCreateUserShoppingBagPerStore(storeID, userID);
    if (!shoppingBagRes.getTag()) return shoppingBagRes;
    ShoppingBagModel shoppingBag = shoppingBagRes.getValue();
    CartProductModel item = CartProductModel(
        storeProductID: productDTO.id,
        name: productDTO.name,
        categories: JsonEncoder.withIndent('  ').convert(productDTO.category),
        price: productDTO.price,
        imageUrl: productDTO.imageUrl,
        description: productDTO.description,
        amount: quantity,
        shoppingbagmodelID: shoppingBag.id);
    await Amplify.DataStore.save(item);
    List<CartProductModel> productsList = shoppingBag.CartProductModels == null
        ? []
        : shoppingBag.CartProductModels!;
    productsList.add(item);
    var shoppingBagWithNewItem =
        shoppingBag.copyWith(CartProductModels: productsList);
    await Amplify.DataStore.save(shoppingBagWithNewItem);
    FLog.info(
        text: "Saved shopping bag product(id - ${item.id}) succssesfully");
    return new Ok("Saved shopping bag product(id - ${item.id}) succssesfully",
        shoppingBagWithNewItem);
  }

  CartProductDTO converCartProductModelToDTO(CartProductModel model,
      String storeProductID, String storeID, double quantity) {
    return CartProductDTO(
        model.storeProductID!,
        model.name,
        model.price,
        model.categories,
        model.imageUrl,
        model.description,
        quantity,
        storeID,
        model.id);
  }

  Future<ResultInterface> getOrCreateUserShoppingBagPerStore(
      String storeID, String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(
        ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID
            .eq(userID)
            .and(ShoppingBagModel.ONLINESTOREID.eq(storeID)));
    if (shoppingBags.isEmpty) {
      //first time we add a product in a specific store we create a shopping bag
      ShoppingBagModel shoppingBagModel =
          new ShoppingBagModel(usermodelID: userID, onlineStoreID: storeID);
      await Amplify.DataStore.save(shoppingBagModel);
      FLog.info(
          text: "Created new shopping bag for store $storeID and user $userID");
      return new Ok(
          "Created new shopping bag for store $storeID and user $userID",
          shoppingBagModel);
    }
    FLog.info(text: "Found shopping bag for store $storeID and user $userID");
    return new Ok("Found shopping bag for store $storeID and user $userID",
        shoppingBags[0]);
  }

  Future<ResultInterface> getCurrentShoppingBag(
      String storeID, String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(
        ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID
            .eq(userID)
            .and(ShoppingBagModel.ONLINESTOREID.eq(storeID)));
    if (shoppingBags.isEmpty) {
      FLog.error(text: "There is no shopping bag for user $userID");
      return new Failure("There is no shopping bag for user $userID", null);
    }

    return convertShoppingBagModelToDTO(shoppingBags[0]);
  }

  Future<ResultInterface> getProductsOfShoppingBag(String shoppingBagID) async {
    List<CartProductModel> items = await Amplify.DataStore.query(
        CartProductModel.classType,
        where: CartProductModel.SHOPPINGBAGMODELID.eq(shoppingBagID));
    if (items.isEmpty) {
      FLog.error(text: "No products in shoppingbag $shoppingBagID");
      return new Failure(
          "No products in shoppingbag $shoppingBagID", shoppingBagID);
    }
    FLog.info(text: "Found products in shopping bag $shoppingBagID");
    return new Ok("Found products in shopping bag $shoppingBagID", items);
  }

  Future<ResultInterface> convertShoppingBagModelToDTO(
      ShoppingBagModel shoppingBagModel) async {
    ResultInterface res = await getProductsOfShoppingBag(shoppingBagModel.id);
    if (!res.getTag()) return res;
    List<CartProductModel> vals = res.getValue() as List<CartProductModel>;
    ShoppingBagDTO shoppingBag = ShoppingBagDTO(shoppingBagModel.id,
        shoppingBagModel.usermodelID, shoppingBagModel.onlineStoreID!);
    List<CartProductDTO> shoppingBagProductsDTO = vals
        .map((e) =>
            convertCartProductModelToDTO(e, shoppingBagModel.onlineStoreID!))
        .toList();
    shoppingBag.products = shoppingBagProductsDTO;
    return new Ok("convert was succsseful", shoppingBag);
  }

  CartProductDTO convertCartProductModelToDTO(
      CartProductModel cartProductModel, String storeID) {
    return CartProductDTO(
        cartProductModel.storeProductID!,
        cartProductModel.name,
        cartProductModel.price,
        cartProductModel.categories.isEmpty
            ? ""
            : jsonDecode(cartProductModel.categories).toString(),
        cartProductModel.imageUrl == null ? "" : cartProductModel.imageUrl!,
        cartProductModel.description == null
            ? ""
            : cartProductModel.description!,
        cartProductModel.amount,
        storeID,
        cartProductModel.id);
  }

  Future<ResultInterface> removeProductFromShoppingBag(
      ProductDTO productDTO, String storeID, String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(
        ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID
            .eq(userID)
            .and(ShoppingBagModel.ONLINESTOREID.eq(storeID)));

    if (shoppingBags.isEmpty) {
      FLog.error(
          text:
              "No shopping bag was found for store $storeID and user $userID");
      return new Failure(
          "No shopping bag was found for store $storeID and user $userID",
          null);
    }

    var shoppingBag = shoppingBags.first; //one shopping bag per user per store
    ResultInterface res = await getProductsOfShoppingBag(shoppingBag.id);
    if (!res.getTag()) return res;
    List<CartProductModel> vals = res.getValue() as List<CartProductModel>;
    CartProductModel? prodToRemove = vals
        .firstWhereOrNull((element) => element.storeProductID == productDTO.id);
    if (prodToRemove != null) {
      vals.removeWhere((element) => element.id == productDTO.id);
      await Amplify.DataStore.delete(prodToRemove);
    } else {
      return new Failure(
          "No such cart product ${productDTO.id} to remove", null);
    }

    if (vals.isEmpty) // no more products in bag - need to remove bag
    {
      await Amplify.DataStore.delete(shoppingBag);
      FLog.info(
          text:
              "Removed product ${productDTO.id} and shopping bag ${shoppingBag.id}");
      return Ok(
          "Removed product ${productDTO.id} and shopping bag ${shoppingBag.id}",
          null);
    }
    var newShoppingBag = shoppingBag.copyWith(CartProductModels: vals);
    await Amplify.DataStore.save(newShoppingBag);
    FLog.info(
        text:
            "Succssesfully removed product ${productDTO.id} from shopping bag ${shoppingBag.id}");
    return new Ok(
        "Succssesfully removed product ${productDTO.id} from shopping bag ${shoppingBag.id}",
        newShoppingBag);
  }

  Future<ResultInterface> updateOrCreateCartProduct(ProductDTO productDTO,
      String storeID, double quantity, String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(
        ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID
            .eq(userID)
            .and(ShoppingBagModel.ONLINESTOREID.eq(storeID)));
    List<CartProductModel> cartProducts = await Amplify.DataStore.query(
        CartProductModel.classType,
        where: CartProductModel.STOREPRODUCTID.eq(productDTO
            .id)); // check if this product exists in shopping bag in case we already have one
    if (shoppingBags.isEmpty || cartProducts.isEmpty) {
      return addProductToShoppingBag(productDTO, storeID, quantity, userID);
    }

    var shoppingBag = shoppingBags.first;
    var productsRes = await getProductsOfShoppingBag(shoppingBag.id);
    if (!productsRes.getTag()) return productsRes;
    CartProductModel? productToUpdate = (productsRes.getValue()
            as List<CartProductModel>)
        .firstWhereOrNull((element) => element.storeProductID == productDTO.id);
    if (productToUpdate == null) {
      FLog.error(
          text:
              "No product was found to update with store product id ${productDTO.id}");
      return new Failure(
          "No product was found to update with store product id ${productDTO.id}",
          null);
    }

    final prevQuantity = productToUpdate.amount;
    var newProd = productToUpdate.copyWith(amount: quantity + prevQuantity);
    await Amplify.DataStore.save(newProd);
    List<CartProductModel> productsList = shoppingBag.CartProductModels == null
        ? []
        : shoppingBag.CartProductModels!;
    productsList.add(newProd);
    var shoppingBagWithNewItem =
        shoppingBag.copyWith(CartProductModels: productsList);
    await Amplify.DataStore.save(shoppingBagWithNewItem);
    FLog.error(text: "Updated product ${productDTO.id} succssefully");
    return new Ok("Updated product ${productDTO.id} succssefully",
        shoppingBagWithNewItem);
  }

  Future<ResultInterface> saveShoppingBag(ShoppingBagDTO shoppingBagDTO) async {
    List<CartProductModel> savedProducts = [];
    if (shoppingBagDTO.id != null) {
      ResultInterface res = await getProductsOfShoppingBag(shoppingBagDTO.id!);
      if (res.getTag()) {
        savedProducts = res.getValue() as List<CartProductModel>;
      }
    }

    List<CartProductModel> removeProducts = [];
    for (var savedProduct in savedProducts) {
      final products = shoppingBagDTO.products
          .where((element) => element.id == savedProduct.id);
      if (products.isEmpty) {
        removeProducts.add(savedProduct);
        await Amplify.DataStore.delete(savedProduct);
      }
    }
    for (var p in removeProducts) {
      savedProducts.remove(p);
    }

    var shoppingBagRes = await getOrCreateUserShoppingBagPerStore(
        shoppingBagDTO.onlineStoreID, shoppingBagDTO.userId);
    if (!shoppingBagRes.getTag()) return shoppingBagRes;
    ShoppingBagModel prevShoppingBag = shoppingBagRes.getValue();

    List<CartProductModel> shoppingBagProducts = [];
    for (var bagProduct in shoppingBagDTO.products) {
      final products =
          savedProducts.where((element) => element.id == bagProduct.id);
      CartProductModel updatedProduct;
      if (products.isEmpty)
        updatedProduct = CartProductModel(
            storeProductID: bagProduct.id,
            name: bagProduct.name,
            categories:
                JsonEncoder.withIndent('  ').convert(bagProduct.category),
            price: bagProduct.price,
            imageUrl: bagProduct.imageUrl,
            description: bagProduct.description,
            amount: bagProduct.amount,
            shoppingbagmodelID: prevShoppingBag.id);
      else
        updatedProduct = products.first.copyWith(amount: bagProduct.amount);
      shoppingBagProducts.add(updatedProduct);
      await Amplify.DataStore.save(updatedProduct);
    }

    ShoppingBagModel shoppingBagModel =
        prevShoppingBag.copyWith(CartProductModels: shoppingBagProducts);
    await Amplify.DataStore.save(shoppingBagModel);
    return new Ok("saved shopping bag", shoppingBagModel.id);
  }

  Future<ResultInterface> clearShoppingBagInStore(
      String storeID, String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(
        ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID
            .eq(userID)
            .and(ShoppingBagModel.ONLINESTOREID.eq(storeID)));

    if (shoppingBags.isEmpty) {
      FLog.error(
          text:
              "No shopping bag was found for store $storeID and user $userID");
      return new Failure(
          "No shopping bag was found for store $storeID and user $userID",
          null);
    }
    await clearShoppingBagProductsInStore(shoppingBags.first.id);
    await Amplify.DataStore.delete(shoppingBags.first); //only one exists
    FLog.info(text: "Deleted shopping bag ${shoppingBags.first.id}");
    return new Ok(
        "Deleted shopping bag ${shoppingBags.first.id}", shoppingBags.first);
  }

  Future<ResultInterface> clearShoppingBagProductsInStore(String cartID) async {
    var res = await getProductsOfShoppingBag(cartID);
    if (!res.getTag()) return res;
    List<CartProductModel> models = res.getValue();
    for (CartProductModel model in models) {
      await Amplify.DataStore.delete(model);
    }
    FLog.info(text: "Deleted all products in shopping bag $cartID");
    return new Ok("Deleted all products in shopping bag $cartID", null);
  }

  Future<void> clearAllShoppingBag(String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(
        ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID.eq(userID));

    for (ShoppingBagModel model in shoppingBags) {
      await clearShoppingBagInStore(model.onlineStoreID!, model.usermodelID);
    }
  }

  Future<ResultInterface> addCreditCardToken(String token) async {
    String emailCurrUser = UserAuthenticator().getCurrentUserId();
    UserModel? currUser = await getUser(emailCurrUser);
    if (currUser == null) {
      FLog.error(text: "No such user - $emailCurrUser");
      return new Failure("No such user - $emailCurrUser", null);
    }

    List<String> creditCards =
        currUser.creditCards != null && currUser.creditCards!.isNotEmpty
            ? jsonDecode(currUser.creditCards!).cast<String>()
            : [];

    creditCards.add(token);
    UserModel updatedUser = currUser.copyWith(
        creditCards: JsonEncoder.withIndent('  ').convert(creditCards));
    await Amplify.DataStore.save(updatedUser);
    FLog.info(text: "Succssefully added credit card token $token");
    return new Ok("Succssefully added credit card token $token", creditCards);
  }

  Future<ResultInterface> removeCreditCardToken(String token) async {
    String emailCurrUser = UserAuthenticator().getCurrentUserId();
    UserModel? currUser = await getUser(emailCurrUser);
    if (currUser == null) {
      FLog.error(text: "No such user - $emailCurrUser");
      return new Failure("No such user - $emailCurrUser", null);
    }

    List<String> creditCards =
        currUser.creditCards != null && currUser.creditCards!.isNotEmpty
            ? jsonDecode(currUser.creditCards!).cast<String>()
            : [];

    if (creditCards.isEmpty) {
      FLog.error(
          text: "No credit card tokens were found for user $emailCurrUser");
      return new Failure(
          "No credit card tokens were found for user $emailCurrUser", null);
    }

    bool res = creditCards.remove(token);
    if (!res) {
      FLog.error(
          text: "Removal of credit card token $token was not successful");
      return new Failure(
          "Removal of credit card token $token was not successful", null);
    }
    UserModel updatedUser = currUser.copyWith(
        creditCards: JsonEncoder.withIndent('  ').convert(creditCards));
    await Amplify.DataStore.save(updatedUser);
    FLog.info(text: "Succssefully removed credit card token $token");
    return new Ok("Succssefully removed credit card token $token", creditCards);
  }

  Future<ResultInterface> saveEWallet(String eWallet) async {
    String emailCurrUser = UserAuthenticator().getCurrentUserId();
    UserModel? currUser = await getUser(emailCurrUser);
    if (currUser == null) {
      FLog.error(text: "No such user - $emailCurrUser");
      return new Failure("No such user - $emailCurrUser", null);
    }

    UserModel updatedUser = currUser.copyWith(eWallet: eWallet);
    await Amplify.DataStore.save(updatedUser);
    FLog.info(text: "Succssefully added eWallet token $eWallet");
    return new Ok("Succssefully added eWallet token $eWallet", eWallet);
  }

  Future<void> saveStoreBankAccount(String token, String storeOwnerID) async {
    List<StoreOwnerModel> owners = await Amplify.DataStore.query(
        StoreOwnerModel.classType,
        where: StoreOwnerModel.ID.eq(storeOwnerID));
    if (owners.isEmpty) {
      FLog.error(text: "No store owners were found for id $storeOwnerID");
      return;
    }

    StoreOwnerModel storeOwnerModel =
        owners.first.copyWith(bankAccountToken: token);
    await Amplify.DataStore.save(storeOwnerModel);
  }

  Future<void> removeStoreBankAccount(String token) async {
    var storeOwnerRes =
        await getStoreOwnerState(UserAuthenticator().getCurrentUserId());
    if (!storeOwnerRes.getTag()) {
      FLog.error(text: storeOwnerRes.getMessage());
    }
    StoreOwnerModel storeOwnerModel = storeOwnerRes.getValue();
    storeOwnerModel = storeOwnerModel.copyWith(bankAccountToken: null);
    await Amplify.DataStore.save(storeOwnerModel);
  }

  Future<void> saveLastPurchaseView(DateTime date) async {
    var storeOwnerRes =
        await getStoreOwnerState(UserAuthenticator().getCurrentUserId());
    if (!storeOwnerRes.getTag()) {
      FLog.error(text: storeOwnerRes.getMessage());
      return;
    }
    StoreOwnerModel storeOwnerModel = storeOwnerRes.getValue();
    storeOwnerModel = storeOwnerModel.copyWith(
        lastPurchasesView:
            TemporalDateTime.fromString(date.toDateTimeIso8601String()));
    await Amplify.DataStore.save(storeOwnerModel);
  }

  Future<ResultInterface> deleteUser(String email) async {
    var user = await getUser(email);
    if (user == null) return new Failure("No such user $email", null);

    var res = await getStoreOwnerState(email);
    if (res.getTag()) {
      StoreOwnerModel storeOwnerModel = res.getValue();
      if (storeOwnerModel.storeOwnerModelOnlineStoreModelId != null)
        StoreStorageProxy().deleteStore(
            storeOwnerModel.storeOwnerModelOnlineStoreModelId!, true);
      if (storeOwnerModel.storeOwnerModelPhysicalStoreModelId != null)
        StoreStorageProxy().deleteStore(
            storeOwnerModel.storeOwnerModelPhysicalStoreModelId!, false);
      await Amplify.DataStore.delete(storeOwnerModel);
    }
    clearAllShoppingBag(user.id);
    await Amplify.DataStore.delete(user);
    return new Ok("Deleted User $email", user.id);
  }

  Future<List<ShoppingBagDTO>> getUserShoppingBags(String userID) async {
    List<ShoppingBagModel> bags = await Amplify.DataStore.query(
        ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID.eq(userID));
    List<ShoppingBagDTO> dtos = [];
    for (var bag in bags) {
      var res = await convertShoppingBagModelToDTO(bag);
      if (res.getTag()) dtos.add(res.getValue());
    }
    return dtos;
  }
}
