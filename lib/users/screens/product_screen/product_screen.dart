import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

final PageController _pageController = PageController();
double _currentPage = 0;

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final args =
        ModalRoute.of(context)!.settings.arguments as QueryDocumentSnapshot;
    return Scaffold(
      backgroundColor: hexToColor("F4F6F8"),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(FeatherIcons.shoppingCart),
            style: IconButton.styleFrom(backgroundColor: Colors.white24),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 4),
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: double.infinity,
                        child: Image.network(
                          args['imageUrl'],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade400,
                                highlightColor: Colors.grey.shade200,
                                child: Container(color: Colors.grey),
                              );
                            }
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported_outlined,
                              size: 90,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            args['name'],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Type: ${args['category']}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        '',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class BottomDots extends StatelessWidget {
//   const BottomDots({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         spacing: 10,
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             decoration: BoxDecoration(
//               color: index == 0
//                   ? Colors.blue
//                   : Colors.black,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           Container(
//             width: 10,
//             height: 10,
//             decoration: BoxDecoration(
//               color: index == 1
//                   ? Colors.blue
//                   : Colors.black,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           Container(
//             width: 10,
//             height: 10,
//             decoration: BoxDecoration(
//               color: index == 2
//                   ? Colors.blue
//                   : Colors.black,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
