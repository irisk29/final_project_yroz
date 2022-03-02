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

import 'package:amplify_core/amplify_core.dart';
import 'package:flutter/foundation.dart';


/** This is an auto generated class representing the DigitalWalletModel type in your schema. */
@immutable
class DigitalWalletModel extends Model {
  static const classType = const _DigitalWalletModelModelType();
  final String id;
  final double? _cashBackAmount;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @override
  String getId() {
    return id;
  }
  
  double get cashBackAmount {
    try {
      return _cashBackAmount!;
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
  
  const DigitalWalletModel._internal({required this.id, required cashBackAmount, createdAt, updatedAt}): _cashBackAmount = cashBackAmount, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory DigitalWalletModel({String? id, required double cashBackAmount}) {
    return DigitalWalletModel._internal(
      id: id == null ? UUID.getUUID() : id,
      cashBackAmount: cashBackAmount);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DigitalWalletModel &&
      id == other.id &&
      _cashBackAmount == other._cashBackAmount;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("DigitalWalletModel {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("cashBackAmount=" + (_cashBackAmount != null ? _cashBackAmount!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  DigitalWalletModel copyWith({String? id, double? cashBackAmount}) {
    return DigitalWalletModel._internal(
      id: id ?? this.id,
      cashBackAmount: cashBackAmount ?? this.cashBackAmount);
  }
  
  DigitalWalletModel.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _cashBackAmount = (json['cashBackAmount'] as num?)?.toDouble(),
      _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'cashBackAmount': _cashBackAmount, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };

  static final QueryField ID = QueryField(fieldName: "digitalWalletModel.id");
  static final QueryField CASHBACKAMOUNT = QueryField(fieldName: "cashBackAmount");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "DigitalWalletModel";
    modelSchemaDefinition.pluralName = "DigitalWalletModels";
    
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
      key: DigitalWalletModel.CASHBACKAMOUNT,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.double)
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

class _DigitalWalletModelModelType extends ModelType<DigitalWalletModel> {
  const _DigitalWalletModelModelType();
  
  @override
  DigitalWalletModel fromJson(Map<String, dynamic> jsonData) {
    return DigitalWalletModel.fromJson(jsonData);
  }
}