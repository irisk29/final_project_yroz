import 'dart:convert';
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

  Future<UserModel> createUser(String email, String name, String imageUrl) async {
    List<UserModel> users = await Amplify.DataStore.query(UserModel.classType, where: UserModel.EMAIL.eq(email));

    if (users.isEmpty) //no such user in the DB
    {
      UserModel userModel = UserModel(
          email: email,
          name: name,
          imageUrl: imageUrl);
      await Amplify.DataStore.save(userModel);
      print("Created user and saved to DB");
      FLog.info(text: "Created user with id ${userModel.id}");
      return userModel;
    }
    var user = users.first;
    return createFullUser(user, user.name, user.imageUrl);
  }

  Future<UserModel> createFullUser(UserModel user, String name, String? imageUrl) async {

    var resStoreOwner = await getStoreOwnerState(user.email);
    StoreOwnerModel? storeOwner = resStoreOwner.getTag() ? resStoreOwner.getValue() : null;
    List<ShoppingBagModel> shoppingBags =
        await Amplify.DataStore.query(ShoppingBagModel.classType, where: ShoppingBagModel.USERMODELID.eq(user.id));

    UserModel fullUser = user.copyWith(
        id: user.id,
        email: user.email,
        name: name,
        imageUrl: imageUrl,
        creditCards: user.creditCards,
        eWallet: user.eWallet,
        shoppingBagModels: shoppingBags,
        storeOwnerModel: storeOwner,
        userModelStoreOwnerModelId: storeOwner == null ? "" : storeOwner.id);
    FLog.info(text: "Fetched existing user");
    return fullUser;
  }

  Future<UserModel?> getUser(String email) async {
    List<UserModel> users = await Amplify.DataStore.query(UserModel.classType, where: UserModel.EMAIL.eq(email));

    return users.isEmpty ? null : users.first;
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
    List<StoreOwnerModel> storeOwners = await Amplify.DataStore.query(StoreOwnerModel.classType,
        where: StoreOwnerModel.ID.eq(currUser.userModelStoreOwnerModelId));
    if (storeOwners.isEmpty) {
      FLog.warning(
         text: "The current user $emailCurrUser does not have store owner state");
      return new Failure("There is no store owner state", null);
    }
    var storeOwner = storeOwners.first;
    var onlinestore = await StoreStorageProxy().fetchOnlineStore(storeOwner.storeOwnerModelOnlineStoreModelId);
    var physicalstore = await StoreStorageProxy().fetchPhysicalStore(storeOwner.storeOwnerModelPhysicalStoreModelId);

    var fullStoreOwner = storeOwner.copyWith(
      onlineStoreModel: onlinestore,
      physicalStoreModel: physicalstore,
      storeOwnerModelPhysicalStoreModelId: physicalstore == null ? null : physicalstore.id,
      storeOwnerModelOnlineStoreModelId: onlinestore == null ? null : onlinestore.id,
    );
    return new Ok("Got store owner succssefully", fullStoreOwner);
  }

  Future<ResultInterface> deleteStoreOwnerState() async {
    String emailCurrUser = UserAuthenticator().getCurrentUserId();
    UserModel? currUser = await getUser(emailCurrUser);
    if (currUser == null) {
      FLog.error(text: "No such user - $emailCurrUser");
      return new Failure("current user model is null ", emailCurrUser);
    }
    List<StoreOwnerModel> storeOwners = await Amplify.DataStore.query(StoreOwnerModel.classType,
        where: StoreOwnerModel.ID.eq(currUser.userModelStoreOwnerModelId));
    var storeOwner = storeOwners.isEmpty ? null : storeOwners.first;
    if (storeOwner == null) {
      FLog.warning(
          text: "The current user $emailCurrUser does not have store owner state");
      return new Failure("No store owner state", emailCurrUser);
    }
    await Amplify.DataStore.delete(storeOwner);
    FLog.info(text: "Deleted store owner ${storeOwner.id} succssefully");
    return new Ok("Deleted store owner state succssefully", storeOwner.id);
  }

  Future<ResultInterface> updateUserNameOrUrl(String newName, String newImageUrl) async {
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
    FLog.info(text: "new name $newName or new image url $newImageUrl was updated");
    return new Ok("new name $newName or new image url $newImageUrl was updated", user.id);
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

  Future<ResultInterface> addFavoriteProduct(String prodID) async {
    var user = await getUser(UserAuthenticator().getCurrentUserId());
    if (user == null) {
      FLog.error(text: "No such user - ${UserAuthenticator().getCurrentUserId()}");
      return new Failure("No user was found", null);
    }
    var favoriteProd = user.favoriteProducts;
    if (favoriteProd != null) {
      List<String> fav = (jsonDecode(user.favoriteProducts!) as List<dynamic>).cast<String>();
      if (fav.contains(prodID)) {
        FLog.error(text: "The product $prodID is already a favorite");
        return new Failure("The product $prodID is already a favorite", prodID);
      }
      fav.add(prodID);
      var updatedUser = user.copyWith(
        favoriteProducts: JsonEncoder.withIndent('  ').convert(fav),
      );
      await Amplify.DataStore.save(updatedUser);
      FLog.info(text: "Added succssefully product $prodID to user's favorite");
      return new Ok("Added succssefully product $prodID to user's favorite", fav);
    }
    var updatedUser = user.copyWith(
      favoriteProducts: JsonEncoder.withIndent('  ').convert([prodID]),
    );
    await Amplify.DataStore.save(updatedUser);
    FLog.info(text: "Added succssefully product $prodID to user's favorite");
    return new Ok("Added succssefully product $prodID to user's favorite", [prodID]);
  }

  Future<ResultInterface> addFavoriteStore(String storeID, bool isOnline) async {
    var user = await getUser(UserAuthenticator().getCurrentUserId());
    if (user == null) {
      FLog.error(text: "No such user - ${UserAuthenticator().getCurrentUserId()}");
      return new Failure("No user was found", null);
    }
    var favoriteStores = user.favoriteStores;
    if (favoriteStores != null) {
      List<Tuple2<String, bool>> fav = fromJsonToTupleList(user.favoriteStores!);
      if (fav.isNotEmpty) {
        if (fav.firstWhere((element) => element.item1 == storeID, orElse: null) != null) {
          FLog.error(text: "The store $storeID is already a favorite");
          return new Failure("The store $storeID is already a favorite", storeID);
        }
      }
      fav.add(Tuple2<String, bool>(storeID, isOnline));
      var updatedUser = user.copyWith(
        favoriteStores: toJsonFromTupleList(fav),
      );
      await Amplify.DataStore.save(updatedUser);
      FLog.info(text: "Added succssefully store $storeID to user's favorite");
      return new Ok("Added succssefully store $storeID to user's favorite", fav);
    }
    var updatedUser = user.copyWith(
      favoriteStores: toJsonFromTupleList([Tuple2<String, bool>(storeID, isOnline)]),
    );
    await Amplify.DataStore.save(updatedUser);
    FLog.info(text: "Added succssefully store $storeID to user's favorite");
    return new Ok("Added succssefully store $storeID to user's favorite", [Tuple2<String, bool>(storeID, isOnline)]);
  }

  Future<ResultInterface> removeFavoriteProduct(String prodID) async {
    var user = await getUser(UserAuthenticator().getCurrentUserId());
    if (user == null) {
      FLog.error(
          text: "No such user - ${UserAuthenticator().getCurrentUserId()}");
      return new Failure("No user was found", null);
    }
    var favoriteProd = user.favoriteProducts;
    if (favoriteProd != null) {
      List<String> fav = (jsonDecode(user.favoriteProducts!) as List<dynamic>).cast<String>();
      if (fav.isNotEmpty) {
        if (!fav.contains(prodID)) {
          FLog.error(text: "The product $prodID is not a favorite");
          return new Failure("The product $prodID is not a favorite", prodID);
        }
        fav.remove(prodID);
        var updatedUser = user.copyWith(
          favoriteProducts: JsonEncoder.withIndent('  ').convert(fav),
        );
        await Amplify.DataStore.save(updatedUser);
        return new Ok("Removed succssefully product $prodID from user's favorite", fav);
      }
      FLog.error(
          text: "There is no favorite stores list from current user ${user.id}");
      return new Failure("There is no favorite stores list from current user ${user.id}", null);
    }
    FLog.error(
        text: "There is no favorite products list from current user ${user.id}");
    return new Failure("There is no favorite products list from current user ${user.id}", null);
  }

  Future<ResultInterface> removeFavoriteStore(String storeID, bool isOnline) async {
    var user = await getUser(UserAuthenticator().getCurrentUserId());
    if (user == null) {
      FLog.error(text: "No such user - ${UserAuthenticator().getCurrentUserId()}");
      return new Failure("No user was found", null);
    }
    var favoriteStores = user.favoriteStores;
    if (favoriteStores != null) {
      List<Tuple2<String, bool>> fav = fromJsonToTupleList(user.favoriteStores!);
      if (fav.firstWhere((element) => element.item1 == storeID, orElse: null) == null) {
        FLog.error(text: "The store $storeID is not a favorite");
        return new Failure("The store $storeID is not a favorite", storeID);
      }
      fav.removeWhere((element) => element.item1 == storeID);
      var updatedUser = user.copyWith(
        favoriteStores: toJsonFromTupleList(fav),
      );
      await Amplify.DataStore.save(updatedUser);
      FLog.info(text: "Removed succssefully store $storeID from user's favorite");
      return new Ok("Removed succssefully store $storeID from user's favorite", fav);
    }
    FLog.error(
        text: "There is no favorite stores list from current user ${user.id}");
    return Failure("There is no favorite stores list from current user ${user.id}", null);
  }

  Future<ResultInterface> addProductToShoppingBag(
      ProductDTO productDTO, String storeID, double quantity, String userID) async {
    var shoppingBagRes = await getOrCreateUserShoppingBagPerStore(storeID, userID);
    if (!shoppingBagRes.getTag()) return shoppingBagRes;
    ShoppingBagModel shoppingBag = shoppingBagRes.getValue();
    CartProductModel item = CartProductModel(
        id: productDTO.id,
        name: productDTO.name,
        categories: JsonEncoder.withIndent('  ').convert(productDTO.category),
        price: productDTO.price,
        imageUrl: productDTO.imageUrl,
        description: productDTO.description,
        amount: quantity,
        shoppingbagmodelID: shoppingBag.id);
    await Amplify.DataStore.save(item);
    List<CartProductModel> productsList = shoppingBag.CartProductModels == null ? [] : shoppingBag.CartProductModels!;
    productsList.add(item);
    var shoppingBagWithNewItem = shoppingBag.copyWith(CartProductModels: productsList);
    FLog.info(
        text: "Saved shopping bag product(id - ${item.id}) succssesfully");
    return new Ok("Saved shopping bag product(id - ${item.id}) succssesfully", shoppingBagWithNewItem);
  }

  CartProductDTO convertStoreProductToCartProduct(ProductDTO productDTO, double quantity) {
    return CartProductDTO(productDTO.id, productDTO.name, productDTO.price, productDTO.category, productDTO.imageUrl,
        productDTO.description, quantity, productDTO.storeID);
  }

  Future<ResultInterface> getOrCreateUserShoppingBagPerStore(String storeID, String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID
            .eq(userID)
            .and(ShoppingBagModel.SHOPPINGBAGMODELONLINESTOREMODELID.eq(storeID)));
    if (shoppingBags.isEmpty) {
      //first time we add a product in a specific store we create a shopping bag
      ShoppingBagModel shoppingBagModel =
          new ShoppingBagModel(usermodelID: userID, shoppingBagModelOnlineStoreModelId: storeID);
      await Amplify.DataStore.save(shoppingBagModel);
      FLog.info(text: "Created new shopping bag for store $storeID and user $userID");
      return new Ok("Created new shopping bag for store $storeID and user $userID", shoppingBagModel);
    }
    FLog.info(
        text: "Found shopping bag for store $storeID and user $userID");
    return new Ok("Found shopping bag for store $storeID and user $userID", shoppingBags[0]);
  }

  Future<ResultInterface> getCurrentShoppingBag(String storeID, String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID
            .eq(userID)
            .and(ShoppingBagModel.SHOPPINGBAGMODELONLINESTOREMODELID.eq(storeID)));
    if (shoppingBags.isEmpty) {
      FLog.error(text: "There is no shopping bag for user $userID");
      return new Failure("There is no shopping bag for user $userID", null);
    }

    return convertShoppingBagModelToDTO(shoppingBags[0]);
  }

  Future<ResultInterface> getProductsOfShoppingBag(String shoppingBagID) async {
    List<CartProductModel> items = await Amplify.DataStore.query(CartProductModel.classType,
        where: CartProductModel.SHOPPINGBAGMODELID.eq(shoppingBagID));
    if (items.isEmpty) {
      FLog.error(text: "No products in shoppingbag $shoppingBagID");
      return new Failure("No products in shoppingbag $shoppingBagID", shoppingBagID);
    }
    FLog.info(text: "Found products in shopping bag $shoppingBagID");
    return new Ok("Found products in shopping bag $shoppingBagID", items);
  }

  Future<ResultInterface> convertShoppingBagModelToDTO(ShoppingBagModel shoppingBagModel) async {
    ResultInterface res = await getProductsOfShoppingBag(shoppingBagModel.id);
    if (!res.getTag()) return res;
    List<CartProductModel> vals = res.getValue() as List<CartProductModel>;
    ShoppingBagDTO shoppingBag =
        ShoppingBagDTO(shoppingBagModel.usermodelID, shoppingBagModel.shoppingBagModelOnlineStoreModelId!);
    List<CartProductDTO> shoppingBagProductsDTO =
        vals.map((e) => convertCartProductModelToDTO(e, shoppingBagModel.shoppingBagModelOnlineStoreModelId!)).toList();
    shoppingBag.products = shoppingBagProductsDTO;
    return new Ok("convert was succsseful", shoppingBag);
  }

  CartProductDTO convertCartProductModelToDTO(CartProductModel cartProductModel, String storeID) {
    return CartProductDTO(
        cartProductModel.id,
        cartProductModel.name,
        cartProductModel.price,
        jsonDecode(cartProductModel.categories).toString(),
        cartProductModel.imageUrl == null ? "" : cartProductModel.imageUrl!,
        cartProductModel.description == null ? "" : cartProductModel.description!,
        cartProductModel.amount,
        storeID);
  }

  Future<ResultInterface> removeProductFromShoppingBag(ProductDTO productDTO, String storeID, String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID
            .eq(userID)
            .and(ShoppingBagModel.SHOPPINGBAGMODELONLINESTOREMODELID.eq(storeID)));

    if (shoppingBags.isEmpty) {
      FLog.error(
          text: "No shopping bag was found for store $storeID and user $userID");
      return new Failure("No shopping bag was found for store $storeID and user $userID", null);
    }

    var shoppingBag = shoppingBags.first; //one shopping bag per user per store
    ResultInterface res = await getProductsOfShoppingBag(shoppingBag.id);
    if (!res.getTag()) return res;
    List<CartProductModel> vals = res.getValue() as List<CartProductModel>;
    CartProductModel? prodToRemove = vals.firstWhere((element) => element.id == productDTO.id, orElse: null);
    vals.removeWhere((element) => element.id == productDTO.id);
    if (prodToRemove != null) {
      await Amplify.DataStore.delete(prodToRemove);
    }

    if (vals.isEmpty) // no more products in bag - need to remove bag
    {
      await Amplify.DataStore.delete(shoppingBag);
      FLog.info(text: "Removed product ${productDTO.id} and shopping bag ${shoppingBag.id}");
      return Ok("Removed product ${productDTO.id} and shopping bag ${shoppingBag.id}", null);
    }
    var newShoppingBag = shoppingBag.copyWith(CartProductModels: vals);
    await Amplify.DataStore.save(newShoppingBag);
    FLog.info(text: "Succssesfully removed product ${productDTO.id} from shopping bag ${shoppingBag.id}");
    return new Ok("Succssesfully removed product ${productDTO.id} from shopping bag ${shoppingBag.id}", newShoppingBag);
  }

  Future<ResultInterface> updateProductQuantityInBag(
      ProductDTO productDTO, String storeID, double quantity, String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID
            .eq(userID)
            .and(ShoppingBagModel.SHOPPINGBAGMODELONLINESTOREMODELID.eq(storeID)));

    if (shoppingBags.isEmpty) {
      FLog.error(text: "No shopping bag was found for store $storeID and user $userID");
      return new Failure("No shopping bag was found for store $storeID and user $userID", null);
    }

    var shoppingBag = shoppingBags.first;
    var productsRes = await getProductsOfShoppingBag(shoppingBag.id);
    if (!productsRes.getTag()) return productsRes;
    var productToUpdate = (productsRes.getValue() as List<CartProductModel>)
        .firstWhere((element) => element.id == productDTO.id, orElse: null);
    if (productToUpdate == null) {
      FLog.error(text: "No Product was found to update");
      return new Failure("No Product was found to update", null);
    }

    var newProd = productToUpdate.copyWith(amount: quantity);
    await Amplify.DataStore.save(newProd);
    FLog.error(text: "Updated product ${productDTO.id} succssefully");
    return new Ok("Updated product ${productDTO.id} succssefully", newProd);
  }

  Future<ResultInterface> clearShoppingBagInStore(String storeID, String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID
            .eq(userID)
            .and(ShoppingBagModel.SHOPPINGBAGMODELONLINESTOREMODELID.eq(storeID)));

    if (shoppingBags.isEmpty) {
      FLog.error(
          text: "No shopping bag was found for store $storeID and user $userID");
      return new Failure("No shopping bag was found for store $storeID and user $userID", null);
    }

    await Amplify.DataStore.delete(shoppingBags.first); //only one exists
    FLog.info(text: "Deleted shopping bag ${shoppingBags.first.id}");
    return new Ok("Deleted shopping bag ${shoppingBags.first.id}", shoppingBags.first);
  }

  Future<void> clearAllShoppingBag(String userID) async {
    List<ShoppingBagModel> shoppingBags =
        await Amplify.DataStore.query(ShoppingBagModel.classType, where: ShoppingBagModel.USERMODELID.eq(userID));

    for (ShoppingBagModel model in shoppingBags) {
      await Amplify.DataStore.delete(model);
    }
  }
}
