// import 'package:app1/shared/widgets/custom_appbar_button.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? color;
  final bool? automaticallyImplyLeading;
  const CustomAppBar({super.key, required this.title, this.actions, this.color, this.automaticallyImplyLeading});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: automaticallyImplyLeading ?? false,
      title: Text(
        title,

        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontFamily: 'Roboto',
        ),
      ),

      backgroundColor: color ?? Colors.amber[300],
      iconTheme: IconThemeData(color: Colors.black),
      elevation: 6,
      shadowColor: Colors.grey,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
      // [
        // CustomAppBarButton(
        //   icon: Icons.home,
        //   onPressed: () {
        //     Navigator.pushNamed(context, '/');
        //   },
        //   tooltip: 'Home',
  




    //     IconButton(
    //       onPressed: () {},
    //       icon: Icon(Icons.file_open),
    //       tooltip: 'Reset Field',
    //     );,
    //     IconButton(
    //       onPressed: () {},
    //       icon: Icon(Icons.menu),
    //       tooltip: 'Open Menu',
    //     );,
    //   ],
    // );
