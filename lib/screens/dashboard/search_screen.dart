import 'package:denbigh_app/screens/product_screen/home_product_card.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor("F4F6F8"),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: TextField(
                          onTap: () {},
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                            hint: Text("Search..."),
                          ),
                        ),
                      ),
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          icon: Icon(FeatherIcons.sliders, size: 28),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            buildGridViewProducts(),
          ],
        ),
      ),
    );
  }

  Widget buildFilterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            icon: Icon(FeatherIcons.sliders, size: 28),
          ),
        ),
      ],
    );
  }

  Widget buildGridViewProducts() {
    return Expanded(
      child: GridView.builder(
        itemCount: 6,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              //TODO: push to detail page
            },
            child: ProductCard(),
          );
        },
      ),
    );
  }
}
