import 'package:flutter/material.dart';
import 'package:project_demo/DataLayer/StoreStorageProxy.dart';
import 'package:project_demo/models/PhysicalStoreModel.dart';

import './models/category.dart';
import 'models/store.dart';

const DUMMY_CATEGORIES = const [
  Category(
    id: 'c1',
    title: 'Food',
    color: Colors.pinkAccent,
  ),
  Category(
    id: 'c2',
    title: 'Home',
    color: Colors.yellow,
  ),
];

// const DUMMY_STORES = const [
//   Store(
//     id: 's1',
//     title: 'Chocolate',
//     address: 'GOOD ADDRESS',
//   ),
//   Store(
//     id: 's2',
//     title: 'Furniture',
//     address: 'BAD ADDRESS',
//   ),
// ];
