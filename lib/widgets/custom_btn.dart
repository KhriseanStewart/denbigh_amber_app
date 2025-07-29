import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final double? width;
  final double? height;
  final String btntext;
  final Color? bgcolor;
  final OutlinedBorder? shape;
  final Color? textcolor;
  final VoidCallback? onpress;
  final bool isItalic;
  final bool isBoldtext;
  final double? size;

  const CustomButton({
    super.key,
    required this.btntext,
    this.height,
    this.width,
    this.bgcolor,
    this.onpress,
    this.shape,
    this.textcolor,
    this.isItalic = false,
    this.isBoldtext = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape:
              shape ??
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: bgcolor ?? Color.fromRGBO(55, 255, 72, 0.6),
        ),
        onPressed: onpress,
        child: Text(
          btntext,
          style: TextStyle(
            color: textcolor,
            fontSize: size,
            fontWeight: isBoldtext ? FontWeight.bold : FontWeight.w200,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

class CustomButtonElevated extends StatelessWidget {
  final double? width;
  final double? height;
  final String btntext;
  final Color? bgcolor;
  final OutlinedBorder? shape;
  final Color? textcolor;
  final VoidCallback? onpress;
  final bool isItalic;
  final bool isBoldtext;
  final double? size;
  final Icon? icon;

  const CustomButtonElevated({
    super.key,
    required this.btntext,
    this.height,
    this.width,
    this.bgcolor,
    this.onpress,
    this.shape,
    this.textcolor,
    this.isItalic = false,
    this.isBoldtext = false,
    this.size,
    this.icon
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          shape:
              shape ??
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: bgcolor ?? Color.fromRGBO(55, 255, 72, 0.6),
        ),
        icon: icon,
        onPressed: onpress,
        label: Text(
          btntext,
          style: TextStyle(
            color: textcolor,
            fontSize: size,
            fontWeight: isBoldtext ? FontWeight.bold : FontWeight.w200,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
