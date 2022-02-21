import 'package:amplify_flutter/amplify.dart';
import 'package:project_demo/DataLayer/user_authenticator.dart';
import 'package:project_demo/models/ModelProvider.dart';

class UsersStorageProxy {
  static final UsersStorageProxy _singleton = UsersStorageProxy._internal();

  factory UsersStorageProxy() {
    return _singleton;
  }

  UsersStorageProxy._internal();

  Future<UserModel> createUser(
      String email, String name, String imageUrl) async {
    List<UserModel> users = await Amplify.DataStore.query(UserModel.classType,
        where: UserModel.EMAIL.eq(email));

    if (users.isEmpty) //no such user in the DB
    {
      DigitalWalletModel digitalWalletModel =
          DigitalWalletModel(cashBackAmount: 0);
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
    UserModel user = users.first;
    List<StoreOwnerModel> storeOwners = await Amplify.DataStore.query(
        StoreOwnerModel.classType,
        where: StoreOwnerModel.ID.eq(user.userModelStoreOwnerModelId));
    StoreOwnerModel storeOwner = null;
    if (!storeOwners.isEmpty) {
      storeOwner = storeOwners.first;
    }

    List<DigitalWalletModel> digitalWallet = await Amplify.DataStore.query(
        DigitalWalletModel.classType,
        where: DigitalWalletModel.ID.eq(user.userModelDigitalWalletModelId));
    DigitalWalletModel wallet = null;
    if (!digitalWallet.isEmpty) {
      wallet = digitalWallet.first;
    }

    List<ShoppingBagModel> shoppingBags = await Amplify.DataStore.query(
        ShoppingBagModel.classType,
        where: ShoppingBagModel.USERMODELID.eq(user.id));

    UserModel fullUser = user.copyWith(
        id: user.id,
        email: user.email,
        name: user.name,
        creditCards: user.creditCards,
        bankAccount: user.bankAccount,
        shoppingBagModel: shoppingBags,
        storeOwnerModel: storeOwner,
        digitalWalletModel: wallet,
        userModelStoreOwnerModelId: storeOwner.id,
        userModelDigitalWalletModelId: wallet.id);
    return fullUser;
  }

  Future<UserModel> getUser(String email) async {
    List<UserModel> users = await Amplify.DataStore.query(UserModel.classType,
        where: UserModel.EMAIL.eq(email));

    return users.isEmpty ? null : users.first;
  }

  Future<String> getStoreOwnerStateId() async {
    String emailCurrUser = UserAuthenticator().getCurrentUserId();
    UserModel currUser = await getUser(emailCurrUser);
    if (currUser == null) {
      throw Exception(
          "current user model is null, user's email: " + emailCurrUser);
    }
    return currUser.userModelStoreOwnerModelId;
  }

  Future<StoreOwnerModel> getStoreOwnerState() async {
    String emailCurrUser = UserAuthenticator().getCurrentUserId();
    UserModel currUser = await getUser(emailCurrUser);
    List<StoreOwnerModel> storeOwners = await Amplify.DataStore.query(
        StoreOwnerModel.classType,
        where: StoreOwnerModel.ID.eq(currUser.userModelStoreOwnerModelId));
    return storeOwners.isEmpty ? null : storeOwners.first;
  }

  void addOnlineStoreToStoreOwnerState(OnlineStoreModel onlineStore) async {
    StoreOwnerModel oldStoreOwner = await getStoreOwnerState();
    StoreOwnerModel updatedStoreOwner = oldStoreOwner.copyWith(
        id: oldStoreOwner.id,
        onlineStoreModel: onlineStore,
        physicalStoreModel: oldStoreOwner.physicalStoreModel,
        storeOwnerModelOnlineStoreModelId: onlineStore.id,
        storeOwnerModelPhysicalStoreModelId:
            oldStoreOwner.storeOwnerModelPhysicalStoreModelId);
    await Amplify.DataStore.save(updatedStoreOwner);
  }

  void addPhysicalStoreToStoreOwnerState(
      PhysicalStoreModel physicalStore) async {
    StoreOwnerModel oldStoreOwner = await getStoreOwnerState();
    StoreOwnerModel updatedStoreOwner = oldStoreOwner.copyWith(
        id: oldStoreOwner.id,
        onlineStoreModel: oldStoreOwner.onlineStoreModel,
        physicalStoreModel: physicalStore,
        storeOwnerModelOnlineStoreModelId:
            oldStoreOwner.storeOwnerModelOnlineStoreModelId,
        storeOwnerModelPhysicalStoreModelId: physicalStore.id);
    await Amplify.DataStore.save(updatedStoreOwner);
  }
}
