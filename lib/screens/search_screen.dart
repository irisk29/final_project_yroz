import 'package:final_project_yroz/dummy_data.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

import '../DTOs/StoreDTO.dart';
import '../LogicLayer/User.dart';
import '../widgets/search_bar_item.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FloatingSearchBarController controller = FloatingSearchBarController();
  late List<StoreDTO> relevantStores;

  @override
  void initState() {
    super.initState();
    relevantStores = [];
  }

  void getStoresByQuery(String query) {
    Provider.of<User>(context, listen: false)
        .getStoresByKeywords(query)
        .then((value) => setState(() => relevantStores = value));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Column(
            children: [
              SizedBox(height: constraints.maxHeight * 0.125),
              Center(
                child: Container(
                  width: constraints.maxWidth * 0.85,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: constraints.maxWidth * 0.015,
                    children: DUMMY_CATEGORIES
                        .map((c) => FilterChip(
                              label: Text(c.title),
                              onSelected: (_) {
                                controller.query = c.title;
                                controller.open();
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          FloatingSearchBar(
            hint: 'search by keywords',
            controller: controller,
            borderRadius: BorderRadius.circular(20.0),
            automaticallyImplyDrawerHamburger: false,
            automaticallyImplyBackButton: false,
            transitionCurve: Curves.easeInOut,
            physics: const BouncingScrollPhysics(),
            openAxisAlignment: 0.0,
            onQueryChanged: getStoresByQuery,
            // Specify a custom transition to be used for
            // animating between opened and closed stated.
            transition: CircularFloatingSearchBarTransition(),
            actions: [],
            leadingActions: [
              FloatingSearchBarAction.searchToClear(),
            ],
            builder: (context, transition) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Material(
                  color: Colors.white,
                  elevation: 4.0,
                  child: ListView.builder(
                      itemCount: relevantStores.length,
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        var store = relevantStores[index];
                        return SearchBarItem(store);
                      }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
