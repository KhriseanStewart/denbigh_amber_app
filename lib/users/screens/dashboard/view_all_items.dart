import 'package:denbigh_app/users/screens/product_screen/home_product_card.dart';
import 'package:flutter/material.dart';

class ViewAllItems extends StatelessWidget {
  const ViewAllItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildGridViewProducts());
  }

  Widget buildGridViewProducts() {
    return SizedBox(
      height: 500,
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
