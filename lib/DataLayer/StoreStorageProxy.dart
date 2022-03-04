import 'dart:io';
import 'dart:ui';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/PhysicalStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/Result/Failure.dart';
import 'package:final_project_yroz/Result/OK.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/models/OnlineStoreModel.dart';
import 'package:final_project_yroz/models/PhysicalStoreModel.dart';
import 'package:final_project_yroz/models/ProductModel.dart';
import 'package:final_project_yroz/models/StoreOwnerModel.dart';
import 'package:final_project_yroz/models/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:tuple/tuple.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'UsersStorageProxy.dart';

class StoreStorageProxy {
  static final StoreStorageProxy _singleton = StoreStorageProxy._internal();

  factory StoreStorageProxy() {
    return _singleton;
  }

  StoreStorageProxy._internal();

  Future<ResultInterface> openOnlineStore(StoreDTO store) async {
    OnlineStoreModel onlineStoreModel = OnlineStoreModel(
        name: store.name,
        phoneNumber: store.phoneNumber,
        address: store.address,
        categories: JsonEncoder.withIndent('  ').convert(store.categories),
        operationHours: JsonEncoder.withIndent('  ', (value) {
          if (value is TimeOfDay) {
            final now = new DateTime.now();
            final dt = DateTime(now.year, now.month, now.day, value.hour, value.minute);
            final format = DateFormat.jm();
            return format.format(dt);
          } else {
            return value.toJson();
          }
        }).convert(store.operationHours));
    ResultInterface storeOwnerRes = await UsersStorageProxy().getStoreOwnerState();
    StoreOwnerModel? storeOwner = null;
    if (!storeOwnerRes.getTag()) {
      //the user will now have a store owner state
      storeOwner =
          StoreOwnerModel(onlineStoreModel: onlineStoreModel, storeOwnerModelOnlineStoreModelId: onlineStoreModel.id);
      UserModel? oldUserModel = await UsersStorageProxy().getUser(UserAuthenticator().getCurrentUserId());
      if (oldUserModel == null) {
        return new Failure("no such user exists in the system!", null);
      }
      UserModel newUserModel = oldUserModel.copyWith(
          id: oldUserModel.id,
          email: oldUserModel.email,
          name: oldUserModel.name,
          imageUrl: oldUserModel.imageUrl,
          creditCards: oldUserModel.creditCards,
          bankAccount: oldUserModel.bankAccount,
          shoppingBagModels: oldUserModel.shoppingBagModels,
          storeOwnerModel: storeOwner,
          digitalWalletModel: oldUserModel.digitalWalletModel,
          userModelDigitalWalletModelId: oldUserModel.userModelDigitalWalletModelId,
          userModelStoreOwnerModelId: storeOwner.id);
      await Amplify.DataStore.save(onlineStoreModel);
      await Amplify.DataStore.save(storeOwner);
      await Amplify.DataStore.save(newUserModel);
    } else if (!storeOwnerRes.getValue().storeOwnerModelOnlineStoreModelId!.isEmpty) // already have an online store
        {
      //TODO: write the exception to log
      return new Failure("User already has online store - only one is allowed!", "");
    } else //we have a store owner state but not an online store
        {
      UsersStorageProxy().addOnlineStoreToStoreOwnerState(onlineStoreModel);
    }
    return new Ok("open online store succsseded", Tuple2<OnlineStoreModel, String>(onlineStoreModel, storeOwner!.id));
  }

  //for physical stores only
  Future<String> generateUniqueQRCode() async {
    final image = await QrPainter(
      data: "This is the QRCode for your physical store",
      version: QrVersions.auto,
      gapless: false,
      color: Color(0x000000),
      emptyColor: Color(0xffffff),
    ).toImage(300);
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    return new String.fromCharCodes(bytes!.buffer.asUint8List());
  }

