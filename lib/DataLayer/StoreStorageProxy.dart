import 'dart:io';
import 'dart:ui';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/LogicLayer/Secret.dart';
import 'package:final_project_yroz/LogicLayer/SecretLoader.dart';
import 'package:final_project_yroz/LogicModels/OpeningTimes.dart';
import 'package:final_project_yroz/Result/Failure.dart';
import 'package:final_project_yroz/Result/OK.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/models/OnlineStoreModel.dart';
import 'package:final_project_yroz/models/PhysicalStoreModel.dart';
import 'package:final_project_yroz/models/StoreOwnerModel.dart';
import 'package:final_project_yroz/models/StoreProductModel.dart';
import 'package:final_project_yroz/models/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
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

  Future<ResultInterface> openOnlineStore(OnlineStoreDTO store, [String? storeID, DateTime? lastViewPurchase]) async {
    OnlineStoreModel onlineStoreModel = OnlineStoreModel(
        id: storeID,
        name: store.name,
        phoneNumber: store.phoneNumber,
        address: store.address,
        categories: JsonEncoder.withIndent('  ').convert(store.categories),
        operationHours: openingsToJson(store.operationHours));

    String qrCode = await generateUniqueQRCode(onlineStoreModel.id);

    String? imageUrl = store.image;
    if (store.imageFromPhone != null) {
      await uploadPicture(onlineStoreModel.id, store.imageFromPhone); // uploading the picture to s3
      Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();
      imageUrl = "${secret.S3_URL}${onlineStoreModel.id}";
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
        imageUrl: imageUrl,
        storeProductModels: productsModel,
        qrCode: qrCode);
    await Amplify.DataStore.save(onlineWithProducts);

    ResultInterface storeOwnerRes =
        await UsersStorageProxy().getStoreOwnerState(UserAuthenticator().getCurrentUserId());
    StoreOwnerModel? storeOwner = null;
    //second case it is empty store owner when upgrading from physical to online
    if (!storeOwnerRes.getTag()) {
      //the user will now have a store owner state
      storeOwner = StoreOwnerModel(
          onlineStoreModel: onlineWithProducts,
          storeOwnerModelOnlineStoreModelId: onlineWithProducts.id,
          lastPurchasesView: lastViewPurchase == null
              ? TemporalDateTime.fromString(
                  DateFormat('yyyy/MM/dd, hh:mm:ss').parse('1/1/2022, 10:00:00').toDateTimeIso8601String())
              : TemporalDateTime.fromString(lastViewPurchase.toDateTimeIso8601String()));
      UserModel? oldUserModel = await UsersStorageProxy().getUser(UserAuthenticator().getCurrentUserId());
      if (oldUserModel == null) {
        FLog.error(text: "No such user - ${UserAuthenticator().getCurrentUserId()}");
        return new Failure("no such user exists in the system!", null);
      }
      UserModel newUserModel =
          oldUserModel.copyWith(storeOwnerModel: storeOwner, userModelStoreOwnerModelId: storeOwner.id);

      await Amplify.DataStore.save(storeOwner);
      await Amplify.DataStore.save(newUserModel);
      FLog.info(text: "open online store ${onlineWithProducts.id} for store owner ${storeOwner.id}");
      return new Ok("open online store succeeded", Tuple2<OnlineStoreModel, String>(onlineWithProducts, storeOwner.id));
    } else if ((storeOwnerRes.getValue().storeOwnerModelOnlineStoreModelId == null &&
            storeOwnerRes.getValue().storeOwnerModelPhysicalStoreModelId == null) ||
        (storeOwnerRes.getValue().storeOwnerModelOnlineStoreModelId!.isEmpty &&
            storeOwnerRes.getValue().storeOwnerModelPhysicalStoreModelId!.isEmpty)) {
      StoreOwnerModel emptyOwner = storeOwnerRes.getValue();
      storeOwner = emptyOwner.copyWith(
          onlineStoreModel: onlineWithProducts, storeOwnerModelOnlineStoreModelId: onlineWithProducts.id);
      UserModel? oldUserModel = await UsersStorageProxy().getUser(UserAuthenticator().getCurrentUserId());
      if (oldUserModel == null) {
        FLog.error(text: "No such user - ${UserAuthenticator().getCurrentUserId()}");
        return new Failure("no such user exists in the system!", onlineWithProducts);
      }
      UserModel newUserModel =
          oldUserModel.copyWith(storeOwnerModel: storeOwner, userModelStoreOwnerModelId: storeOwner.id);

      await Amplify.DataStore.save(storeOwner);
      await Amplify.DataStore.save(newUserModel);
      FLog.debug(text: "Finished open online store in case of convert, store owner ID: ${storeOwner.id}");
      return new Ok("open online store succeeded", Tuple2<OnlineStoreModel, String>(onlineWithProducts, storeOwner.id));
    }
    // already have an online store
    FLog.error(text: "User already has online store - only one is allowed!");
    return new Failure("User already has online store - only one is allowed!", onlineWithProducts);
  }

  Future<String> generateUniqueQRCode(String storeID) async {
    final qrValidationResult = QrValidator.validate(
      data: storeID,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode!,
      color: const Color(0xFF000000),
      gapless: true,
      embeddedImageStyle: null,
      embeddedImage: null,
    );

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    String path = '$tempPath/$ts.png';
    final picData = await painter.toImageData(2048, format: ImageByteFormat.png);
    File qrFile = await writeToFile(picData!, path);
    var res = await uploadPicture("$storeID-qrcode", qrFile);
    if (!res.getTag()) {
      print(res.getMessage());
      return "";
    }
    FLog.info(text: "Generated QRCode and saved it in $path");
    Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();
    return "${secret.S3_URL}$storeID-qrcode";
  }

  Future<File> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    File file = await File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    return file;
  }

  String openingsToJson(Openings openings) {
    String json = "";
    for (OpeningTimes t in openings.days) {
      json = json + t.day + "-";
      if (t.closed)
        json = json + "closed";
      else {
        final now = new DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, t.operationHours.item1.hour, t.operationHours.item1.minute);
        final dt2 = DateTime(now.year, now.month, now.day, t.operationHours.item2.hour, t.operationHours.item2.minute);
        final format = DateFormat.jm();
        json = json + format.format(dt) + "," + format.format(dt2);
      }
      json = json + "\n";
    }
    return json;
  }

  Future<ResultInterface> openPhysicalStore(StoreDTO store, [DateTime? lastViewPurchase]) async {
    PhysicalStoreModel physicalModelNotComplete = PhysicalStoreModel(
        name: store.name,
        phoneNumber: store.phoneNumber,
        address: store.address,
        categories: JsonEncoder.withIndent('  ').convert(store.categories),
        operationHours: openingsToJson(store.operationHours));

    String qrCode = await generateUniqueQRCode(physicalModelNotComplete.id);

    String? imageUrl = null;
    if (store.imageFromPhone != null) {
      await uploadPicture(physicalModelNotComplete.id, store.imageFromPhone); // uploading the picture to s3
      Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();
      imageUrl = "${secret.S3_URL}${physicalModelNotComplete.id}";
    }

    var physicalModel = physicalModelNotComplete.copyWith(imageUrl: imageUrl, qrCode: qrCode);
    await Amplify.DataStore.save(physicalModel);

    ResultInterface storeOwnerRes =
        await UsersStorageProxy().getStoreOwnerState(UserAuthenticator().getCurrentUserId());

    if (!storeOwnerRes.getTag()) {
      //the user will now have a store owner state
      StoreOwnerModel storeOwner = StoreOwnerModel(
          physicalStoreModel: physicalModel,
          storeOwnerModelPhysicalStoreModelId: physicalModel.id,
          lastPurchasesView: lastViewPurchase == null
              ? TemporalDateTime.fromString(
                  DateFormat('yyyy/MM/dd, hh:mm:ss').parse('1/1/2022, 10:00:00').toDateTimeIso8601String())
              : TemporalDateTime.fromString(lastViewPurchase.toDateTimeIso8601String()));
      await Amplify.DataStore.save(storeOwner);

      UserModel? oldUserModel = await UsersStorageProxy().getUser(UserAuthenticator().getCurrentUserId());
      if (oldUserModel == null) {
        FLog.error(text: "No such user - ${UserAuthenticator().getCurrentUserId()}");
        return new Failure("no such user exists in the system!", physicalModel);
      }

      UserModel newUserModel =
          oldUserModel.copyWith(storeOwnerModel: storeOwner, userModelStoreOwnerModelId: storeOwner.id);
      FLog.info(text: "saving user model: $newUserModel");
      await Amplify.DataStore.save(newUserModel);
      FLog.info(text: "open physical store ${physicalModel.id} for store owner ${storeOwner.id}");
      return new Ok("open physical store succsseded", Tuple2<PhysicalStoreModel, String>(physicalModel, storeOwner.id));
    }
    // already have an physical store
    FLog.error(text: "User already has physical store - only one is allowed!");
    return new Failure("User already has physical store - only one is allowed!", physicalModel);
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

  Future<ResultInterface> uploadPicture(String storeId, File? file) async {
    try {
      if (file == null) {
        FLog.error(text: "Image file is null");
        return new Failure("Image file is null");
      }
      final UploadFileResult result = await Amplify.Storage.uploadFile(
          local: file,
          key: storeId,
          onProgress: (progress) {
            print("Fraction completed: " + progress.getFractionCompleted().toString());
          });
      FLog.info(text: "Successfully uploaded file: ${result.key}");
      return new Ok('Successfully uploaded file: ${result.key}', storeId);
    } on StorageException catch (e) {
      FLog.error(text: e.message, stacktrace: StackTrace.current);
      return new Failure('Error uploading file: $e', storeId);
    }
  }

  Future<ResultInterface> deletePicture(String storeId) async {
    try {
      final RemoveResult result = await Amplify.Storage.remove(key: storeId);
      return new Ok('Deleted file: ${result.key}', storeId);
    } on StorageException catch (e) {
      FLog.error(text: e.message, stacktrace: StackTrace.current);
      return new Failure('Error deleting file: $e', storeId);
    }
  }

  Future<void> deleteFileLocally(String? path) async {
    try {
      if (path == null) return;
      final file = await File(path);
      await file.delete();
    } catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      print(e.toString());
    }
  }

  Future<ResultInterface> updatePicture(File file, String storeId) async {
    var res = await deletePicture(storeId);
    return res.getTag() ? await uploadPicture(storeId, file) : res;
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

  Future<List<StoreDTO>> fetchCategoryStores(String category) async {
    List<PhysicalStoreModel> physicalStores = await Amplify.DataStore.query(PhysicalStoreModel.classType,
        where: PhysicalStoreModel.CATEGORIES.contains(category));
    List<StoreDTO> convertedPhysicalStores = await convertPhysicalStoreModelToDTO(physicalStores);
    List<OnlineStoreModel> onlineStores = await Amplify.DataStore.query(OnlineStoreModel.classType,
        where: OnlineStoreModel.CATEGORIES.contains(category));
    List<StoreDTO> convertedOnlineStores = await convertOnlineStoreModelToDTO(onlineStores);

    convertedPhysicalStores.addAll(convertedOnlineStores);
    return convertedPhysicalStores;
  }

  Future<List<StoreDTO>> fetchAllPhysicalStores() async {
    try {
      List<PhysicalStoreModel> physicalStores = await Amplify.DataStore.query(PhysicalStoreModel.classType);
      return convertPhysicalStoreModelToDTO(physicalStores); //only one physical store per user
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      throw e;
    }
  }

  Future<List<OnlineStoreDTO>> fetchAllOnlineStores() async {
    try {
      List<OnlineStoreModel> onlineStores = await Amplify.DataStore.query(OnlineStoreModel.classType);
      return convertOnlineStoreModelToDTO(onlineStores); //only one online store per user
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      throw e;
    }
  }

  Future<List<StoreDTO>> fetchAllStores() async {
    try {
      List<OnlineStoreDTO> onlineDtos = await fetchAllOnlineStores();
      List<StoreDTO> physicalDtos = await fetchAllPhysicalStores();
      List<StoreDTO> allDtos = [];
      onlineDtos.forEach((element) {
        allDtos.add(element);
      });
      physicalDtos.forEach((element) {
        allDtos.add(element);
      });
      return allDtos;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      throw e;
    }
  }

  List<ProductDTO> convertProductsModelToDTO(List<StoreProductModel> products) {
    List<ProductDTO> productsDTO = [];
    for (var p in products) {
      productsDTO.add(new ProductDTO(
          id: p.id,
          name: p.name,
          price: p.price,
          category: p.categories.isEmpty ? "" : jsonDecode(p.categories).cast<String>(),
          imageUrl: p.imageUrl == null ? "" : p.imageUrl!,
          description: p.description!,
          storeID: p.onlinestoremodelID,
          imageFromPhone: null));
    }
    return productsDTO;
  }

  Future<List<ProductDTO>> fetchStoreProducts(String storeId) async {
    List<StoreProductModel> products = await Amplify.DataStore.query(StoreProductModel.classType,
        where: StoreProductModel.ONLINESTOREMODELID.eq(storeId));
    return convertProductsModelToDTO(products);
  }

  Future<List<StoreDTO>> fetchStoresByKeywords(String keywords) async {
    try {
      final splitedKeywords = keywords.split(' ');
      List<PhysicalStoreModel> physicalStores = [];
      List<OnlineStoreModel> onlineStores = [];

      for (var i = 0; i < splitedKeywords.length; i++) {
        final lowerKeyword = splitedKeywords[i].toLowerCase();
        final upperKeyword = splitedKeywords[i].toUpperCase();
        final firstUpperKeyword =
            splitedKeywords[i].isNotEmpty ? splitedKeywords[i][0].toUpperCase() + splitedKeywords[i].substring(1) : "";

        physicalStores.addAll(
          await Amplify.DataStore.query(PhysicalStoreModel.classType,
              where: PhysicalStoreModel.NAME
                  .contains(splitedKeywords[i])
                  .or(PhysicalStoreModel.ADDRESS.contains(splitedKeywords[i]))
                  .or(PhysicalStoreModel.CATEGORIES.contains(splitedKeywords[i]))
                  .or(PhysicalStoreModel.NAME
                      .contains(lowerKeyword)
                      .or(PhysicalStoreModel.ADDRESS.contains(lowerKeyword))
                      .or(PhysicalStoreModel.CATEGORIES.contains(lowerKeyword)))
                  .or(PhysicalStoreModel.NAME
                      .contains(upperKeyword)
                      .or(PhysicalStoreModel.ADDRESS.contains(upperKeyword))
                      .or(PhysicalStoreModel.CATEGORIES.contains(upperKeyword)))
                  .or(PhysicalStoreModel.NAME
                      .contains(firstUpperKeyword)
                      .or(PhysicalStoreModel.ADDRESS.contains(firstUpperKeyword))
                      .or(PhysicalStoreModel.CATEGORIES.contains(firstUpperKeyword)))),
        );
        onlineStores.addAll(await Amplify.DataStore.query(
          OnlineStoreModel.classType,
          where: OnlineStoreModel.NAME
              .contains(splitedKeywords[i])
              .or(OnlineStoreModel.ADDRESS.contains(splitedKeywords[i]))
              .or(OnlineStoreModel.CATEGORIES.contains(splitedKeywords[i]))
              .or(OnlineStoreModel.NAME
                  .contains(lowerKeyword)
                  .or(OnlineStoreModel.ADDRESS.contains(lowerKeyword))
                  .or(OnlineStoreModel.CATEGORIES.contains(lowerKeyword)))
              .or(OnlineStoreModel.NAME
                  .contains(upperKeyword)
                  .or(OnlineStoreModel.ADDRESS.contains(upperKeyword))
                  .or(OnlineStoreModel.CATEGORIES.contains(upperKeyword)))
              .or(OnlineStoreModel.NAME
                  .contains(firstUpperKeyword)
                  .or(OnlineStoreModel.ADDRESS.contains(firstUpperKeyword))
                  .or(OnlineStoreModel.CATEGORIES.contains(firstUpperKeyword))),
        ));
      }

      List<StoreDTO> physicalDtos = await convertPhysicalStoreModelToDTO(physicalStores);
      List<OnlineStoreDTO> onlineDtos = await convertOnlineStoreModelToDTO(onlineStores);

      List<StoreDTO> allDtos = List.generate(onlineDtos.length, (index) => onlineDtos[index]);
      allDtos.addAll(physicalDtos);
      return allDtos;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
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
      FLog.info(text: "Got URL: ${result.url}");
      return result.url;
    } on StorageException catch (e) {
      print('Error getting download URL: $e');
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      throw e;
    }
  }

  Openings decodeOpenings(String hours) {
    List<OpeningTimes> days = [];
    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(hours);
    for (String line in lines) {
      if (line.contains("closed")) {
        days.add(OpeningTimes(
            day: line.substring(0, line.indexOf("-")),
            closed: true,
            operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))));
      } else {
        int firsthour = 0;
        int firstminute = 0;
        int secondhour = 0;
        int secondminute = 0;
        String firsttime = line.substring(line.indexOf("-") + 1, line.indexOf(","));
        if (firsttime.contains("AM")) {
          firsthour = int.parse(firsttime.substring(0, firsttime.indexOf(":")));
          firstminute = int.parse(firsttime.substring(firsttime.indexOf(":") + 1, firsttime.indexOf(" ")));
        } else {
          firsthour = int.parse(firsttime.substring(0, firsttime.indexOf(":"))) + 12;
          firstminute = int.parse(firsttime.substring(firsttime.indexOf(":") + 1, firsttime.indexOf(" ")));
        }
        String secondtime = line.substring(line.indexOf(",") + 1);
        if (secondtime.contains("AM")) {
          secondhour = int.parse(secondtime.substring(0, secondtime.indexOf(":")));
          secondminute = int.parse(secondtime.substring(secondtime.indexOf(":") + 1, secondtime.indexOf(" ")));
        } else {
          secondhour = int.parse(secondtime.substring(0, secondtime.indexOf(":"))) + 12;
          secondminute = int.parse(secondtime.substring(secondtime.indexOf(":") + 1, secondtime.indexOf(" ")));
        }
        days.add(OpeningTimes(
            day: line.substring(0, line.indexOf("-")),
            closed: false,
            operationHours: Tuple2(
                TimeOfDay(hour: firsthour, minute: firstminute), TimeOfDay(hour: secondhour, minute: secondminute))));
      }
    }
    return Openings(days: days);
  }

  Future<List<StoreDTO>> convertPhysicalStoreModelToDTO(List<PhysicalStoreModel> physicalStores) async {
    List<StoreDTO> lst = [];
    for (PhysicalStoreModel model in physicalStores) {
      StoreDTO dto = StoreDTO(
          id: model.id,
          name: model.name,
          address: model.address,
          phoneNumber: model.phoneNumber,
          categories: jsonDecode(model.categories).cast<String>(),
          operationHours: decodeOpenings(model.operationHours),
          image: model.imageUrl != null && model.imageUrl!.isEmpty ? null : model.imageUrl,
          qrCode: model.qrCode!);
      lst.add(dto);
    }
    return lst;
  }

  Future<List<OnlineStoreDTO>> convertOnlineStoreModelToDTO(List<OnlineStoreModel> onlineStores) async {
    List<OnlineStoreDTO> lst = [];
    for (OnlineStoreModel model in onlineStores) {
      OnlineStoreDTO dto = OnlineStoreDTO(
          id: model.id,
          name: model.name,
          address: model.address,
          phoneNumber: model.phoneNumber,
          categories: jsonDecode(model.categories).cast<String>(),
          operationHours: decodeOpenings(model.operationHours),
          image: model.imageUrl != null && model.imageUrl!.isEmpty ? null : model.imageUrl,
          products: await fetchStoreProducts(model.id),
          qrCode: model.qrCode);
      lst.add(dto);
    }
    return lst;
  }

  Openings opHours(Map<String, dynamic> oper) {
    Map<String, List<TimeOfDay>> map = {};
    for (MapEntry e in oper.entries) {
      List<TimeOfDay> l = [];
      for (dynamic d in e.value) {
        l.add(TimeOfDay.fromDateTime(DateFormat.jm().parse(d.toString())));
      }
      map.addEntries([MapEntry(e.key, l)]);
    }
    return Openings(days: []);
  }

  Future<ResultInterface> createProductForOnlineStore(ProductDTO productDTO, String onlineStoreModelID) async {
    try {
      StoreProductModel productModel = StoreProductModel(
          name: productDTO.name,
          price: productDTO.price,
          categories: productDTO.category,
          description: productDTO.description,
          onlinestoremodelID: onlineStoreModelID);
      if (productDTO.imageFromPhone != null) {
        var res = await uploadPicture(productModel.id, productDTO.imageFromPhone); // uploading the picture to s3
        if (!res.getTag()) return res;
        Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();
        String imageUrl = "${secret.S3_URL}${productModel.id}";
        productModel = productModel.copyWith(imageUrl: imageUrl);
      }

      await Amplify.DataStore.save(productModel);
      FLog.info(
          text: "created product with ID: ${productModel.id} and added it to the online store: ${onlineStoreModelID}");
      return new Ok(
          "created product with ID: ${productModel.id} and added it to the online store: ${onlineStoreModelID}",
          productModel);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure("Something went wrong, please try again later...", null);
    }
  }

  Future<ResultInterface> updatePhysicalStore(StoreDTO newStore) async {
    try {
      List<PhysicalStoreModel> physicalStores =
          await Amplify.DataStore.query(PhysicalStoreModel.classType, where: PhysicalStoreModel.ID.eq(newStore.id));
      if (physicalStores.isEmpty) {
        FLog.error(text: "No physical store is found!");
        return new Failure("No physical store is found!", null);
      }

      String? imageUrl = newStore.image;
      if (newStore.imageFromPhone != null) {
        var res = await updatePicture(newStore.imageFromPhone!, newStore.id);
        if (!res.getTag()) return res;
        Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();
        imageUrl = "${secret.S3_URL}${physicalStores[0].id}";
      }

      PhysicalStoreModel updatedStore = physicalStores[0].copyWith(
          id: newStore.id,
          name: newStore.name,
          phoneNumber: newStore.phoneNumber,
          address: newStore.address,
          categories: JsonEncoder.withIndent('  ').convert(newStore.categories),
          operationHours: openingsToJson(newStore.operationHours),
          qrCode: newStore.qrCode,
          imageUrl: imageUrl == null ? "" : imageUrl);

      await Amplify.DataStore.save(updatedStore);
      FLog.info(text: "updated physical store succssefully");
      return new Ok("updated physical store succssefully", updatedStore);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      throw e;
    }
  }

  Future<ResultInterface> updateOnlineStore(OnlineStoreDTO newStore) async {
    try {
      List<OnlineStoreModel> onlineStores =
          await Amplify.DataStore.query(OnlineStoreModel.classType, where: OnlineStoreModel.ID.eq(newStore.id));
      if (onlineStores.isEmpty) {
        FLog.error(text: "No online store is found!");
        return new Failure("No online store is found!", null);
      }

      String? imageUrl = newStore.image;
      if (newStore.imageFromPhone != null) {
        var res = await updatePicture(newStore.imageFromPhone!, newStore.id);
        if (!res.getTag()) return res;
        Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();
        imageUrl = "${secret.S3_URL}${onlineStores[0].id}";
      }
      OnlineStoreModel updatedStore = onlineStores[0].copyWith(
          id: newStore.id,
          name: newStore.name,
          phoneNumber: newStore.phoneNumber,
          address: newStore.address,
          categories: JsonEncoder.withIndent('  ').convert(newStore.categories),
          operationHours: openingsToJson(newStore.operationHours),
          qrCode: newStore.qrCode,
          imageUrl: imageUrl == null ? "" : imageUrl);

      await Amplify.DataStore.save(updatedStore);
      ResultInterface prodRes = await updateOnlineStoreProducts(newStore.products, newStore.id);
      if (!prodRes.getTag()) return prodRes;
      List<StoreProductModel> prods = prodRes.getValue();
      OnlineStoreModel update = updatedStore.copyWith(storeProductModels: prods);
      FLog.info(text: "updated online store succssefully");
      return new Ok("updated online store succssefully", update);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      throw e;
    }
  }

  Future<ResultInterface> updateOnlineStoreProducts(List<ProductDTO> products, String storeID) async {
    List<OnlineStoreModel> stores =
        await Amplify.DataStore.query(OnlineStoreModel.classType, where: OnlineStoreModel.ID.eq(storeID));
    if (stores.isEmpty) {
      return new Failure("No such store with id $storeID");
    }
    List<StoreProductModel> productsModels = await Amplify.DataStore.query(StoreProductModel.classType,
        where: StoreProductModel.ONLINESTOREMODELID.eq(storeID));
    //can be empty when upgrading from physical to online
    if (productsModels.isNotEmpty) {
      for (StoreProductModel prod in productsModels) {
        deletePicture(prod.id);
        await Amplify.DataStore.delete(prod);
      }
    }

    List<StoreProductModel> updatedProd = [];
    for (var p in products) {
      var res = await createProductForOnlineStore(p, storeID);
      if (res.getTag()) {
        updatedProd.add(res.getValue());
      } else {
        FLog.error(text: res.getMessage());
      }
    }

    for (StoreProductModel p in updatedProd) {
      await Amplify.DataStore.save(p);
    }
    FLog.info(text: "Updated products in store $storeID");
    return new Ok("Updated products in store $storeID", updatedProd);
  }

  Future<ResultInterface> deleteStore(String id, bool isOnline) async {
    try {
      var res = isOnline ? await deleteOnlineStore(id) : await deletePhysicalStore(id);
      if (!res.getTag()) return res; //failure occured
      return new Ok(res.getMessage(), id);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure("Something went wrong, please try again later...", null);
    }
  }

  Future<void> deleteOnlineStoreProducts(String storeID) async {
    List<StoreProductModel> products = await Amplify.DataStore.query(StoreProductModel.classType,
        where: StoreProductModel.ONLINESTOREMODELID.eq(storeID));
    for (var prod in products) {
      await Amplify.DataStore.delete(prod);
      await deletePicture(prod.id);
    }
  }

  Future<ResultInterface> deleteOnlineStore(String id) async {
    try {
      List<OnlineStoreModel> stores =
          await Amplify.DataStore.query(OnlineStoreModel.classType, where: OnlineStoreModel.ID.eq(id));
      if (stores.isEmpty) {
        FLog.error(text: "No such store $id");
        return new Failure("No such store", id);
      }
      await deleteOnlineStoreProducts(stores[0].id);
      await Amplify.DataStore.delete(stores[0]); //only 1 store per user
      deletePicture(id); // in s3 - for store picutre
      deletePicture("$id-qrcode"); //in s3
      deleteFileLocally(stores[0].qrCode);
      var res = await deleteStoreOwnerStateIfNeeded();
      if (!res.getTag()) return res;
      FLog.info(text: "Deleted online store succssefully");
      return new Ok("Deleted online store succssefully", id);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure("Something went wrong, please try again later...", id);
    }
  }

  Future<ResultInterface> deletePhysicalStore(String id, [bool? updateStoreOwner]) async {
    try {
      List<PhysicalStoreModel> stores =
          await Amplify.DataStore.query(PhysicalStoreModel.classType, where: PhysicalStoreModel.ID.eq(id));
      if (stores.isEmpty) {
        FLog.error(text: "No such store $id");
        return new Failure("No such store", id);
      }
      await Amplify.DataStore.delete(stores[0]); //only 1 store per user
      deletePicture(id); // in s3 - for store picutre
      deletePicture("$id-qrcode"); //in s3
      deleteFileLocally(stores[0].qrCode);
      if (updateStoreOwner == null || !updateStoreOwner) {
        var res = await deleteStoreOwnerStateIfNeeded();
        if (!res.getTag()) return res;
      }
      FLog.info(text: "Deleted physical store succssefully");
      return new Ok("Deleted physical store succssefully", id);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return new Failure("Something went wrong, please try again later...", id);
    }
  }

  Future<ResultInterface> deleteStoreOwnerStateIfNeeded() async {
    String? storeOwnerID = await UsersStorageProxy().getStoreOwnerStateId();
    if (storeOwnerID == null) {
      FLog.error(text: "No store owner to delete");
      return new Failure("No store owner to delete", null);
    }
    List<StoreOwnerModel> storeOwners =
        await Amplify.DataStore.query(StoreOwnerModel.classType, where: StoreOwnerModel.ID.eq(storeOwnerID));
    StoreOwnerModel storeOwnerModel = storeOwners.first;

    await Amplify.DataStore.delete(storeOwnerModel); //no store left
    UserModel? currUser = await UsersStorageProxy().getUser(UserAuthenticator().getCurrentUserId());
    if (currUser == null) return Failure("No such user", null);
    currUser = currUser.copyWith(userModelStoreOwnerModelId: "", storeOwnerModel: null);
    await Amplify.DataStore.save(currUser);
    FLog.info(text: "Deleted completly Store Owner State");
    return new Ok("Deleted completly Store Owner State", currUser);
  }

  Future<ResultInterface> emptyStoreOwner() async {
    String? storeOwnerID = await UsersStorageProxy().getStoreOwnerStateId();
    if (storeOwnerID == null) {
      FLog.error(text: "No store owner to delete");
      return new Failure("No store owner to delete", null);
    }
    List<StoreOwnerModel> storeOwners =
        await Amplify.DataStore.query(StoreOwnerModel.classType, where: StoreOwnerModel.ID.eq(storeOwnerID));
    StoreOwnerModel storeOwnerModel = storeOwners.first;
    var empty = storeOwnerModel.copyWith(
        onlineStoreModel: null,
        storeOwnerModelOnlineStoreModelId: "",
        physicalStoreModel: null,
        storeOwnerModelPhysicalStoreModelId: "");
    await Amplify.DataStore.save(empty);
    return new Ok("Empty store owner ${empty.id}", storeOwnerID);
  }

  Future<ResultInterface> convertPhysicalStoreToOnline(StoreDTO physicalStore, DateTime lastViewPurchase) async {
    ResultInterface deletePhysicalRes = await deletePhysicalStore(physicalStore.id, true);
    if (!deletePhysicalRes.getTag()) return deletePhysicalRes;
    ResultInterface emptyStoreOwnerRes = await emptyStoreOwner();
    if (!emptyStoreOwnerRes.getTag()) return emptyStoreOwnerRes;
    OnlineStoreDTO onlineStoreDTO = OnlineStoreDTO(
        id: physicalStore.id,
        name: physicalStore.name,
        address: physicalStore.address,
        phoneNumber: physicalStore.phoneNumber,
        categories: physicalStore.categories,
        operationHours: physicalStore.operationHours,
        products: [],
        qrCode: physicalStore.qrCode,
        image: physicalStore.image,
        imageFromPhone: physicalStore.imageFromPhone);
    ResultInterface openOnlineStoreRes = await openOnlineStore(onlineStoreDTO, physicalStore.id, lastViewPurchase);
    return openOnlineStoreRes;
  }

  Future<ResultInterface> getPhysicalStore(String storeID) async {
    List<PhysicalStoreModel> stores =
        await Amplify.DataStore.query(PhysicalStoreModel.classType, where: PhysicalStoreModel.ID.eq(storeID));
    if (stores.isEmpty) {
      FLog.error(text: "No such store $storeID exists");
      return new Failure("No such store $storeID exists", storeID);
    }
    var store = stores.first;
    return new Ok(
        "Found store $storeID",
        StoreDTO(
            id: store.id,
            name: store.name,
            phoneNumber: store.phoneNumber,
            address: store.address,
            categories: store.categories.isEmpty ? "" : jsonDecode(store.categories).cast<String>(),
            operationHours: decodeOpenings(store.operationHours),
            qrCode: store.qrCode,
            image: store.imageUrl));
  }

  Future<ResultInterface> getOnlineStore(String storeID) async {
    List<OnlineStoreModel> stores =
        await Amplify.DataStore.query(OnlineStoreModel.classType, where: OnlineStoreModel.ID.eq(storeID));
    if (stores.isEmpty) {
      FLog.error(text: "No such store $storeID exists");
      return new Failure("No such store $storeID exists", storeID);
    }
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
            operationHours: decodeOpenings(store.operationHours),
            products: products,
            qrCode: store.qrCode,
            image: store.imageUrl));
  }

  Future<ResultInterface> getOnlineStoreProduct(String prodId) async {
    List<StoreProductModel> prods =
        await Amplify.DataStore.query(StoreProductModel.classType, where: StoreProductModel.ID.eq(prodId));
    if (prods.isEmpty) {
      FLog.error(text: "No such product $prodId exists");
      return new Failure("No such product $prodId exists", prodId);
    }
    var prod = prods.first;
    File? file = prod.imageUrl != null ? await createFileFromImageUrl(prod.imageUrl!) : null;
    return new Ok(
        "Found product $prodId",
        ProductDTO(
            id: prod.id,
            name: prod.name,
            price: prod.price,
            category: prod.categories,
            imageUrl: prod.imageUrl == null ? "" : prod.imageUrl!,
            description: prod.description!,
            storeID: prod.onlinestoremodelID,
            imageFromPhone: file));
  }

  Future<ResultInterface> getStoreNameByID(String storeID) async {
    var phy = await fetchPhysicalStore(storeID);
    if (phy == null) {
      var online = await fetchOnlineStore(storeID);
      if (online == null) {
        FLog.error(text: "No such store $storeID");
        return new Failure("The store $storeID does not exist");
      }
      return new Ok("Found store $storeID name", online.name);
    }
    return new Ok("Found store $storeID name", phy.name);
  }
}
