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
import 'package:flutter/foundation.dart';

/** This is an auto generated class representing the StoreOwnerModel type in your schema. */
@immutable
class StoreOwnerModel extends Model {
  static const classType = const _StoreOwnerModelModelType();
  final String id;
  final OnlineStoreModel onlineStoreModel;
  final PhysicalStoreModel physicalStoreModel;
  final String storeOwnerModelOnlineStoreModelId;
  final String storeOwnerModelPhysicalStoreModelId;

  @override
  getInstanceType() => classType;

  @override
  String getId() {
    return id;
  }

  const StoreOwnerModel._internal(
      {@required this.id,
      this.onlineStoreModel,
      this.physicalStoreModel,
      this.storeOwnerModelOnlineStoreModelId,
      this.storeOwnerModelPhysicalStoreModelId});

  factory StoreOwnerModel(
      {String id,
      OnlineStoreModel onlineStoreModel,
      PhysicalStoreModel physicalStoreModel,
      String storeOwnerModelOnlineStoreModelId,
      String storeOwnerModelPhysicalStoreModelId}) {
    return StoreOwnerModel._internal(
        id: id == null ? UUID.getUUID() : id,
        onlineStoreModel: onlineStoreModel,
        physicalStoreModel: physicalStoreModel,
        storeOwnerModelOnlineStoreModelId: storeOwnerModelOnlineStoreModelId,
        storeOwnerModelPhysicalStoreModelId:
            storeOwnerModelPhysicalStoreModelId);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StoreOwnerModel &&
        id == other.id &&
        onlineStoreModel == other.onlineStoreModel &&
        physicalStoreModel == other.physicalStoreModel &&
        storeOwnerModelOnlineStoreModelId ==
            other.storeOwnerModelOnlineStoreModelId &&
        storeOwnerModelPhysicalStoreModelId ==
            other.storeOwnerModelPhysicalStoreModelId;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("StoreOwnerModel {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("storeOwnerModelOnlineStoreModelId=" +
        "$storeOwnerModelOnlineStoreModelId" +
        ", ");
    buffer.write("storeOwnerModelPhysicalStoreModelId=" +
        "$storeOwnerModelPhysicalStoreModelId");
    buffer.write("}");

    return buffer.toString();
  }

  StoreOwnerModel copyWith(
      {String id,
      OnlineStoreModel onlineStoreModel,
      PhysicalStoreModel physicalStoreModel,
      String storeOwnerModelOnlineStoreModelId,
      String storeOwnerModelPhysicalStoreModelId}) {
    return StoreOwnerModel(
        id: id ?? this.id,
        onlineStoreModel: onlineStoreModel ?? this.onlineStoreModel,
        physicalStoreModel: physicalStoreModel ?? this.physicalStoreModel,
        storeOwnerModelOnlineStoreModelId: storeOwnerModelOnlineStoreModelId ??
            this.storeOwnerModelOnlineStoreModelId,
        storeOwnerModelPhysicalStoreModelId:
            storeOwnerModelPhysicalStoreModelId ??
                this.storeOwnerModelPhysicalStoreModelId);
  }

  StoreOwnerModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        onlineStoreModel = json['onlineStoreModel'] != null
            ? OnlineStoreModel.fromJson(
                new Map<String, dynamic>.from(json['onlineStoreModel']))
            : null,
        physicalStoreModel = json['physicalStoreModel'] != null
            ? PhysicalStoreModel.fromJson(
                new Map<String, dynamic>.from(json['physicalStoreModel']))
            : null,
        storeOwnerModelOnlineStoreModelId =
            json['storeOwnerModelOnlineStoreModelId'],
        storeOwnerModelPhysicalStoreModelId =
            json['storeOwnerModelPhysicalStoreModelId'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'onlineStoreModel': onlineStoreModel?.toJson(),
        'physicalStoreModel': physicalStoreModel?.toJson(),
        'storeOwnerModelOnlineStoreModelId': storeOwnerModelOnlineStoreModelId,
        'storeOwnerModelPhysicalStoreModelId':
            storeOwnerModelPhysicalStoreModelId
      };

  static final QueryField ID = QueryField(fieldName: "storeOwnerModel.id");
  static final QueryField ONLINESTOREMODEL = QueryField(
      fieldName: "onlineStoreModel",
      fieldType: ModelFieldType(ModelFieldTypeEnum.model,
          ofModelName: (OnlineStoreModel).toString()));
  static final QueryField PHYSICALSTOREMODEL = QueryField(
      fieldName: "physicalStoreModel",
      fieldType: ModelFieldType(ModelFieldTypeEnum.model,
          ofModelName: (PhysicalStoreModel).toString()));
  static final QueryField STOREOWNERMODELONLINESTOREMODELID =
      QueryField(fieldName: "storeOwnerModelOnlineStoreModelId");
  static final QueryField STOREOWNERMODELPHYSICALSTOREMODELID =
      QueryField(fieldName: "storeOwnerModelPhysicalStoreModelId");
  static var schema =
      Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "StoreOwnerModel";
    modelSchemaDefinition.pluralName = "StoreOwnerModels";

    modelSchemaDefinition.authRules = [
      AuthRule(authStrategy: AuthStrategy.PUBLIC, operations: [
        ModelOperation.CREATE,
        ModelOperation.UPDATE,
        ModelOperation.DELETE,
        ModelOperation.READ
      ])
    ];

    modelSchemaDefinition.addField(ModelFieldDefinition.id());

    modelSchemaDefinition.addField(ModelFieldDefinition.hasOne(
        key: StoreOwnerModel.ONLINESTOREMODEL,
        isRequired: false,
        ofModelName: (OnlineStoreModel).toString(),
        associatedKey: OnlineStoreModel.ID));

    modelSchemaDefinition.addField(ModelFieldDefinition.hasOne(
        key: StoreOwnerModel.PHYSICALSTOREMODEL,
        isRequired: false,
        ofModelName: (PhysicalStoreModel).toString(),
        associatedKey: PhysicalStoreModel.ID));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: StoreOwnerModel.STOREOWNERMODELONLINESTOREMODELID,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: StoreOwnerModel.STOREOWNERMODELPHYSICALSTOREMODELID,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));
  });
}

class _StoreOwnerModelModelType extends ModelType<StoreOwnerModel> {
  const _StoreOwnerModelModelType();

  @override
  StoreOwnerModel fromJson(Map<String, dynamic> jsonData) {
    return StoreOwnerModel.fromJson(jsonData);
  }
}
