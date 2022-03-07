import 'package:flutter/material.dart';

class MultiSelect extends StatefulWidget {
  final List<String> items;
  const MultiSelect({Key? key, required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  // this variable holds the selected items
  final List<String> _selectedItems = [];

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Select Store Categories',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Divider(),
        SingleChildScrollView(
          child: ListBody(
            children: widget.items
                .map((item) => CheckboxListTile(
                      value: _selectedItems.contains(item),
                      title: Text(item),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (isChecked) => _itemChange(item, isChecked!),
                    ))
                .toList(),
          ),
        ),
        Wrap(
          children: _selectedItems
              .map((e) => Chip(
                    deleteIcon: Icon(
                      Icons.close,
                    ),
                    onDeleted: () {
                      setState(() {
                        _selectedItems.remove(e);
                      });
                    },
                    label: Text(e),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
