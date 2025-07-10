import 'package:denbigh_app/widgets/misc.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor("F4F6F8"),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: hexToColor("438823"),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Row(
                      children: [
                        Container(width: 50, height: 50, child: Placeholder()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text("Khrisean Stewart"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(FeatherIcons.logOut, color: Colors.white),
                  ),
                ],
              ),
              TextField(
                decoration: InputDecoration(
                  
                  hint: Row(children: [Icon(Icons.search), Text("Search...")]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
