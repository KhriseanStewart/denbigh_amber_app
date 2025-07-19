import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final TextInputType inputType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixicon;
  final Widget? suffix;
  final Icon? preffixicon;
  final VoidCallback? toggleObscure;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final bool underlineborder; 
  final String? initialValue;
  final  Function(String?)? onSaved;
  final InputDecoration? decoration;
final int? maxLines;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.label,
    this.suffixicon,
    this.suffix,
    this.preffixicon,
    this.inputType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.toggleObscure,
    this.hintText,
    this.inputFormatters,
    this.underlineborder = false, 
    this.initialValue,
    this.onSaved,
    this.decoration,
     this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.black;
    final errorColor = Colors.red;

    InputBorder enabledBorder;
    InputBorder focusedBorder;
    InputBorder errorBorder;
    InputBorder focusedErrorBorder;

    if (underlineborder) {
      enabledBorder = UnderlineInputBorder(borderSide: BorderSide(color: borderColor, width: 0.5));
      focusedBorder = UnderlineInputBorder(borderSide: BorderSide(color: borderColor, width: 1));
      errorBorder = UnderlineInputBorder(borderSide: BorderSide(color: errorColor, width: 0.5));
      focusedErrorBorder = UnderlineInputBorder(borderSide: BorderSide(color: errorColor, width: 1));
    } else {
      enabledBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 0.5),
      );
      focusedBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 1),
      );
      errorBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: errorColor, width: 0.5),
      );
      focusedErrorBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: errorColor, width: 1),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          suffix: suffix,
          suffixIcon: suffixicon,
          prefixIcon: preffixicon,
          prefixIconColor: Colors.blue,
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          enabledBorder: enabledBorder,
          focusedBorder: focusedBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: focusedErrorBorder,
        ),
      ),
    );
  }
}
