import 'package:flutter/material.dart';

import '../dummy_data.dart';
import '../widgets/category_item.dart';

class PaymentScreen extends StatelessWidget {

  static const routeName = '/payment';

  @override
  Widget build(BuildContext context) {
    return GridView(
      padding: const EdgeInsets.all(25),
      children: [DUMMY_CATEGORIES.map(
            (catData) => CategoryItem(
          catData.id,
          catData.title,
          catData.color,
        ),
      ).toList()
        ,].expand((i) => i).toList(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
    );
  }
}
