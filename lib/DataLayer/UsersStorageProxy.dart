import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/Result/Failure.dart';
import 'package:final_project_yroz/Result/OK.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/models/DigitalWalletModel.dart';
import 'package:final_project_yroz/models/OnlineStoreModel.dart';
import 'package:final_project_yroz/models/PhysicalStoreModel.dart';
import 'package:final_project_yroz/models/ShoppingBagModel.dart';
import 'package:final_project_yroz/models/StoreOwnerModel.dart';
import 'package:final_project_yroz/models/UserModel.dart';

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
      print("current user model is null, user's email: " + emailCurrUser);
      return null;
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
}
