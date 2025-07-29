import 'package:denbigh_app/users/database/lists.dart';
import 'package:denbigh_app/utils/validators_%20and_widgets.dart';
import 'package:flutter/material.dart';

class LocationAutoComplete extends StatefulWidget {
  final Function(String?) onCategorySelected;
  final bool? underlineBorder;
  const LocationAutoComplete({super.key, required this.onCategorySelected, this.underlineBorder});

  @override
  _LocationAutoCompleteState createState() => _LocationAutoCompleteState();
}

class _LocationAutoCompleteState extends State<LocationAutoComplete> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        try {
          return jamaicaParishesWithTowns.where((String category) {
            return category.toLowerCase().contains(
              textEditingValue.text.toLowerCase(),
            );
          });
        } catch (e) {
          print('Error in LocationAutoComplete optionsBuilder: $e');
          return const Iterable<String>.empty();
        }
      },
      onSelected: (String selection) {
        try {
          widget.onCategorySelected(selection);
        } catch (e) {
          print('Error in LocationAutoComplete onSelected: $e');
        }
      },
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController controller,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            try {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Enter Location",
                  hintStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.location_on, color: Colors.grey),
                  border: widget.underlineBorder == true
                      ? UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        )
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                  enabledBorder: widget.underlineBorder == true
                      ? UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        )
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                ),
                validator: validateNotEmpty,
              );
            } catch (e) {
              print('Error in LocationAutoComplete fieldViewBuilder: $e');
              return TextFormField(
                decoration: InputDecoration(
                  hintText: "Error loading location field",
                  border: OutlineInputBorder(),
                ),
              );
            }
          },
    );
  }
}
