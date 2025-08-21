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
  final Function(String?)? onSaved;
  final Function(String?)? onChanged;
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
    this.onChanged,
    this.decoration,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Color(0xFF4CAF50);
    final errorColor = Color(0xFFE57373);
    final fillColor = Color(0xFFF1F8E9);

    InputBorder enabledBorder;
    InputBorder focusedBorder;
    InputBorder errorBorder;
    InputBorder focusedErrorBorder;

    if (underlineborder) {
      enabledBorder = UnderlineInputBorder(
        borderSide: BorderSide(color: borderColor.withOpacity(0.7), width: 1),
      );
      focusedBorder = UnderlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 2),
      );
      errorBorder = UnderlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 1),
      );
      focusedErrorBorder = UnderlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 2),
      );
    } else {
      enabledBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor.withOpacity(0.3), width: 1),
      );
      focusedBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 2),
      );
      errorBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor, width: 1),
      );
      focusedErrorBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor, width: 2),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        validator: validator,
        maxLines: obscureText ? 1 : (maxLines ?? 1),
        initialValue: initialValue,
        onSaved: onSaved,
        onChanged: onChanged,
        style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32)),
        decoration:
            decoration ??
            InputDecoration(
              suffix: suffix,
              suffixIcon: suffixicon,
              prefixIcon: preffixicon,
              prefixIconColor: Color(0xFF4CAF50),
              labelText: label,
              labelStyle: TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w500,
              ),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: fillColor,
              enabledBorder: enabledBorder,
              focusedBorder: focusedBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: focusedErrorBorder,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
      ),
    );
  }
}
