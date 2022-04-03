import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/widgets/search_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late List<StoreDTO> relevantStores;

  @override
  void initState() {
    super.initState();
    relevantStores = [];
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      hint: 'Search',
      borderRadius: BorderRadius.circular(20.0),
      automaticallyImplyDrawerHamburger: false,
      automaticallyImplyBackButton: false,
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      openAxisAlignment: 0.0,
      onQueryChanged: (query) {
        Provider.of<User>(context, listen: false)
            .getStoresByKeywords(query)
            .then((value) => setState(() => relevantStores = value));
      },
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
    );
  }
}
