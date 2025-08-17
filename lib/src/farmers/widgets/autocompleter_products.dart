import 'package:denbigh_app/src/farmers/widgets/used_list/list.dart';

import 'package:denbigh_app/src/utils/validators_%20and_widgets.dart';
import 'package:flutter/material.dart';

class AutocompleterProducts extends StatefulWidget {
  final Function(String?) onNameSelected;
  final bool? underlineBorder;
  const AutocompleterProducts({super.key, required this.onNameSelected, this.underlineBorder});

  @override
  _AutocompleterProductsState createState() => _AutocompleterProductsState();
}

class _AutocompleterProductsState extends State<AutocompleterProducts> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return farmProductNames.where((String Name) {
          return Name.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: (String selection) {
        widget.onNameSelected(selection);
      },
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController controller,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                label: Text('Product'),
                labelStyle: TextStyle(color: Colors.black),
                hintText:'e.g., Fresh Tomatoes',
                hintStyle: TextStyle(color: Colors.black),
              
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: .5),
                ),
             
              ),
              validator: validateNotEmpty,
            );
          },
    );
  }
}