  Future<ResultInterface> openPhysicalStore(StoreDTO store) async {
    PhysicalStoreModel physicalModel = PhysicalStoreModel(
        name: store.name,
        phoneNumber: store.phoneNumber,
        address: store.address,
        categories: JsonEncoder.withIndent('  ').convert(store.categories),
        operationHours: JsonEncoder.withIndent('  ', (value) {
          if (value is TimeOfDay) {
            final now = new DateTime.now();
            final dt = DateTime(now.year, now.month, now.day, value.hour, value.minute);
            final format = DateFormat.jm();
            return format.format(dt);
          } else {
            return value.toJson();
          }
        }).convert(store.operationHours),
        qrCode: await generateUniqueQRCode());
    if (store.image != null) {
      await uploadPicture(store.image!, physicalModel.id); // uploading the picture to s3
    }
    ResultInterface storeOwnerRes = await UsersStorageProxy().getStoreOwnerState();
    StoreOwnerModel? storeOwner = null;
    if (!storeOwnerRes.getTag()) {
      //the user will now have a store owner state
      storeOwner =
          StoreOwnerModel(physicalStoreModel: physicalModel, storeOwnerModelPhysicalStoreModelId: physicalModel.id);
      UserModel? oldUserModel = await UsersStorageProxy().getUser(UserAuthenticator().getCurrentUserId());
      if (oldUserModel == null) {
        return new Failure("no such user exists in the system!", null);
      }

      UserModel newUserModel = oldUserModel.copyWith(
          id: oldUserModel.id,
          email: oldUserModel.email,
          name: oldUserModel.name,
          imageUrl: oldUserModel.imageUrl,
          creditCards: oldUserModel.creditCards,
          bankAccount: oldUserModel.bankAccount,
          shoppingBagModels: oldUserModel.shoppingBagModels,
          storeOwnerModel: storeOwner,
          digitalWalletModel: oldUserModel.digitalWalletModel,
          userModelDigitalWalletModelId: oldUserModel.userModelDigitalWalletModelId,
          userModelStoreOwnerModelId: storeOwner.id);
      await Amplify.DataStore.save(physicalModel);
      await Amplify.DataStore.save(storeOwner);
      await Amplify.DataStore.save(newUserModel);
    } else if (!storeOwnerRes.getValue().storeOwnerModelPhysicalStoreModelId!.isEmpty) // already have an physical store
        {
      //TODO: write the exception to log
      return new Failure("User already has physical store - only one is allowed!", "");
    } else //we have a store owner state but not an physical store
        {
      UsersStorageProxy().addPhysicalStoreToStoreOwnerState(physicalModel);
    }
    return new Ok("open physical store succsseded", Tuple2<PhysicalStoreModel, String>(physicalModel, storeOwner!.id));
  }

