import 'dart:io';
import 'dart:ui';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/Result/Failure.dart';
import 'package:final_project_yroz/Result/OK.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/models/CartProductModel.dart';
import 'package:final_project_yroz/models/OnlineStoreModel.dart';
import 'package:final_project_yroz/models/PhysicalStoreModel.dart';
import 'package:final_project_yroz/models/StoreOwnerModel.dart';
import 'package:final_project_yroz/models/StoreProductModel.dart';
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

  Future<ResultInterface> openOnlineStore(OnlineStoreDTO store) async {
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

    String? qrCode = store.qrCode;
    if (store.qrCode == null || store.qrCode!.isEmpty) {
      qrCode = await generateUniqueQRCode(onlineStoreModel.id);
      onlineStoreModel = onlineStoreModel.copyWith(qrCode: qrCode);
    }
    if (store.image != null && store.image!.isNotEmpty) {
      await uploadPicture(store.image!, onlineStoreModel.id); // uploading the picture to s3
    }

    List<StoreProductModel> productsModel = [];
    for (ProductDTO prod in store.products) {
      var res = await createProductForOnlineStore(prod, onlineStoreModel.id);
      if (!res.getTag()) return res;
      productsModel.add(res.getValue());
    }

    var onlineWithProducts = onlineStoreModel.copyWith(
        id: onlineStoreModel.id,
        name: onlineStoreModel.name,
        phoneNumber: onlineStoreModel.phoneNumber,
        address: onlineStoreModel.address,
        operationHours: onlineStoreModel.operationHours,
        categories: onlineStoreModel.categories,
        storeProductModels: productsModel);
    await Amplify.DataStore.save(onlineWithProducts);

    ResultInterface storeOwnerRes =
        await UsersStorageProxy().getStoreOwnerState(UserAuthenticator().getCurrentUserId());
    StoreOwnerModel? storeOwner = null;
    if (!storeOwnerRes.getTag()) {
      //the user will now have a store owner state
      storeOwner = StoreOwnerModel(
          onlineStoreModel: onlineWithProducts, storeOwnerModelOnlineStoreModelId: onlineWithProducts.id);
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
      await Amplify.DataStore.save(onlineWithProducts);
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
    return new Ok("open online store succeeded", Tuple2<OnlineStoreModel, String>(onlineWithProducts, storeOwner!.id));
  }

  //for physical stores only
  Future<String> generateUniqueQRCode(String storeID) async {
    final image = await QrPainter(
      data: storeID,
      version: QrVersions.auto,
      gapless: false,
      color: Color(0x000000),
      emptyColor: Color(0xffffff),
    ).toImage(300);
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    return new String.fromCharCodes(bytes!.buffer.asUint8List());
  }

  Future<ResultInterface> openPhysicalStore(StoreDTO store) async {
    PhysicalStoreModel physicalModelWithoutQR = PhysicalStoreModel(
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

    String qrCode = await generateUniqueQRCode(physicalModelWithoutQR.id);
    var physicalModel = physicalModelWithoutQR.copyWith(qrCode: qrCode);
    if (store.image != null) {
      await uploadPicture(store.image!, physicalModel.id); // uploading the picture to s3
    }
    ResultInterface storeOwnerRes =
        await UsersStorageProxy().getStoreOwnerState(UserAuthenticator().getCurrentUserId());
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

  Future<OnlineStoreModel?> fetchOnlineStore(String? storeOwnerOnlineStoreId) async {
    if (storeOwnerOnlineStoreId == null) return null;
    List<OnlineStoreModel> onlineStores = await Amplify.DataStore.query(OnlineStoreModel.classType,
        where: OnlineStoreModel.ID.eq(storeOwnerOnlineStoreId));
    if (onlineStores.isEmpty) return null;
    var onlinestore = onlineStores.first;
    List<StoreProductModel> products = await Amplify.DataStore.query(StoreProductModel.classType,
        where: StoreProductModel.ONLINESTOREMODELID.eq(onlinestore.id));

    var fullStore = onlinestore.copyWith(storeProductModels: products);
    return fullStore; //only one online store per user
  }

  Future<PhysicalStoreModel?> fetchPhysicalStore(String? storeOwnerPhysicalStoreId) async {
    if (storeOwnerPhysicalStoreId == null) return null;
    List<PhysicalStoreModel> physicalStores = await Amplify.DataStore.query(PhysicalStoreModel.classType,
        where: PhysicalStoreModel.ID.eq(storeOwnerPhysicalStoreId));

    if (physicalStores.isEmpty) return null;
    return physicalStores.first; //only one physical store per user
  }

  Future<List<StoreDTO>> fetchAllPhysicalStores() async {
    try {
      List<PhysicalStoreModel> physicalStores = await Amplify.DataStore.query(PhysicalStoreModel.classType);
      return convertPhysicalStoreModelToDTO(physicalStores); //only one physical store per user
    } on Exception catch (e) {
      // TODO: write to log
      throw e;
    }
  }

  Future<List<OnlineStoreDTO>> fetchAllOnlineStores() async {
    try {
      List<OnlineStoreModel> onlineStores = await Amplify.DataStore.query(OnlineStoreModel.classType);
      return convertOnlineStoreModelToDTO(onlineStores); //only one online store per user
    } on Exception catch (e) {
      // TODO: write to log
      throw e;
    }
  }

  Future<List<StoreDTO>> fetchAllStores() async {
    try {
      List<OnlineStoreModel> onlineStores = await Amplify.DataStore.query(OnlineStoreModel.classType);
      List<PhysicalStoreModel> physicalStores = await Amplify.DataStore.query(PhysicalStoreModel.classType);
      List<OnlineStoreDTO> onlineDtos = await convertOnlineStoreModelToDTO(onlineStores);
      List<StoreDTO> physicalDtos = await convertPhysicalStoreModelToDTO(physicalStores);
      List<StoreDTO> allDtos = onlineDtos;
      allDtos.addAll(physicalDtos);
      return allDtos;
    } on Exception catch (e) {
      // TODO: write to log
      throw e;
    }
  }

  Future<List<ProductDTO>> fetchStoreProducts(String storeId) async {
    List<StoreProductModel> products = await Amplify.DataStore.query(StoreProductModel.classType,
        where: StoreProductModel.ONLINESTOREMODELID.eq(storeId));
    return products
        .map((e) => ProductDTO(
            id: e.id,
            name: e.name,
            price: e.price,
            category: e.categories.isEmpty ? "" : jsonDecode(e.categories).cast<String>(),
            imageUrl: e.imageUrl!,
            description: e.description!))
        .toList();
  }

  Future<List<StoreDTO>> fetchStoresByKeywords(String keywords) async {
    try {
      List<PhysicalStoreModel> physicalStores = await Amplify.DataStore.query(
        PhysicalStoreModel.classType,
        where: PhysicalStoreModel.NAME
            .contains(keywords)
            .or(PhysicalStoreModel.ADDRESS.contains(keywords))
            .or(PhysicalStoreModel.CATEGORIES.contains(keywords)),
      );
      List<OnlineStoreModel> onlineStores = await Amplify.DataStore.query(
        OnlineStoreModel.classType,
        where: OnlineStoreModel.NAME
            .contains(keywords)
            .or(OnlineStoreModel.ADDRESS.contains(keywords))
            .or(OnlineStoreModel.CATEGORIES.contains(keywords)),
      );
      List<StoreDTO> physicalDtos = await convertPhysicalStoreModelToDTO(physicalStores);
      List<OnlineStoreDTO> onlineDtos = await convertOnlineStoreModelToDTO(onlineStores);

      List<StoreDTO> allDtos = List.generate(onlineDtos.length, (index) => onlineDtos[index]);
      allDtos.addAll(physicalDtos);
      return allDtos;
    } on Exception catch (e) {
      // TODO: write to log
      throw e;
    }
  }

  Future<String?> getDownloadUrl(String keyName) async {
    try {
      final ListResult storageItems = await Amplify.Storage.list();
      final item = storageItems.items.where((element) => element.key == keyName);
      if (item.isEmpty) return null;
      final GetUrlResult result = await Amplify.Storage.getUrl(key: keyName);
      print('Got URL: ${result.url}');
      return result.url;
    } on StorageException catch (e) {
      print('Error getting download URL: $e');
      throw e;
      //TODO: write to log
    }
  }

  Future<List<StoreDTO>> convertPhysicalStoreModelToDTO(List<PhysicalStoreModel> physicalStores) async {
    List<StoreDTO> lst = [];
    for (PhysicalStoreModel model in physicalStores) {
      String? url = await getDownloadUrl(model.id);
      StoreDTO dto = StoreDTO(
          id: model.id,
          name: model.name,
          address: model.address,
          phoneNumber: model.phoneNumber,
          categories: jsonDecode(model.categories).cast<String>(),
          operationHours: opHours(jsonDecode(model.operationHours)),
          image: url,
          qrCode: model.qrCode!);
      await dto.initImageFile();
      lst.add(dto);
    }
    return lst;
  }

  Future<List<OnlineStoreDTO>> convertOnlineStoreModelToDTO(List<OnlineStoreModel> onlineStores) async {
    List<OnlineStoreDTO> lst = [];
    for (OnlineStoreModel model in onlineStores) {
      String? url = await getDownloadUrl(model.id);
      OnlineStoreDTO dto = OnlineStoreDTO(
          id: model.id,
          name: model.name,
          address: model.address,
          phoneNumber: model.phoneNumber,
          categories: jsonDecode(model.categories).cast<String>(),
          operationHours: opHours(jsonDecode(model.operationHours)),
          image: url,
          products: await fetchStoreProducts(model.id),
          qrCode: model.qrCode);
      await dto.initImageFile();
      lst.add(dto);
    }
    return lst;
  }

  List<ProductDTO> convertProductModelToDTO(List<StoreProductModel> products) {
    List<ProductDTO> lst = [];
    for (StoreProductModel model in products) {
      ProductDTO dto = ProductDTO(
          id: model.id,
          name: model.name,
          price: model.price,
          category: jsonDecode(model.categories).cast<List<String>>(),
          imageUrl: model.imageUrl!,
          description: model.description!);
      lst.add(dto);
    }
    return lst;
  }

  Map<String, List<TimeOfDay>> opHours(Map<String, dynamic> oper) {
    Map<String, List<TimeOfDay>> map = {};
    for (MapEntry e in oper.entries) {
      List<TimeOfDay> l = [];
      for (dynamic d in e.value) {
        l.add(TimeOfDay.fromDateTime(DateFormat.jm().parse(d.toString())));
      }
      map.addEntries([MapEntry(e.key, l)]);
    }
    return map;
  }

  Future<ResultInterface> createProductForOnlineStore(ProductDTO productDTO, String onlineStoreModelID) async {
    try {
      StoreProductModel productModel = StoreProductModel(
          name: productDTO.name,
          imageUrl: productDTO.imageUrl,
          price: productDTO.price,
          categories: productDTO.category,
          description: productDTO.description,
          onlinestoremodelID: onlineStoreModelID);
      if (productDTO.imageUrl.isNotEmpty) {
        await uploadPicture(productDTO.imageUrl, productModel.id); // uploading the picture to s3
      }
      await Amplify.DataStore.save(productModel);
      return new Ok(
          "created product with ID: ${productModel.id} and added it to the online store: ${onlineStoreModelID}",
          productModel);
    } on Exception catch (e) {
      // TODO: write to log
      return new Failure(e.toString(), null);
    }
  }

  Future<ResultInterface> updatePhysicalStore(StoreDTO newStore) async {
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
          operationHours: JsonEncoder.withIndent('  ', (value) {
            if (value is TimeOfDay) {
              final now = new DateTime.now();
              final dt = DateTime(now.year, now.month, now.day, value.hour, value.minute);
              final format = DateFormat.jm();
              return format.format(dt);
            } else {
              return value.toJson();
            }
          }).convert(newStore.operationHours),
          qrCode: newStore.qrCode);
      if (newStore.image != null && newStore.image! != await getDownloadUrl(newStore.id)) //changed the picture
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
          operationHours: JsonEncoder.withIndent('  ', (value) {
            if (value is TimeOfDay) {
              final now = new DateTime.now();
              final dt = DateTime(now.year, now.month, now.day, value.hour, value.minute);
              final format = DateFormat.jm();
              return format.format(dt);
            } else {
              return value.toJson();
            }
          }).convert(newStore.operationHours),
          qrCode: newStore.qrCode);
      if (newStore.image != null && newStore.image! != await getDownloadUrl(newStore.id)) //changed the picture
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

  Future<ResultInterface> updateOnlineStoreProducts(List<ProductDTO> products, String storeID) async {
    List<StoreProductModel> products = await Amplify.DataStore.query(StoreProductModel.classType,
        where: StoreProductModel.ONLINESTOREMODELID.eq(storeID));
    if (products.isEmpty) return new Failure("No products were found in store $storeID", storeID);
    for (StoreProductModel prod in products) {
      await Amplify.DataStore.delete(prod);
    }

    List<StoreProductModel> updatedProd = products
        .map((e) => StoreProductModel(
            name: e.name,
            categories: e.categories,
            price: e.price,
            onlinestoremodelID: storeID,
            imageUrl: e.imageUrl,
            description: e.description))
        .toList();

    for (StoreProductModel p in updatedProd) {
      await Amplify.DataStore.save(p);
    }
    return new Ok("Updated products in store $storeID", updatedProd);
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
      var res = await deleteStoreOwnerStateIfNeeded(true);
      if (!res.getTag()) return res;
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
      var res = await deleteStoreOwnerStateIfNeeded(false);
      if (!res.getTag()) return res;
      return new Ok("Deleted physical store succssefully", id);
    } on Exception catch (e) {
      // TODO: write to log
      return new Failure(e.toString(), id);
    }
  }

  Future<ResultInterface> deleteStoreOwnerStateIfNeeded(bool deletedOnlineStore) async {
    String? storeOwnerID = await UsersStorageProxy().getStoreOwnerStateId();
    if (storeOwnerID == null) return new Failure("No store owner to delete", null);
    List<StoreOwnerModel> storeOwners =
        await Amplify.DataStore.query(StoreOwnerModel.classType, where: StoreOwnerModel.ID.eq(storeOwnerID));
    StoreOwnerModel storeOwnerModel = storeOwners.first;
    if (deletedOnlineStore) {
      if (storeOwnerModel.storeOwnerModelPhysicalStoreModelId == null) {
        await Amplify.DataStore.delete(storeOwnerModel); //no store left
        UserModel? currUser = await UsersStorageProxy().getUser(UserAuthenticator().getCurrentUserId());
        if (currUser == null) return Failure("No such user", null);
        UserModel userWithoutStoreOwnerState =
            currUser.copyWith(userModelStoreOwnerModelId: null, storeOwnerModel: null);
        await Amplify.DataStore.save(userWithoutStoreOwnerState);
        return new Ok("Deleted completly Store Owner State", userWithoutStoreOwnerState);
      }
      StoreOwnerModel updatedStoreModel =
          storeOwnerModel.copyWith(onlineStoreModel: null, storeOwnerModelOnlineStoreModelId: null);
      await Amplify.DataStore.save(updatedStoreModel);
      return new Ok("Deleted online store from Store Owner State", updatedStoreModel);
    }

    if (storeOwnerModel.storeOwnerModelOnlineStoreModelId == null) {
      await Amplify.DataStore.delete(storeOwnerModel); //no store left
      UserModel? currUser = await UsersStorageProxy().getUser(UserAuthenticator().getCurrentUserId());
      if (currUser == null) return Failure("No such user", null);
      UserModel userWithoutStoreOwnerState = currUser.copyWith(userModelStoreOwnerModelId: null, storeOwnerModel: null);
      await Amplify.DataStore.save(userWithoutStoreOwnerState);
      return new Ok("Deleted completly Store Owner State", userWithoutStoreOwnerState);
    }
    StoreOwnerModel updatedStoreModel =
        storeOwnerModel.copyWith(physicalStoreModel: null, storeOwnerModelPhysicalStoreModelId: null);
    await Amplify.DataStore.save(updatedStoreModel);
    return new Ok("Deleted online store from Store Owner State", updatedStoreModel);
  }

  Future<ResultInterface> convertPhysicalStoreToOnlineStore(StoreDTO physicalStore) async {
    ResultInterface deletePhysicalRes = await deletePhysicalStore(physicalStore.id);
    if (!deletePhysicalRes.getTag()) return deletePhysicalRes;
    OnlineStoreDTO onlineStoreDTO = OnlineStoreDTO(
        id: physicalStore.id,
        name: physicalStore.name,
        address: physicalStore.address,
        phoneNumber: physicalStore.phoneNumber,
        categories: physicalStore.categories,
        operationHours: physicalStore.operationHours,
        products: [],
        qrCode: physicalStore.qrCode,
        image: physicalStore.image);
    ResultInterface openOnlineStoreRes = await openOnlineStore(onlineStoreDTO);
    return openOnlineStoreRes;
    //Tuple2<OnlineStoreModel, String>
  }

  Future<ResultInterface> getPhysicalStore(String storeID) async {
    List<PhysicalStoreModel> stores =
        await Amplify.DataStore.query(PhysicalStoreModel.classType, where: PhysicalStoreModel.ID.eq(storeID));
    if (stores.isEmpty) return new Failure("No such store $storeID exists", storeID);
    var store = stores.first;
    return new Ok(
        "Found store $storeID",
        StoreDTO(
            id: store.id,
            name: store.name,
            phoneNumber: store.phoneNumber,
            address: store.address,
            categories: store.categories.isEmpty ? "" : jsonDecode(store.categories).cast<String>(),
            operationHours: opHours(jsonDecode(store.operationHours)),
            qrCode: store.qrCode,
            image: await getDownloadUrl(storeID)));
  }

  Future<ResultInterface> getOnlineStore(String storeID) async {
    List<OnlineStoreModel> stores =
        await Amplify.DataStore.query(OnlineStoreModel.classType, where: OnlineStoreModel.ID.eq(storeID));
    if (stores.isEmpty) return new Failure("No such store $storeID exists", storeID);
    var store = stores.first;
    var products = await fetchStoreProducts(store.id);
    return new Ok(
        "Found store $storeID",
        OnlineStoreDTO(
            id: store.id,
            name: store.name,
            phoneNumber: store.phoneNumber,
            address: store.address,
            categories: store.categories.isEmpty ? "" : jsonDecode(store.categories).cast<String>(),
            operationHours: opHours(jsonDecode(store.operationHours)),
            products: products,
            qrCode: store.qrCode,
            image: await getDownloadUrl(storeID)));
  }

  Future<ResultInterface> getOnlineStoreProduct(String prodId) async {
    List<StoreProductModel> prods =
        await Amplify.DataStore.query(StoreProductModel.classType, where: StoreProductModel.ID.eq(prodId));
    if (prods.isEmpty) return new Failure("No such products $prodId exists", prodId);
    var prod = prods.first;
    return new Ok(
        "Found product $prodId",
        ProductDTO(id: prod.id, name: prod.name, price: prod.price, category: prod.categories, imageUrl: prod.imageUrl!, description: prod.description!));
  }
}
