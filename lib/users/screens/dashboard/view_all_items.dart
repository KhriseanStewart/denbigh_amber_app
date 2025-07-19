import 'package:denbigh_app/routes.dart';
import 'package:denbigh_app/users/database/product_services.dart';
import 'package:denbigh_app/users/screens/product_screen/product_card.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:flutter/material.dart';

class ViewAllItems extends StatelessWidget {
  const ViewAllItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor("F4F6F8"),
      appBar: AppBar(title: Text("View All"), centerTitle: true),
      body: buildGridViewProducts(),
    );
  }

  Widget buildGridViewProducts() {
    return Expanded(
      child: StreamBuilder(
        stream: ProductService().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text("No Product"));
          }
          final productdata = snapshot.data!.docs;
          return Expanded(
            child: GridView.builder(
              itemCount: productdata.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final data = productdata[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.productdetail,
                      arguments: data,
                    );
                  },
                  child: UserProductCard(data: data),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
