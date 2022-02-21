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

import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:flutter/foundation.dart';

/** This is an auto generated class representing the PhysicalStoreModel type in your schema. */
@immutable
class PhysicalStoreModel extends Model {
  static const classType = const _PhysicalStoreModelModelType();
  final String id;
  final String name;
  final String phoneNumber;
  final String address;
  final String operationHours;
  final String categories;
  final String qrCode;

  @override
  getInstanceType() => classType;

  @override
  String getId() {
    return id;
  }

  const PhysicalStoreModel._internal(
      {@required this.id,
      this.name,
      this.phoneNumber,
      this.address,
      this.operationHours,
      this.categories,
      this.qrCode});

  factory PhysicalStoreModel(
      {String id,
      String name,
      String phoneNumber,
      String address,
      String operationHours,
      String categories,
      String qrCode}) {
    return PhysicalStoreModel._internal(
        id: id == null ? UUID.getUUID() : id,
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        operationHours: operationHours,
        categories: categories,
        qrCode: qrCode);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhysicalStoreModel &&
        id == other.id &&
        name == other.name &&
        phoneNumber == other.phoneNumber &&
        address == other.address &&
        operationHours == other.operationHours &&
        categories == other.categories &&
        qrCode == other.qrCode;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("PhysicalStoreModel {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$name" + ", ");
    buffer.write("phoneNumber=" + "$phoneNumber" + ", ");
    buffer.write("address=" + "$address" + ", ");
    buffer.write("operationHours=" + "$operationHours" + ", ");
    buffer.write("categories=" + "$categories" + ", ");
    buffer.write("qrCode=" + "$qrCode");
    buffer.write("}");

    return buffer.toString();
  }

  PhysicalStoreModel copyWith(
      {String id,
      String name,
      String phoneNumber,
      String address,
      String operationHours,
      String categories,
      String qrCode}) {
    return PhysicalStoreModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        address: address ?? this.address,
        operationHours: operationHours ?? this.operationHours,
        categories: categories ?? this.categories,
        qrCode: qrCode ?? this.qrCode);
  }

  PhysicalStoreModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        phoneNumber = json['phoneNumber'],
        address = json['address'],
        operationHours = json['operationHours'],
        categories = json['categories'],
        qrCode = json['qrCode'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'address': address,
        'operationHours': operationHours,
        'categories': categories,
        'qrCode': qrCode
      };

  static final QueryField ID = QueryField(fieldName: "physicalStoreModel.id");
  static final QueryField NAME = QueryField(fieldName: "name");
  static final QueryField PHONENUMBER = QueryField(fieldName: "phoneNumber");
  static final QueryField ADDRESS = QueryField(fieldName: "address");
  static final QueryField OPERATIONHOURS =
      QueryField(fieldName: "operationHours");
  static final QueryField CATEGORIES = QueryField(fieldName: "categories");
  static final QueryField QRCODE = QueryField(fieldName: "qrCode");
  static var schema =
      Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "PhysicalStoreModel";
    modelSchemaDefinition.pluralName = "PhysicalStoreModels";

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
        key: PhysicalStoreModel.NAME,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: PhysicalStoreModel.PHONENUMBER,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: PhysicalStoreModel.ADDRESS,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: PhysicalStoreModel.OPERATIONHOURS,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: PhysicalStoreModel.CATEGORIES,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: PhysicalStoreModel.QRCODE,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));
  });
}

class _PhysicalStoreModelModelType extends ModelType<PhysicalStoreModel> {
  const _PhysicalStoreModelModelType();

  @override
  PhysicalStoreModel fromJson(Map<String, dynamic> jsonData) {
    return PhysicalStoreModel.fromJson(jsonData);
  }
}
