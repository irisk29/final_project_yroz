import 'dart:convert';

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
      DigitalWalletModel digitalWalletModel = DigitalWalletModel(cashBackAmount: 0);
      UserModel userModel = UserModel(
          email: email,
          name: name,
          imageUrl: imageUrl,
          digitalWalletModel: digitalWalletModel,
          userModelDigitalWalletModelId: digitalWalletModel.id);
      await Amplify.DataStore.save(digitalWalletModel);
      await Amplify.DataStore.save(userModel);
      print("Created user and saved to DB");
      return userModel;
    }
    var user = users.first;
    return createFullUser(user, user.name, user.imageUrl);
  }

  Future<UserModel> createFullUser(UserModel user, String name, String? imageUrl) async {
    List<DigitalWalletModel> digitalWallet = await Amplify.DataStore.query(DigitalWalletModel.classType,
        where: DigitalWalletModel.ID.eq(user.userModelDigitalWalletModelId));

    var resStoreOwner = await getStoreOwnerState(user.email);
    StoreOwnerModel? storeOwner = resStoreOwner.getTag() ? resStoreOwner.getValue() : null;
    DigitalWalletModel? wallet = digitalWallet.isNotEmpty ? digitalWallet.first : null;
    List<ShoppingBagModel> shoppingBags =
        await Amplify.DataStore.query(ShoppingBagModel.classType, where: ShoppingBagModel.USERMODELID.eq(user.id));
    //TODO: fetch products for shopping bag
    StoreOwnerModel? storeOwner = resStoreOwner.getTag() ? resStoreOwner.getValue() : null;
    DigitalWalletModel? wallet = digitalWallet.isNotEmpty ? digitalWallet.first : null;
    List<ShoppingBagModel> shoppingBags =
        await Amplify.DataStore.query(ShoppingBagModel.classType, where: ShoppingBagModel.USERMODELID.eq(user.id));

    UserModel fullUser = user.copyWith(
        id: user.id,
        email: user.email,
        name: name,
        imageUrl: imageUrl,
        creditCards: user.creditCards,
        bankAccount: user.bankAccount,
        shoppingBagModels: shoppingBags,
        storeOwnerModel: storeOwner,
        digitalWalletModel: wallet,
        userModelStoreOwnerModelId: storeOwner == null ? "" : storeOwner.id,
        userModelDigitalWalletModelId: wallet == null ? "" : wallet.id);
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
      throw Exception("current user model is null, user's email: " + emailCurrUser);
    }
    return currUser.userModelStoreOwnerModelId;
  }

  Future<ResultInterface> getStoreOwnerState(String emailCurrUser) async {
    UserModel? currUser = await getUser(emailCurrUser);
    if (currUser == null) {
      return new Failure("current user model is null", emailCurrUser);
    }
    List<StoreOwnerModel> storeOwners = await Amplify.DataStore.query(StoreOwnerModel.classType,
        where: StoreOwnerModel.ID.eq(currUser.userModelStoreOwnerModelId));
    if (storeOwners.isEmpty) return new Failure("There is no store owner state", null);
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
      return new Failure("current user model is null ", emailCurrUser);
    }
    List<StoreOwnerModel> storeOwners = await Amplify.DataStore.query(StoreOwnerModel.classType,
        where: StoreOwnerModel.ID.eq(currUser.userModelStoreOwnerModelId));
    var storeOwner = storeOwners.isEmpty ? null : storeOwners.first;
    if (storeOwner == null) return new Failure("No store owner state", emailCurrUser);
    if (storeOwner.storeOwnerModelOnlineStoreModelId != null &&
        storeOwner.storeOwnerModelPhysicalStoreModelId != null) {
      return new Ok("No need to delete - there were 2 stores open", null);
    }
    await Amplify.DataStore.delete(storeOwner);
    return new Ok("Deleted store owner state succssefully", storeOwner.id);
  }

  void addOnlineStoreToStoreOwnerState(OnlineStoreModel onlineStore) async {
    ResultInterface oldStoreOwnerRes = await getStoreOwnerState(UserAuthenticator().getCurrentUserId());
    if (!oldStoreOwnerRes.getTag()) {
      //TODO: write to log
      print(oldStoreOwnerRes.getMessage());
    }
    var oldStoreOwner = oldStoreOwnerRes.getValue();
    StoreOwnerModel updatedStoreOwner = oldStoreOwner.copyWith(
        id: oldStoreOwner.id,
        onlineStoreModel: onlineStore,
        physicalStoreModel: oldStoreOwner.physicalStoreModel,
        storeOwnerModelOnlineStoreModelId: onlineStore.id,
        storeOwnerModelPhysicalStoreModelId: oldStoreOwner.storeOwnerModelPhysicalStoreModelId);
    await Amplify.DataStore.save(updatedStoreOwner);
  }

  void addPhysicalStoreToStoreOwnerState(PhysicalStoreModel physicalStore) async {
    ResultInterface oldStoreOwnerRes = await getStoreOwnerState(UserAuthenticator().getCurrentUserId());
    if (!oldStoreOwnerRes.getTag()) {
      //TODO: write to log
      print(oldStoreOwnerRes.getMessage());
    }
    var oldStoreOwner = oldStoreOwnerRes.getValue();
    StoreOwnerModel updatedStoreOwner = oldStoreOwner.copyWith(
        id: oldStoreOwner.id,
        onlineStoreModel: oldStoreOwner.onlineStoreModel,
        physicalStoreModel: physicalStore,
        storeOwnerModelOnlineStoreModelId: oldStoreOwner.storeOwnerModelOnlineStoreModelId,
        storeOwnerModelPhysicalStoreModelId: physicalStore.id);
    await Amplify.DataStore.save(updatedStoreOwner);
  }

  Future<ResultInterface> updateUserNameOrUrl(String newName, String newImageUrl) async {
    var user = await getUser(UserAuthenticator().getCurrentUserId());
    if (user == null) {
      //TODO: write to log
      return new Failure("No user was found", null);
    }
    var nameUpdate = newName.isEmpty ? user.name : newName;
    var urlUpdate = newImageUrl.isEmpty ? user.imageUrl : newImageUrl;
    var fullUser = await createFullUser(user, nameUpdate, urlUpdate);
    await Amplify.DataStore.save(fullUser);
    return new Ok("new name $newName or new image url $newImageUrl was updated", user.id);
  }

  Future<ResultInterface> addProductToShoppingBag(
      ProductDTO productDTO, String storeID, int quantity, String userID) async {
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
    return new Ok("Saved shopping bag product(id - ${item.id}) succssesfully", shoppingBagWithNewItem);
  }

  CartProductDTO convertStoreProductToCartProduct(ProductDTO productDTO, int quantity) {
    return CartProductDTO(productDTO.id, productDTO.name, productDTO.price, productDTO.category, productDTO.imageUrl,
        productDTO.description, quantity);
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
      return new Ok("Created new shopping bag for store $storeID and user $userID", shoppingBagModel);
    }

    return new Ok("Found shopping bag for store $storeID and user $userID", shoppingBags[0]);
  }

  Future<ResultInterface> getProductsOfShoppingBag(String shoppingBagID) async {
    List<CartProductModel> items = await Amplify.DataStore.query(CartProductModel.classType,
        where: CartProductModel.SHOPPINGBAGMODELID.eq(shoppingBagID));
    if (items.isEmpty) return new Failure("No products in shoppingbag $shoppingBagID", shoppingBagID);
    return new Ok("Found products in shopping bag $shoppingBagID", items);
  }

  Future<ResultInterface> convertShoppingBagModelToDTO(ShoppingBagModel shoppingBagModel) async {
    var res = await getProductsOfShoppingBag(shoppingBagModel.id);
    if (!res.getTag()) return res;
    ShoppingBagDTO shoppingBag =
        ShoppingBagDTO(shoppingBagModel.usermodelID, shoppingBagModel.shoppingBagModelOnlineStoreModelId!);
    var shoppingBagProductsDTO = res.getValue().map((e) => convertCartProductModelToDTO(e)).toList();
    shoppingBag.products = shoppingBagProductsDTO!;
    return new Ok("convert was succsseful", shoppingBag);
  }

  CartProductDTO convertCartProductModelToDTO(CartProductModel cartProductModel) {
    return CartProductDTO(
        cartProductModel.id,
        cartProductModel.name,
        cartProductModel.price,
        jsonDecode(cartProductModel.categories).cast<String>(),
        cartProductModel.imageUrl == null ? "" : cartProductModel.imageUrl!,
        cartProductModel.description == null ? "" : cartProductModel.description!,
        cartProductModel.amount!);
  }

  Future<ResultInterface> removeProductFromShoppingBag(ProductDTO productDTO, String storeID, String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID
            .eq(userID)
            .and(ShoppingBagModel.SHOPPINGBAGMODELONLINESTOREMODELID.eq(storeID)));

    if (shoppingBags.isEmpty) return new Failure("No shopping bag was found for store $storeID and user $userID", null);

    var shoppingBag = shoppingBags.first; //one shopping bag per user per store
    List<CartProductModel> productsInBag = (await getProductsOfShoppingBag(shoppingBag.id)) as List<CartProductModel>;
    productsInBag.removeWhere((element) => element.id == productDTO.id);

    var newShoppingBag = shoppingBag.copyWith(CartProductModels: productsInBag);
    await Amplify.DataStore.save(newShoppingBag);
    return new Ok("Succssesfully removed product ${productDTO.id} from shopping bag ${shoppingBag.id}", newShoppingBag);
  }

  Future<ResultInterface> updateProductQuantityInBag(
      ProductDTO productDTO, String storeID, int quantity, String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID
            .eq(userID)
            .and(ShoppingBagModel.SHOPPINGBAGMODELONLINESTOREMODELID.eq(storeID)));

    if (shoppingBags.isEmpty) return new Failure("No shopping bag was found for store $storeID and user $userID", null);

    var shoppingBag = shoppingBags.first;
    var productsRes = await getProductsOfShoppingBag(shoppingBag.id);
    if (!productsRes.getTag()) return productsRes;
    var productToUpdate = (productsRes.getValue() as List<CartProductModel>)
        .firstWhere((element) => element.id == productDTO.id, orElse: null);
    if (productToUpdate == null) return new Failure("No Product was found to update", null);

    var newProd = productToUpdate.copyWith(amount: quantity);
    await Amplify.DataStore.save(newProd);
    return new Ok("Updated product ${productDTO.id} succssefully", newProd);
  }

  Future<ResultInterface> clearShoppingBagInStore(String storeID, String userID) async {
    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID
            .eq(userID)
            .and(ShoppingBagModel.SHOPPINGBAGMODELONLINESTOREMODELID.eq(storeID)));

    if (shoppingBags.isEmpty) return new Failure("No shopping bag was found for store $storeID and user $userID", null);

    await Amplify.DataStore.delete(shoppingBags.first); //only one exists
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
