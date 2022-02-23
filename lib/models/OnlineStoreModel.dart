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


/** This is an auto generated class representing the OnlineStoreModel type in your schema. */
@immutable
class OnlineStoreModel extends Model {
  static const classType = const _OnlineStoreModelModelType();
  final String id;
  final String? _name;
  final String? _phoneNumber;
  final String? _address;
  final String? _operationHours;
  final String? _categories;
  final List<ProductModel>? _productModel;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @override
  String getId() {
    return id;
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
  
  String get phoneNumber {
    try {
      return _phoneNumber!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get address {
    try {
      return _address!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get operationHours {
    try {
      return _operationHours!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get categories {
    try {
      return _categories!;
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
  
  TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const OnlineStoreModel._internal({required this.id, required name, required phoneNumber, required address, required operationHours, required categories, productModel, createdAt, updatedAt}): _name = name, _phoneNumber = phoneNumber, _address = address, _operationHours = operationHours, _categories = categories, _productModel = productModel, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory OnlineStoreModel({String? id, required String name, required String phoneNumber, required String address, required String operationHours, required String categories, List<ProductModel>? productModel}) {
    return OnlineStoreModel._internal(
      id: id == null ? UUID.getUUID() : id,
      name: name,
      phoneNumber: phoneNumber,
      address: address,
      operationHours: operationHours,
      categories: categories,
      productModel: productModel != null ? List<ProductModel>.unmodifiable(productModel) : productModel);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OnlineStoreModel &&
      id == other.id &&
      _name == other._name &&
      _phoneNumber == other._phoneNumber &&
      _address == other._address &&
      _operationHours == other._operationHours &&
      _categories == other._categories &&
      DeepCollectionEquality().equals(_productModel, other._productModel);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("OnlineStoreModel {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("phoneNumber=" + "$_phoneNumber" + ", ");
    buffer.write("address=" + "$_address" + ", ");
    buffer.write("operationHours=" + "$_operationHours" + ", ");
    buffer.write("categories=" + "$_categories" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  OnlineStoreModel copyWith({String? id, String? name, String? phoneNumber, String? address, String? operationHours, String? categories, List<ProductModel>? productModel}) {
    return OnlineStoreModel._internal(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      operationHours: operationHours ?? this.operationHours,
      categories: categories ?? this.categories,
      productModel: productModel ?? this.productModel);
  }
  
  OnlineStoreModel.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _name = json['name'],
      _phoneNumber = json['phoneNumber'],
      _address = json['address'],
      _operationHours = json['operationHours'],
      _categories = json['categories'],
      _productModel = json['productModel'] is List
        ? (json['productModel'] as List)
          .where((e) => e?['serializedData'] != null)
          .map((e) => ProductModel.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
          .toList()
        : null,
      _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': _name, 'phoneNumber': _phoneNumber, 'address': _address, 'operationHours': _operationHours, 'categories': _categories, 'productModel': _productModel?.map((ProductModel? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };

  static final QueryField ID = QueryField(fieldName: "onlineStoreModel.id");
  static final QueryField NAME = QueryField(fieldName: "name");
  static final QueryField PHONENUMBER = QueryField(fieldName: "phoneNumber");
  static final QueryField ADDRESS = QueryField(fieldName: "address");
  static final QueryField OPERATIONHOURS = QueryField(fieldName: "operationHours");
  static final QueryField CATEGORIES = QueryField(fieldName: "categories");
  static final QueryField PRODUCTMODEL = QueryField(
    fieldName: "productModel",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (ProductModel).toString()));
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "OnlineStoreModel";
    modelSchemaDefinition.pluralName = "OnlineStoreModels";
    
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
      key: OnlineStoreModel.NAME,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: OnlineStoreModel.PHONENUMBER,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: OnlineStoreModel.ADDRESS,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: OnlineStoreModel.OPERATIONHOURS,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: OnlineStoreModel.CATEGORIES,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
      key: OnlineStoreModel.PRODUCTMODEL,
      isRequired: false,
      ofModelName: (ProductModel).toString(),
      associatedKey: ProductModel.ONLINESTOREMODELID
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
  });
}

class _OnlineStoreModelModelType extends ModelType<OnlineStoreModel> {
  const _OnlineStoreModelModelType();
  
  @override
  OnlineStoreModel fromJson(Map<String, dynamic> jsonData) {
    return OnlineStoreModel.fromJson(jsonData);
  }
}