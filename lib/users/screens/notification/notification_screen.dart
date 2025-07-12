import 'package:denbigh_app/widgets/misc.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor("F4F6F8"),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Notifications"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 10,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        height: 10,
                        padding: EdgeInsets.all(5),
                      ),
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        width: 50,
                        height: 50,
                        child: Placeholder(),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("John now has Carrots for sale"),
                          Text("Updated 2 minutes ago"),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    width: 50,
                    height: 50,
                    child: Placeholder(),
                  ),
                ],
              ),
            ),
            //NEXT ONE
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.yellow,
                        ),
                        height: 10,
                        padding: EdgeInsets.all(5),
                      ),
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        width: 50,
                        height: 50,
                        child: Icon(FeatherIcons.truck, size: 35),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Your items were deliveried"),
                          Text("Updated 2 minutes ago"),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    width: 50,
                    height: 50,
                    child: Placeholder(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
