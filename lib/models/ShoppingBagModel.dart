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


/** This is an auto generated class representing the ShoppingBagModel type in your schema. */
@immutable
class ShoppingBagModel extends Model {
  static const classType = const _ShoppingBagModelModelType();
  final String id;
  final String? _productsAndQuantity;
  final String? _usermodelID;
  final List<ProductModel>? _productModel;
  final OnlineStoreModel? _onlineStoreModel;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;
  final String? _shoppingBagModelOnlineStoreModelId;

  @override
  getInstanceType() => classType;
  
  @override
  String getId() {
    return id;
  }
  
  String? get productsAndQuantity {
    return _productsAndQuantity;
  }
  
  String get usermodelID {
    try {
      return _usermodelID!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<ProductModel>? get productModel {
    return _productModel;
  }
  
  OnlineStoreModel get onlineStoreModel {
    try {
      return _onlineStoreModel!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  String get shoppingBagModelOnlineStoreModelId {
    try {
      return _shoppingBagModelOnlineStoreModelId!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  const ShoppingBagModel._internal({required this.id, productsAndQuantity, required usermodelID, productModel, required onlineStoreModel, createdAt, updatedAt, required shoppingBagModelOnlineStoreModelId}): _productsAndQuantity = productsAndQuantity, _usermodelID = usermodelID, _productModel = productModel, _onlineStoreModel = onlineStoreModel, _createdAt = createdAt, _updatedAt = updatedAt, _shoppingBagModelOnlineStoreModelId = shoppingBagModelOnlineStoreModelId;
  
  factory ShoppingBagModel({String? id, String? productsAndQuantity, required String usermodelID, List<ProductModel>? productModel, required OnlineStoreModel onlineStoreModel, required String shoppingBagModelOnlineStoreModelId}) {
    return ShoppingBagModel._internal(
      id: id == null ? UUID.getUUID() : id,
      productsAndQuantity: productsAndQuantity,
      usermodelID: usermodelID,
      productModel: productModel != null ? List<ProductModel>.unmodifiable(productModel) : productModel,
      onlineStoreModel: onlineStoreModel,
      shoppingBagModelOnlineStoreModelId: shoppingBagModelOnlineStoreModelId);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShoppingBagModel &&
      id == other.id &&
      _productsAndQuantity == other._productsAndQuantity &&
      _usermodelID == other._usermodelID &&
      DeepCollectionEquality().equals(_productModel, other._productModel) &&
      _onlineStoreModel == other._onlineStoreModel &&
      _shoppingBagModelOnlineStoreModelId == other._shoppingBagModelOnlineStoreModelId;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("ShoppingBagModel {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("productsAndQuantity=" + "$_productsAndQuantity" + ", ");
    buffer.write("usermodelID=" + "$_usermodelID" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null") + ", ");
    buffer.write("shoppingBagModelOnlineStoreModelId=" + "$_shoppingBagModelOnlineStoreModelId");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  ShoppingBagModel copyWith({String? id, String? productsAndQuantity, String? usermodelID, List<ProductModel>? productModel, OnlineStoreModel? onlineStoreModel, String? shoppingBagModelOnlineStoreModelId}) {
    return ShoppingBagModel._internal(
      id: id ?? this.id,
      productsAndQuantity: productsAndQuantity ?? this.productsAndQuantity,
      usermodelID: usermodelID ?? this.usermodelID,
      productModel: productModel ?? this.productModel,
      onlineStoreModel: onlineStoreModel ?? this.onlineStoreModel,
      shoppingBagModelOnlineStoreModelId: shoppingBagModelOnlineStoreModelId ?? this.shoppingBagModelOnlineStoreModelId);
  }
  
  ShoppingBagModel.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _productsAndQuantity = json['productsAndQuantity'],
      _usermodelID = json['usermodelID'],
      _productModel = json['productModel'] is List
        ? (json['productModel'] as List)
          .where((e) => e?['serializedData'] != null)
          .map((e) => ProductModel.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
          .toList()
        : null,
      _onlineStoreModel = json['onlineStoreModel']?['serializedData'] != null
        ? OnlineStoreModel.fromJson(new Map<String, dynamic>.from(json['onlineStoreModel']['serializedData']))
        : null,
      _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null,
      _shoppingBagModelOnlineStoreModelId = json['shoppingBagModelOnlineStoreModelId'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'productsAndQuantity': _productsAndQuantity, 'usermodelID': _usermodelID, 'productModel': _productModel?.map((ProductModel? e) => e?.toJson()).toList(), 'onlineStoreModel': _onlineStoreModel?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format(), 'shoppingBagModelOnlineStoreModelId': _shoppingBagModelOnlineStoreModelId
  };

  static final QueryField ID = QueryField(fieldName: "shoppingBagModel.id");
  static final QueryField PRODUCTSANDQUANTITY = QueryField(fieldName: "productsAndQuantity");
  static final QueryField USERMODELID = QueryField(fieldName: "usermodelID");
  static final QueryField PRODUCTMODEL = QueryField(
    fieldName: "productModel",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (ProductModel).toString()));
  static final QueryField ONLINESTOREMODEL = QueryField(
    fieldName: "onlineStoreModel",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (OnlineStoreModel).toString()));
  static final QueryField SHOPPINGBAGMODELONLINESTOREMODELID = QueryField(fieldName: "shoppingBagModelOnlineStoreModelId");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "ShoppingBagModel";
    modelSchemaDefinition.pluralName = "ShoppingBagModels";
    
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
      key: ShoppingBagModel.PRODUCTSANDQUANTITY,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: ShoppingBagModel.USERMODELID,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
      key: ShoppingBagModel.PRODUCTMODEL,
      isRequired: false,
      ofModelName: (ProductModel).toString(),
      associatedKey: ProductModel.SHOPPINGBAGMODELID
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasOne(
      key: ShoppingBagModel.ONLINESTOREMODEL,
      isRequired: true,
      ofModelName: (OnlineStoreModel).toString(),
      associatedKey: OnlineStoreModel.ID
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
      key: ShoppingBagModel.SHOPPINGBAGMODELONLINESTOREMODELID,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
  });
}

class _ShoppingBagModelModelType extends ModelType<ShoppingBagModel> {
  const _ShoppingBagModelModelType();
  
  @override
  ShoppingBagModel fromJson(Map<String, dynamic> jsonData) {
    return ShoppingBagModel.fromJson(jsonData);
  }
}