  Future<File> createFileFromImageUrl(String url) async {
    final http.Response responseData = await http.get(Uri.parse(url));
    var uint8list = responseData.bodyBytes;
    var buffer = uint8list.buffer;
    ByteData byteData = ByteData.view(buffer);
    var tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/img')
        .writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  Future<ResultInterface> uploadPicture(String url, String storeId) async {
    try {
      File img = await createFileFromImageUrl(url);
      final UploadFileResult result = await Amplify.Storage.uploadFile(
          local: img,
          key: storeId,
          onProgress: (progress) {
            print("Fraction completed: " + progress.getFractionCompleted().toString());
          });
      return new Ok('Successfully uploaded file: ${result.key}', storeId);
    } on StorageException catch (e) {
      return new Failure('Error uploading file: $e', storeId);
    }
  }

  Future<ResultInterface> deletePicture(String storeId) async {
    try {
      final RemoveResult result = await Amplify.Storage.remove(key: storeId);
      return new Ok('Deleted file: ${result.key}', storeId);
    } on StorageException catch (e) {
      return new Failure('Error deleting file: $e', storeId);
    }
  }

  Future<ResultInterface> updatePicture(String url, String storeId) async {
    var res = await deletePicture(storeId);
    return res.getTag() ? await uploadPicture(url, storeId) : res;
  }

  Future<OnlineStoreModel?> fetchOnlineStore() async {
    ResultInterface storeOwnerRes = await UsersStorageProxy().getStoreOwnerState();
    if (!storeOwnerRes.getTag()) {
      List<OnlineStoreModel> onlineStores = await Amplify.DataStore.query(OnlineStoreModel.classType,
          where: OnlineStoreModel.ID.eq(storeOwnerRes.getValue().storeOwnerModelOnlineStoreModelId));
      if (onlineStores.isEmpty) return null;
      return onlineStores.first; //only one online store per user
    }
  }

  Future<PhysicalStoreModel?> fetchPhysicalStore() async {
    try {
      ResultInterface storeOwnerRes = await UsersStorageProxy().getStoreOwnerState();
      if (!storeOwnerRes.getTag()) {
        List<PhysicalStoreModel> physicalStores = await Amplify.DataStore.query(PhysicalStoreModel.classType,
            where: PhysicalStoreModel.ID.eq(storeOwnerRes.getValue().storeOwnerModelPhysicalStoreModelId));

        if (physicalStores.isEmpty) return null;
        return physicalStores.first; //only one physical store per user
      }
    } on Exception {
      // TODO: write to log
    }
  }

  Future<List<PhysicalStoreDTO>> fetchAllPhysicalStores() async {
    try {
      List<PhysicalStoreModel> physicalStores = await Amplify.DataStore.query(PhysicalStoreModel.classType);
      return convertPhysicalStoreModelToDTO(physicalStores); //only one physical store per user
    } on Exception catch (e) {
      // TODO: write to log
      throw e;
    }
  }

  Future<String> getDownloadUrl(String keyName) async {
    try {
      final GetUrlResult result = await Amplify.Storage.getUrl(key: keyName);
      print('Got URL: ${result.url}');
      return result.url;
    } on StorageException catch (e) {
      print('Error getting download URL: $e');
      throw e;
      //TODO: write to log
    }
  }

  Future<List<PhysicalStoreDTO>> convertPhysicalStoreModelToDTO(List<PhysicalStoreModel> physicalStores) async {
    List<PhysicalStoreDTO> lst = [];
    for (PhysicalStoreModel model in physicalStores) {
      String url = await getDownloadUrl(model.id);
      PhysicalStoreDTO dto = PhysicalStoreDTO(
          model.id,
          model.name,
          model.address,
          model.phoneNumber,
          jsonDecode(model.categories).cast<String>(),
          jsonDecode(model.operationHours).cast<String, List<TimeOfDay>>(),
          url,
          model.qrCode);
      await dto.initImageFile();
      lst.add(dto);
    }
    return lst;
  }

  Future<List<OnlineStoreModel>?> fetchAllOnlineStores() async {
    try {
      List<OnlineStoreModel> onlineStores = await Amplify.DataStore.query(OnlineStoreModel.classType);
      if (onlineStores.isEmpty) return null;
      return onlineStores; //only one physical store per user
    } on Exception catch (e) {
      // TODO: write to log
    }
    return null;
  }

  Future<ResultInterface> createProductForOnlineStore(ProductDTO productDTO) async {
    try {
      OnlineStoreModel? onlineStoreModel = await fetchOnlineStore();
      if (onlineStoreModel == null) {
        //TODO: write error to log
        return new Failure("no online store exists!", null);
      }
      ProductModel productModel = ProductModel(
          name: productDTO.name,
          imageUrl: productDTO.imageUrl,
          price: productDTO.price,
          categories: jsonEncode(productDTO.categories),
          description: productDTO.description,
          onlinestoremodelID: onlineStoreModel.id, shoppingbagmodelID: '');

      onlineStoreModel.productModel!.add(productModel);
      OnlineStoreModel updatedOnlineStore = onlineStoreModel.copyWith(
        id: onlineStoreModel.id,
        address: onlineStoreModel.address,
        operationHours: onlineStoreModel.operationHours,
        phoneNumber: onlineStoreModel.phoneNumber,
        categories: onlineStoreModel.categories,
        name: onlineStoreModel.name,
        productModel: onlineStoreModel.productModel,
      );
      await Amplify.DataStore.save(productModel);
      await Amplify.DataStore.save(updatedOnlineStore);
      return new Ok(
          "created product with ID: ${productModel.id} andd added it to the online store: ${onlineStoreModel.id}",
          productModel);
    } on Exception catch (e) {
      // TODO: write to log
      return new Failure(e.toString(), null);
    }
  }

  Future<ResultInterface> updatePhysicalStore(PhysicalStoreDTO newStore) async {
    try {
      List<PhysicalStoreModel> physicalStores =
      await Amplify.DataStore.query(PhysicalStoreModel.classType, where: PhysicalStoreModel.ID.eq(newStore.id));
      if (physicalStores.isEmpty) {
        return new Failure("No physical store is found!", null);
      }
      PhysicalStoreModel updatedStore = physicalStores[0].copyWith(
          id: newStore.id,
          name: newStore.name,
          phoneNumber: newStore.phoneNumber,
          address: newStore.address,
          categories: JsonEncoder.withIndent('  ').convert(newStore.categories),
          operationHours: JsonEncoder.withIndent('  ').convert(newStore.operationHours),
          qrCode: await generateUniqueQRCode());
      if(newStore.image != null && newStore.image!.compareTo(await getDownloadUrl(newStore.id)) == 0) //changed the picture
          {
        updatePicture(newStore.image!, newStore.id);
      }
      await Amplify.DataStore.save(updatedStore);
      return new Ok("updated physical store succssefully", updatedStore);
    } on Exception catch (e) {
      // TODO: write to log
      throw e;
    }
  }

  Future<ResultInterface> updateOnlineStore(StoreDTO newStore) async {
    try {
      List<OnlineStoreModel> onlineStores =
      await Amplify.DataStore.query(OnlineStoreModel.classType, where: OnlineStoreModel.ID.eq(newStore.id));
      if (onlineStores.isEmpty) {
        return new Failure("No online store is found!", null);
      }
      OnlineStoreModel updatedStore = onlineStores[0].copyWith(
          id: newStore.id,
          name: newStore.name,
          phoneNumber: newStore.phoneNumber,
          address: newStore.address,
          categories: JsonEncoder.withIndent('  ').convert(newStore.categories),
          operationHours: JsonEncoder.withIndent('  ').convert(newStore.operationHours));
      if(newStore.image != null && newStore.image!.compareTo(await getDownloadUrl(newStore.id)) == 0) //changed the picture
          {
        updatePicture(newStore.image!, newStore.id);
      }
      await Amplify.DataStore.save(updatedStore);
      return new Ok("updated online store succssefully", updatedStore);
    } on Exception catch (e) {
      // TODO: write to log
      throw e;
    }
  }

  Future<ResultInterface> deleteStore(String id, bool isOnline) async {
    try {
      var res = isOnline ? await deleteOnlineStore(id) : await deletePhysicalStore(id);
      if (!res.getTag()) return res; //failure occured
      var msg = res.getMessage();
      res = await UsersStorageProxy().deleteStoreOwnerState();
      if (!res.getTag()) return res; //failure occured
      return new Ok(res.getMessage() + " " + msg, id);
    } on Exception catch (e) {
      // TODO: write to log
      return new Failure(e.toString(), null);
    }
  }

  Future<ResultInterface> deleteOnlineStore(String id) async {
    try {
      List<OnlineStoreModel> stores =
      await Amplify.DataStore.query(OnlineStoreModel.classType, where: OnlineStoreModel.ID.eq(id));
      if (stores.isEmpty) {
        return new Failure("No such store", id);
      }
      await Amplify.DataStore.delete(stores[0]); //only 1 store per user
      return new Ok("Deleted online store succssefully", id);
    } on Exception catch (e) {
      // TODO: write to log
      return new Failure(e.toString(), id);
    }
  }

  Future<ResultInterface> deletePhysicalStore(String id) async {
    try {
      List<PhysicalStoreModel> stores =
      await Amplify.DataStore.query(PhysicalStoreModel.classType, where: PhysicalStoreModel.ID.eq(id));
      if (stores.isEmpty) {
        return new Failure("No such store", id);
      }
      await Amplify.DataStore.delete(stores[0]); //only 1 store per user
      return new Ok("Deleted physical store succssefully", id);
    } on Exception catch (e) {
      // TODO: write to log
      return new Failure(e.toString(), id);
    }
  }
}