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
import 'package:amplify_core/amplify_core.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';


/** This is an auto generated class representing the UserModel type in your schema. */
@immutable
class UserModel extends Model {
  static const classType = const _UserModelModelType();
  final String id;
  final String? _email;
  final String? _name;
  final String? _imageUrl;
  final String? _creditCards;
  final String? _bankAccount;
  final StoreOwnerModel? _storeOwnerModel;
  final DigitalWalletModel? _digitalWalletModel;
  final List<ShoppingBagModel>? _shoppingBagModels;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;
  final String? _userModelStoreOwnerModelId;
  final String? _userModelDigitalWalletModelId;

  @override
  getInstanceType() => classType;
  
  @override
  String getId() {
    return id;
  }
  
  String get email {
    try {
      return _email!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get name {
    try {
      return _name!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get imageUrl {
    return _imageUrl;
  }
  
  String? get creditCards {
    return _creditCards;
  }
  
  String? get bankAccount {
    return _bankAccount;
  }
  
  StoreOwnerModel? get storeOwnerModel {
    return _storeOwnerModel;
  }
  
  DigitalWalletModel? get digitalWalletModel {
    return _digitalWalletModel;
  }
  
  List<ShoppingBagModel>? get shoppingBagModels {
    return _shoppingBagModels;
  }
  
  TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  String? get userModelStoreOwnerModelId {
    return _userModelStoreOwnerModelId;
  }
  
  String? get userModelDigitalWalletModelId {
    return _userModelDigitalWalletModelId;
  }
  
  const UserModel._internal({required this.id, required email, required name, imageUrl, creditCards, bankAccount, storeOwnerModel, digitalWalletModel, shoppingBagModels, createdAt, updatedAt, userModelStoreOwnerModelId, userModelDigitalWalletModelId}): _email = email, _name = name, _imageUrl = imageUrl, _creditCards = creditCards, _bankAccount = bankAccount, _storeOwnerModel = storeOwnerModel, _digitalWalletModel = digitalWalletModel, _shoppingBagModels = shoppingBagModels, _createdAt = createdAt, _updatedAt = updatedAt, _userModelStoreOwnerModelId = userModelStoreOwnerModelId, _userModelDigitalWalletModelId = userModelDigitalWalletModelId;
  
  factory UserModel({String? id, required String email, required String name, String? imageUrl, String? creditCards, String? bankAccount, StoreOwnerModel? storeOwnerModel, DigitalWalletModel? digitalWalletModel, List<ShoppingBagModel>? shoppingBagModels, String? userModelStoreOwnerModelId, String? userModelDigitalWalletModelId}) {
    return UserModel._internal(
      id: id == null ? UUID.getUUID() : id,
      email: email,
      name: name,
      imageUrl: imageUrl,
      creditCards: creditCards,
      bankAccount: bankAccount,
      storeOwnerModel: storeOwnerModel,
      digitalWalletModel: digitalWalletModel,
      shoppingBagModels: shoppingBagModels != null ? List<ShoppingBagModel>.unmodifiable(shoppingBagModels) : shoppingBagModels,
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
      _email == other._email &&
      _name == other._name &&
      _imageUrl == other._imageUrl &&
      _creditCards == other._creditCards &&
      _bankAccount == other._bankAccount &&
      _storeOwnerModel == other._storeOwnerModel &&
      _digitalWalletModel == other._digitalWalletModel &&
      DeepCollectionEquality().equals(_shoppingBagModels, other._shoppingBagModels) &&
      _userModelStoreOwnerModelId == other._userModelStoreOwnerModelId &&
      _userModelDigitalWalletModelId == other._userModelDigitalWalletModelId;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("UserModel {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("email=" + "$_email" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("imageUrl=" + "$_imageUrl" + ", ");
    buffer.write("creditCards=" + "$_creditCards" + ", ");
    buffer.write("bankAccount=" + "$_bankAccount" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null") + ", ");
    buffer.write("userModelStoreOwnerModelId=" + "$_userModelStoreOwnerModelId" + ", ");
    buffer.write("userModelDigitalWalletModelId=" + "$_userModelDigitalWalletModelId");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  UserModel copyWith({String? id, String? email, String? name, String? imageUrl, String? creditCards, String? bankAccount, StoreOwnerModel? storeOwnerModel, DigitalWalletModel? digitalWalletModel, List<ShoppingBagModel>? shoppingBagModels, String? userModelStoreOwnerModelId, String? userModelDigitalWalletModelId}) {
    return UserModel._internal(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      creditCards: creditCards ?? this.creditCards,
      bankAccount: bankAccount ?? this.bankAccount,
      storeOwnerModel: storeOwnerModel ?? this.storeOwnerModel,
      digitalWalletModel: digitalWalletModel ?? this.digitalWalletModel,
      shoppingBagModels: shoppingBagModels ?? this.shoppingBagModels,
      userModelStoreOwnerModelId: userModelStoreOwnerModelId ?? this.userModelStoreOwnerModelId,
      userModelDigitalWalletModelId: userModelDigitalWalletModelId ?? this.userModelDigitalWalletModelId);
  }
  
  UserModel.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _email = json['email'],
      _name = json['name'],
      _imageUrl = json['imageUrl'],
      _creditCards = json['creditCards'],
      _bankAccount = json['bankAccount'],
      _storeOwnerModel = json['storeOwnerModel']?['serializedData'] != null
        ? StoreOwnerModel.fromJson(new Map<String, dynamic>.from(json['storeOwnerModel']['serializedData']))
        : null,
      _digitalWalletModel = json['digitalWalletModel']?['serializedData'] != null
        ? DigitalWalletModel.fromJson(new Map<String, dynamic>.from(json['digitalWalletModel']['serializedData']))
        : null,
      _shoppingBagModels = json['shoppingBagModels'] is List
        ? (json['shoppingBagModels'] as List)
          .where((e) => e?['serializedData'] != null)
          .map((e) => ShoppingBagModel.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
          .toList()
        : null,
      _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null,
      _userModelStoreOwnerModelId = json['userModelStoreOwnerModelId'],
      _userModelDigitalWalletModelId = json['userModelDigitalWalletModelId'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'email': _email, 'name': _name, 'imageUrl': _imageUrl, 'creditCards': _creditCards, 'bankAccount': _bankAccount, 'storeOwnerModel': _storeOwnerModel?.toJson(), 'digitalWalletModel': _digitalWalletModel?.toJson(), 'shoppingBagModels': _shoppingBagModels?.map((ShoppingBagModel? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format(), 'userModelStoreOwnerModelId': _userModelStoreOwnerModelId, 'userModelDigitalWalletModelId': _userModelDigitalWalletModelId
  };

  static final QueryField ID = QueryField(fieldName: "userModel.id");
  static final QueryField EMAIL = QueryField(fieldName: "email");
  static final QueryField NAME = QueryField(fieldName: "name");
  static final QueryField IMAGEURL = QueryField(fieldName: "imageUrl");
  static final QueryField CREDITCARDS = QueryField(fieldName: "creditCards");
  static final QueryField BANKACCOUNT = QueryField(fieldName: "bankAccount");
  static final QueryField STOREOWNERMODEL = QueryField(
    fieldName: "storeOwnerModel",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (StoreOwnerModel).toString()));
  static final QueryField DIGITALWALLETMODEL = QueryField(
    fieldName: "digitalWalletModel",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (DigitalWalletModel).toString()));
  static final QueryField SHOPPINGBAGMODELS = QueryField(
    fieldName: "shoppingBagModels",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (ShoppingBagModel).toString()));
  static final QueryField USERMODELSTOREOWNERMODELID = QueryField(fieldName: "userModelStoreOwnerModelId");
  static final QueryField USERMODELDIGITALWALLETMODELID = QueryField(fieldName: "userModelDigitalWalletModelId");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "UserModel";
    modelSchemaDefinition.pluralName = "UserModels";
    
    modelSchemaDefinition.authRules = [
      AuthRule(
        authStrategy: AuthStrategy.PUBLIC,
        operations: [
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
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: UserModel.NAME,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: UserModel.IMAGEURL,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: UserModel.CREDITCARDS,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: UserModel.BANKACCOUNT,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasOne(
      key: UserModel.STOREOWNERMODEL,
      isRequired: false,
      ofModelName: (StoreOwnerModel).toString(),
      associatedKey: StoreOwnerModel.ID
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasOne(
      key: UserModel.DIGITALWALLETMODEL,
      isRequired: false,
      ofModelName: (DigitalWalletModel).toString(),
      associatedKey: DigitalWalletModel.ID
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
      key: UserModel.SHOPPINGBAGMODELS,
      isRequired: false,
      ofModelName: (ShoppingBagModel).toString(),
      associatedKey: ShoppingBagModel.USERMODELID
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: UserModel.USERMODELSTOREOWNERMODELID,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: UserModel.USERMODELDIGITALWALLETMODELID,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
  });
}

class _UserModelModelType extends ModelType<UserModel> {
  const _UserModelModelType();
  
  @override
  UserModel fromJson(Map<String, dynamic> jsonData) {
    return UserModel.fromJson(jsonData);
  }
}