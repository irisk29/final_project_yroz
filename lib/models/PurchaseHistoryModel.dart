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
import 'package:flutter/foundation.dart';


/** This is an auto generated class representing the PurchaseHistoryModel type in your schema. */
@immutable
class PurchaseHistoryModel extends Model {
  static const classType = const _PurchaseHistoryModelModelType();
  final String id;
  final TemporalDate? _date;
  final double? _amount;
  final UserModel? _userModel;
  final OnlineStoreModel? _onlineStoreModel;
  final PhysicalStoreModel? _physicalStoreModel;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;
  final String? _purchaseHistoryModelUserModelId;
  final String? _purchaseHistoryModelOnlineStoreModelId;
  final String? _purchaseHistoryModelPhysicalStoreModelId;

  @override
  getInstanceType() => classType;
  
  @override
  String getId() {
    return id;
  }
  
  TemporalDate get date {
    try {
      return _date!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get amount {
    try {
      return _amount!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  UserModel? get userModel {
    return _userModel;
  }
  
  OnlineStoreModel? get onlineStoreModel {
    return _onlineStoreModel;
  }
  
  PhysicalStoreModel? get physicalStoreModel {
    return _physicalStoreModel;
  }
  
  TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  String? get purchaseHistoryModelUserModelId {
    return _purchaseHistoryModelUserModelId;
  }
  
  String? get purchaseHistoryModelOnlineStoreModelId {
    return _purchaseHistoryModelOnlineStoreModelId;
  }
  
  String? get purchaseHistoryModelPhysicalStoreModelId {
    return _purchaseHistoryModelPhysicalStoreModelId;
  }
  
  const PurchaseHistoryModel._internal({required this.id, required date, required amount, userModel, onlineStoreModel, physicalStoreModel, createdAt, updatedAt, purchaseHistoryModelUserModelId, purchaseHistoryModelOnlineStoreModelId, purchaseHistoryModelPhysicalStoreModelId}): _date = date, _amount = amount, _userModel = userModel, _onlineStoreModel = onlineStoreModel, _physicalStoreModel = physicalStoreModel, _createdAt = createdAt, _updatedAt = updatedAt, _purchaseHistoryModelUserModelId = purchaseHistoryModelUserModelId, _purchaseHistoryModelOnlineStoreModelId = purchaseHistoryModelOnlineStoreModelId, _purchaseHistoryModelPhysicalStoreModelId = purchaseHistoryModelPhysicalStoreModelId;
  
  factory PurchaseHistoryModel({String? id, required TemporalDate date, required double amount, UserModel? userModel, OnlineStoreModel? onlineStoreModel, PhysicalStoreModel? physicalStoreModel, String? purchaseHistoryModelUserModelId, String? purchaseHistoryModelOnlineStoreModelId, String? purchaseHistoryModelPhysicalStoreModelId}) {
    return PurchaseHistoryModel._internal(
      id: id == null ? UUID.getUUID() : id,
      date: date,
      amount: amount,
      userModel: userModel,
      onlineStoreModel: onlineStoreModel,
      physicalStoreModel: physicalStoreModel,
      purchaseHistoryModelUserModelId: purchaseHistoryModelUserModelId,
      purchaseHistoryModelOnlineStoreModelId: purchaseHistoryModelOnlineStoreModelId,
      purchaseHistoryModelPhysicalStoreModelId: purchaseHistoryModelPhysicalStoreModelId);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PurchaseHistoryModel &&
      id == other.id &&
      _date == other._date &&
      _amount == other._amount &&
      _userModel == other._userModel &&
      _onlineStoreModel == other._onlineStoreModel &&
      _physicalStoreModel == other._physicalStoreModel &&
      _purchaseHistoryModelUserModelId == other._purchaseHistoryModelUserModelId &&
      _purchaseHistoryModelOnlineStoreModelId == other._purchaseHistoryModelOnlineStoreModelId &&
      _purchaseHistoryModelPhysicalStoreModelId == other._purchaseHistoryModelPhysicalStoreModelId;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("PurchaseHistoryModel {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("date=" + (_date != null ? _date!.format() : "null") + ", ");
    buffer.write("amount=" + (_amount != null ? _amount!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null") + ", ");
    buffer.write("purchaseHistoryModelUserModelId=" + "$_purchaseHistoryModelUserModelId" + ", ");
    buffer.write("purchaseHistoryModelOnlineStoreModelId=" + "$_purchaseHistoryModelOnlineStoreModelId" + ", ");
    buffer.write("purchaseHistoryModelPhysicalStoreModelId=" + "$_purchaseHistoryModelPhysicalStoreModelId");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  PurchaseHistoryModel copyWith({String? id, TemporalDate? date, double? amount, UserModel? userModel, OnlineStoreModel? onlineStoreModel, PhysicalStoreModel? physicalStoreModel, String? purchaseHistoryModelUserModelId, String? purchaseHistoryModelOnlineStoreModelId, String? purchaseHistoryModelPhysicalStoreModelId}) {
    return PurchaseHistoryModel._internal(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      userModel: userModel ?? this.userModel,
      onlineStoreModel: onlineStoreModel ?? this.onlineStoreModel,
      physicalStoreModel: physicalStoreModel ?? this.physicalStoreModel,
      purchaseHistoryModelUserModelId: purchaseHistoryModelUserModelId ?? this.purchaseHistoryModelUserModelId,
      purchaseHistoryModelOnlineStoreModelId: purchaseHistoryModelOnlineStoreModelId ?? this.purchaseHistoryModelOnlineStoreModelId,
      purchaseHistoryModelPhysicalStoreModelId: purchaseHistoryModelPhysicalStoreModelId ?? this.purchaseHistoryModelPhysicalStoreModelId);
  }
  
  PurchaseHistoryModel.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _date = json['date'] != null ? TemporalDate.fromString(json['date']) : null,
      _amount = (json['amount'] as num?)?.toDouble(),
      _userModel = json['userModel']?['serializedData'] != null
        ? UserModel.fromJson(new Map<String, dynamic>.from(json['userModel']['serializedData']))
        : null,
      _onlineStoreModel = json['onlineStoreModel']?['serializedData'] != null
        ? OnlineStoreModel.fromJson(new Map<String, dynamic>.from(json['onlineStoreModel']['serializedData']))
        : null,
      _physicalStoreModel = json['physicalStoreModel']?['serializedData'] != null
        ? PhysicalStoreModel.fromJson(new Map<String, dynamic>.from(json['physicalStoreModel']['serializedData']))
        : null,
      _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null,
      _purchaseHistoryModelUserModelId = json['purchaseHistoryModelUserModelId'],
      _purchaseHistoryModelOnlineStoreModelId = json['purchaseHistoryModelOnlineStoreModelId'],
      _purchaseHistoryModelPhysicalStoreModelId = json['purchaseHistoryModelPhysicalStoreModelId'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'date': _date?.format(), 'amount': _amount, 'userModel': _userModel?.toJson(), 'onlineStoreModel': _onlineStoreModel?.toJson(), 'physicalStoreModel': _physicalStoreModel?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format(), 'purchaseHistoryModelUserModelId': _purchaseHistoryModelUserModelId, 'purchaseHistoryModelOnlineStoreModelId': _purchaseHistoryModelOnlineStoreModelId, 'purchaseHistoryModelPhysicalStoreModelId': _purchaseHistoryModelPhysicalStoreModelId
  };

  static final QueryField ID = QueryField(fieldName: "purchaseHistoryModel.id");
  static final QueryField DATE = QueryField(fieldName: "date");
  static final QueryField AMOUNT = QueryField(fieldName: "amount");
  static final QueryField USERMODEL = QueryField(
    fieldName: "userModel",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (UserModel).toString()));
  static final QueryField ONLINESTOREMODEL = QueryField(
    fieldName: "onlineStoreModel",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (OnlineStoreModel).toString()));
  static final QueryField PHYSICALSTOREMODEL = QueryField(
    fieldName: "physicalStoreModel",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (PhysicalStoreModel).toString()));
  static final QueryField PURCHASEHISTORYMODELUSERMODELID = QueryField(fieldName: "purchaseHistoryModelUserModelId");
  static final QueryField PURCHASEHISTORYMODELONLINESTOREMODELID = QueryField(fieldName: "purchaseHistoryModelOnlineStoreModelId");
  static final QueryField PURCHASEHISTORYMODELPHYSICALSTOREMODELID = QueryField(fieldName: "purchaseHistoryModelPhysicalStoreModelId");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "PurchaseHistoryModel";
    modelSchemaDefinition.pluralName = "PurchaseHistoryModels";
    
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
      key: PurchaseHistoryModel.DATE,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.date)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: PurchaseHistoryModel.AMOUNT,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasOne(
      key: PurchaseHistoryModel.USERMODEL,
      isRequired: false,
      ofModelName: (UserModel).toString(),
      associatedKey: UserModel.ID
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasOne(
      key: PurchaseHistoryModel.ONLINESTOREMODEL,
      isRequired: false,
      ofModelName: (OnlineStoreModel).toString(),
      associatedKey: OnlineStoreModel.ID
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasOne(
      key: PurchaseHistoryModel.PHYSICALSTOREMODEL,
      isRequired: false,
      ofModelName: (PhysicalStoreModel).toString(),
      associatedKey: PhysicalStoreModel.ID
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
      key: PurchaseHistoryModel.PURCHASEHISTORYMODELUSERMODELID,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: PurchaseHistoryModel.PURCHASEHISTORYMODELONLINESTOREMODELID,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: PurchaseHistoryModel.PURCHASEHISTORYMODELPHYSICALSTOREMODELID,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
  });
}

class _PurchaseHistoryModelModelType extends ModelType<PurchaseHistoryModel> {
  const _PurchaseHistoryModelModelType();
  
  @override
  PurchaseHistoryModel fromJson(Map<String, dynamic> jsonData) {
    return PurchaseHistoryModel.fromJson(jsonData);
  }
}