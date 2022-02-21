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
import 'DigitalWalletModel.dart';
import 'OnlineStoreModel.dart';
import 'PhysicalStoreModel.dart';
import 'ProductModel.dart';
import 'PurchaseHistoryModel.dart';
import 'ShoppingBagModel.dart';
import 'StoreOwnerModel.dart';
import 'UserModel.dart';

export 'DigitalWalletModel.dart';
export 'OnlineStoreModel.dart';
export 'PhysicalStoreModel.dart';
export 'ProductModel.dart';
export 'PurchaseHistoryModel.dart';
export 'ShoppingBagModel.dart';
export 'StoreOwnerModel.dart';
export 'UserModel.dart';

class ModelProvider implements ModelProviderInterface {
  @override
  String version = "aa3f82f2de66cc6d05955ba921c7c5cb";
  @override
  List<ModelSchema> modelSchemas = [
    DigitalWalletModel.schema,
    OnlineStoreModel.schema,
    PhysicalStoreModel.schema,
    ProductModel.schema,
    PurchaseHistoryModel.schema,
    ShoppingBagModel.schema,
    StoreOwnerModel.schema,
    UserModel.schema
  ];
  static final ModelProvider _instance = ModelProvider();

  static ModelProvider get instance => _instance;

  ModelType getModelTypeByModelName(String modelName) {
    switch (modelName) {
      case "DigitalWalletModel":
        {
          return DigitalWalletModel.classType;
        }
        break;
      case "OnlineStoreModel":
        {
          return OnlineStoreModel.classType;
        }
        break;
      case "PhysicalStoreModel":
        {
          return PhysicalStoreModel.classType;
        }
        break;
      case "ProductModel":
        {
          return ProductModel.classType;
        }
        break;
      case "PurchaseHistoryModel":
        {
          return PurchaseHistoryModel.classType;
        }
        break;
      case "ShoppingBagModel":
        {
          return ShoppingBagModel.classType;
        }
        break;
      case "StoreOwnerModel":
        {
          return StoreOwnerModel.classType;
        }
        break;
      case "UserModel":
        {
          return UserModel.classType;
        }
        break;
      default:
        {
          throw Exception(
              "Failed to find model in model provider for model name: " +
                  modelName);
        }
    }
  }
}
