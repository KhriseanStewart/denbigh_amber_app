import 'package:denbigh_app/src/users/database/lists.dart';
import 'package:denbigh_app/src/utils/validators_%20and_widgets.dart';
import 'package:flutter/material.dart';

class LocationAutoComplete extends StatefulWidget {
  final Function(String?) onCategorySelected;
  final bool? underlineBorder;
  const LocationAutoComplete({
    super.key,
    required this.onCategorySelected,
    this.underlineBorder,
  });

  @override
  _LocationAutoCompleteState createState() => _LocationAutoCompleteState();
}

class _LocationAutoCompleteState extends State<LocationAutoComplete> {
  @override
  Widget build(BuildContext context) {
    print('LocationAutoComplete build called');
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        print(
          'LocationAutoComplete optionsBuilder called with: ${textEditingValue.text}',
        );
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        try {
          final results = jamaicaParishesWithTowns
              .where((String category) {
                // Filter out null, empty, or malformed entries
                if (category.isEmpty || category.trim().isEmpty) {
                  print('LocationAutoComplete: Filtering out empty category');
                  return false;
                }

                return category.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
              })
              .map((category) => category.trim()) // Ensure no extra whitespace
              .where(
                (category) => category.isNotEmpty,
              ); // Double-check after trimming

          print(
            'LocationAutoComplete optionsBuilder returning ${results.length} results',
          );
          return results;
        } catch (e) {
          print('Error in LocationAutoComplete optionsBuilder: $e');
          print('Error stack trace: ${e.toString()}');
          return const Iterable<String>.empty();
        }
      },
      onSelected: (String selection) {
        print('LocationAutoComplete onSelected called with: $selection');
        try {
          // Validate the selection is not null or empty
          if (selection.isEmpty) {
            print('LocationAutoComplete: Empty selection received');
            return;
          }

          // Trim any extra whitespace
          final cleanSelection = selection.trim();
          if (cleanSelection.isEmpty) {
            print('LocationAutoComplete: Selection is empty after trimming');
            return;
          }

          print(
            'LocationAutoComplete: Calling onCategorySelected with clean selection: $cleanSelection',
          );
          widget.onCategorySelected(cleanSelection);
          print('LocationAutoComplete onSelected completed successfully');
        } catch (e) {
          print('Error in LocationAutoComplete onSelected: $e');
          print('Error stack trace: ${e.toString()}');
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
