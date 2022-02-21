/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, file_names, unnecessary_new, prefer_if_null_operators, prefer_const_constructors, slash_for_doc_comments, annotate_overrides, non_constant_identifier_names, unnecessary_string_interpolations, prefer_adjacent_string_concatenation, unnecessary_const, dead_code

import 'ModelProvider.dart';
import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/** This is an auto generated class representing the UserModel type in your schema. */
@immutable
class UserModel extends Model {
  static const classType = const _UserModelModelType();
  final String id;
  final String email;
  final String name;
  final String imageUrl;
  final String creditCards;
  final String bankAccount;
  final List<ShoppingBagModel> shoppingBagModel;
  final StoreOwnerModel storeOwnerModel;
  final DigitalWalletModel digitalWalletModel;
  final String userModelStoreOwnerModelId;
  final String userModelDigitalWalletModelId;

  @override
  getInstanceType() => classType;

  @override
  String getId() {
    return id;
  }

  const UserModel._internal(
      {@required this.id,
      @required this.email,
      @required this.name,
      this.imageUrl,
      this.creditCards,
      this.bankAccount,
      this.shoppingBagModel,
      this.storeOwnerModel,
      this.digitalWalletModel,
      this.userModelStoreOwnerModelId,
      this.userModelDigitalWalletModelId});

  factory UserModel(
      {String id,
      @required String email,
      @required String name,
      String imageUrl,
      String creditCards,
      String bankAccount,
      List<ShoppingBagModel> shoppingBagModel,
      StoreOwnerModel storeOwnerModel,
      DigitalWalletModel digitalWalletModel,
      String userModelStoreOwnerModelId,
      String userModelDigitalWalletModelId}) {
    return UserModel._internal(
        id: id == null ? UUID.getUUID() : id,
        email: email,
        name: name,
        imageUrl: imageUrl,
        creditCards: creditCards,
        bankAccount: bankAccount,
        shoppingBagModel: shoppingBagModel != null
            ? List<ShoppingBagModel>.unmodifiable(shoppingBagModel)
            : shoppingBagModel,
        storeOwnerModel: storeOwnerModel,
        digitalWalletModel: digitalWalletModel,
        userModelStoreOwnerModelId: userModelStoreOwnerModelId,
        userModelDigitalWalletModelId: userModelDigitalWalletModelId);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserModel &&
        id == other.id &&
        email == other.email &&
        name == other.name &&
        imageUrl == other.imageUrl &&
        creditCards == other.creditCards &&
        bankAccount == other.bankAccount &&
        DeepCollectionEquality()
            .equals(shoppingBagModel, other.shoppingBagModel) &&
        storeOwnerModel == other.storeOwnerModel &&
        digitalWalletModel == other.digitalWalletModel &&
        userModelStoreOwnerModelId == other.userModelStoreOwnerModelId &&
        userModelDigitalWalletModelId == other.userModelDigitalWalletModelId;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("UserModel {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("email=" + "$email" + ", ");
    buffer.write("name=" + "$name" + ", ");
    buffer.write("imageUrl=" + "$imageUrl" + ", ");
    buffer.write("creditCards=" + "$creditCards" + ", ");
    buffer.write("bankAccount=" + "$bankAccount" + ", ");
    buffer.write(
        "userModelStoreOwnerModelId=" + "$userModelStoreOwnerModelId" + ", ");
    buffer.write(
        "userModelDigitalWalletModelId=" + "$userModelDigitalWalletModelId");
    buffer.write("}");

    return buffer.toString();
  }

  UserModel copyWith(
      {String id,
      String email,
      String name,
      String imageUrl,
      String creditCards,
      String bankAccount,
      List<ShoppingBagModel> shoppingBagModel,
      StoreOwnerModel storeOwnerModel,
      DigitalWalletModel digitalWalletModel,
      String userModelStoreOwnerModelId,
      String userModelDigitalWalletModelId}) {
    return UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        imageUrl: imageUrl ?? this.imageUrl,
        creditCards: creditCards ?? this.creditCards,
        bankAccount: bankAccount ?? this.bankAccount,
        shoppingBagModel: shoppingBagModel ?? this.shoppingBagModel,
        storeOwnerModel: storeOwnerModel ?? this.storeOwnerModel,
        digitalWalletModel: digitalWalletModel ?? this.digitalWalletModel,
        userModelStoreOwnerModelId:
            userModelStoreOwnerModelId ?? this.userModelStoreOwnerModelId,
        userModelDigitalWalletModelId: userModelDigitalWalletModelId ??
            this.userModelDigitalWalletModelId);
  }

  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        email = json['email'],
        name = json['name'],
        imageUrl = json['imageUrl'],
        creditCards = json['creditCards'],
        bankAccount = json['bankAccount'],
        shoppingBagModel = json['shoppingBagModel'] is List
            ? (json['shoppingBagModel'] as List)
                .map((e) =>
                    ShoppingBagModel.fromJson(new Map<String, dynamic>.from(e)))
                .toList()
            : null,
        storeOwnerModel = json['storeOwnerModel'] != null
            ? StoreOwnerModel.fromJson(
                new Map<String, dynamic>.from(json['storeOwnerModel']))
            : null,
        digitalWalletModel = json['digitalWalletModel'] != null
            ? DigitalWalletModel.fromJson(
                new Map<String, dynamic>.from(json['digitalWalletModel']))
            : null,
        userModelStoreOwnerModelId = json['userModelStoreOwnerModelId'],
        userModelDigitalWalletModelId = json['userModelDigitalWalletModelId'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'imageUrl': imageUrl,
        'creditCards': creditCards,
        'bankAccount': bankAccount,
        'shoppingBagModel': shoppingBagModel != null
            ? shoppingBagModel
                .map((ShoppingBagModel e) => e != null ? e.toJson() : null)
                .toList()
            : null,
        'storeOwnerModel': storeOwnerModel?.toJson(),
        'digitalWalletModel': digitalWalletModel?.toJson(),
        'userModelStoreOwnerModelId': userModelStoreOwnerModelId,
        'userModelDigitalWalletModelId': userModelDigitalWalletModelId
      };

