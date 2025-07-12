import 'package:flutter/material.dart';

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
    final args = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: AppBar(title: Text("Ripe Banana"), centerTitle: true),
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
                      final scale = (1 - (_currentPage - index)).abs().clamp(
                        0.8,
                        1.0,
                      );
                      return Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              '',
                              fit: BoxFit.cover,
                            ),
                          ),
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
                           '',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Type: ",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'destination.description',
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
