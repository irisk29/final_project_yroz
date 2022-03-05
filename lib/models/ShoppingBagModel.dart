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
  final List<ProductModel>? _productModels;
  final OnlineStoreModel? _onlineStoreModel;
  final String? _usermodelID;
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
  
  List<ProductModel>? get productModels {
    return _productModels;
  }
  
  OnlineStoreModel? get onlineStoreModel {
    return _onlineStoreModel;
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
  
  TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  String? get shoppingBagModelOnlineStoreModelId {
    return _shoppingBagModelOnlineStoreModelId;
  }
  
  const ShoppingBagModel._internal({required this.id, productsAndQuantity, productModels, onlineStoreModel, required usermodelID, createdAt, updatedAt, shoppingBagModelOnlineStoreModelId}): _productsAndQuantity = productsAndQuantity, _productModels = productModels, _onlineStoreModel = onlineStoreModel, _usermodelID = usermodelID, _createdAt = createdAt, _updatedAt = updatedAt, _shoppingBagModelOnlineStoreModelId = shoppingBagModelOnlineStoreModelId;
  
  factory ShoppingBagModel({String? id, String? productsAndQuantity, List<ProductModel>? productModels, OnlineStoreModel? onlineStoreModel, required String usermodelID, String? shoppingBagModelOnlineStoreModelId}) {
    return ShoppingBagModel._internal(
      id: id == null ? UUID.getUUID() : id,
      productsAndQuantity: productsAndQuantity,
      productModels: productModels != null ? List<ProductModel>.unmodifiable(productModels) : productModels,
      onlineStoreModel: onlineStoreModel,
      usermodelID: usermodelID,
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
      DeepCollectionEquality().equals(_productModels, other._productModels) &&
      _onlineStoreModel == other._onlineStoreModel &&
      _usermodelID == other._usermodelID &&
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
  
  ShoppingBagModel copyWith({String? id, String? productsAndQuantity, List<ProductModel>? productModels, OnlineStoreModel? onlineStoreModel, String? usermodelID, String? shoppingBagModelOnlineStoreModelId}) {
    return ShoppingBagModel._internal(
      id: id ?? this.id,
      productsAndQuantity: productsAndQuantity ?? this.productsAndQuantity,
      productModels: productModels ?? this.productModels,
      onlineStoreModel: onlineStoreModel ?? this.onlineStoreModel,
      usermodelID: usermodelID ?? this.usermodelID,
      shoppingBagModelOnlineStoreModelId: shoppingBagModelOnlineStoreModelId ?? this.shoppingBagModelOnlineStoreModelId);
  }
  
  ShoppingBagModel.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _productsAndQuantity = json['productsAndQuantity'],
      _productModels = json['productModels'] is List
        ? (json['productModels'] as List)
          .where((e) => e?['serializedData'] != null)
          .map((e) => ProductModel.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
          .toList()
        : null,
      _onlineStoreModel = json['onlineStoreModel']?['serializedData'] != null
        ? OnlineStoreModel.fromJson(new Map<String, dynamic>.from(json['onlineStoreModel']['serializedData']))
        : null,
      _usermodelID = json['usermodelID'],
      _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null,
      _shoppingBagModelOnlineStoreModelId = json['shoppingBagModelOnlineStoreModelId'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'productsAndQuantity': _productsAndQuantity, 'productModels': _productModels?.map((ProductModel? e) => e?.toJson()).toList(), 'onlineStoreModel': _onlineStoreModel?.toJson(), 'usermodelID': _usermodelID, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format(), 'shoppingBagModelOnlineStoreModelId': _shoppingBagModelOnlineStoreModelId
  };

  static final QueryField ID = QueryField(fieldName: "shoppingBagModel.id");
  static final QueryField PRODUCTSANDQUANTITY = QueryField(fieldName: "productsAndQuantity");
  static final QueryField PRODUCTMODELS = QueryField(
    fieldName: "productModels",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (ProductModel).toString()));
  static final QueryField ONLINESTOREMODEL = QueryField(
    fieldName: "onlineStoreModel",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (OnlineStoreModel).toString()));
  static final QueryField USERMODELID = QueryField(fieldName: "usermodelID");
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
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
      key: ShoppingBagModel.PRODUCTMODELS,
      isRequired: false,
      ofModelName: (ProductModel).toString(),
      associatedKey: ProductModel.SHOPPINGBAGMODELID
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasOne(
      key: ShoppingBagModel.ONLINESTOREMODEL,
      isRequired: false,
      ofModelName: (OnlineStoreModel).toString(),
      associatedKey: OnlineStoreModel.ID
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: ShoppingBagModel.USERMODELID,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
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
      isRequired: false,
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