  static final QueryField ID = QueryField(fieldName: "userModel.id");
  static final QueryField EMAIL = QueryField(fieldName: "email");
  static final QueryField NAME = QueryField(fieldName: "name");
  static final QueryField IMAGEURL = QueryField(fieldName: "imageUrl");
  static final QueryField CREDITCARDS = QueryField(fieldName: "creditCards");
  static final QueryField BANKACCOUNT = QueryField(fieldName: "bankAccount");
  static final QueryField SHOPPINGBAGMODEL = QueryField(
      fieldName: "shoppingBagModel",
      fieldType: ModelFieldType(ModelFieldTypeEnum.model,
          ofModelName: (ShoppingBagModel).toString()));
  static final QueryField STOREOWNERMODEL = QueryField(
      fieldName: "storeOwnerModel",
      fieldType: ModelFieldType(ModelFieldTypeEnum.model,
          ofModelName: (StoreOwnerModel).toString()));
  static final QueryField DIGITALWALLETMODEL = QueryField(
      fieldName: "digitalWalletModel",
      fieldType: ModelFieldType(ModelFieldTypeEnum.model,
          ofModelName: (DigitalWalletModel).toString()));
  static final QueryField USERMODELSTOREOWNERMODELID =
      QueryField(fieldName: "userModelStoreOwnerModelId");
  static final QueryField USERMODELDIGITALWALLETMODELID =
      QueryField(fieldName: "userModelDigitalWalletModelId");
  static var schema =
      Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "UserModel";
    modelSchemaDefinition.pluralName = "UserModels";

    modelSchemaDefinition.authRules = [
      AuthRule(authStrategy: AuthStrategy.PUBLIC, operations: [
        ModelOperation.CREATE,
        ModelOperation.UPDATE,
        ModelOperation.DELETE,
        ModelOperation.READ
      ])
    ];

    modelSchemaDefinition.addField(ModelFieldDefinition.id());

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserModel.EMAIL,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserModel.NAME,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserModel.IMAGEURL,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserModel.CREDITCARDS,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserModel.BANKACCOUNT,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
        key: UserModel.SHOPPINGBAGMODEL,
        isRequired: false,
        ofModelName: (ShoppingBagModel).toString(),
        associatedKey: ShoppingBagModel.USERMODELID));

    modelSchemaDefinition.addField(ModelFieldDefinition.hasOne(
        key: UserModel.STOREOWNERMODEL,
        isRequired: false,
        ofModelName: (StoreOwnerModel).toString(),
        associatedKey: StoreOwnerModel.ID));

    modelSchemaDefinition.addField(ModelFieldDefinition.hasOne(
        key: UserModel.DIGITALWALLETMODEL,
        isRequired: false,
        ofModelName: (DigitalWalletModel).toString(),
        associatedKey: DigitalWalletModel.ID));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserModel.USERMODELSTOREOWNERMODELID,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserModel.USERMODELDIGITALWALLETMODELID,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));
  });
}

class _UserModelModelType extends ModelType<UserModel> {
  const _UserModelModelType();

  @override
  UserModel fromJson(Map<String, dynamic> jsonData) {
    return UserModel.fromJson(jsonData);
  }
}
