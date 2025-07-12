import 'package:denbigh_app/routes.dart';
import 'package:denbigh_app/users/screens/product_screen/home_product_card.dart';
import 'package:denbigh_app/users/screens/profile/pic_card.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _currentSliderPrice = 100;
  List<String> category = [
    'All',
    'Legumes',
    'Herbs & Spicies',
    'Roots & Tubers',
    'Condiments',
    'Fruits',
    'Vegetable',
  ];
  String? _selectedValue;
  @override
  void initState() {
    super.initState();
    _selectedValue = 'default';
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.red),
    );
  }

  Future<void> onRefresh() async {
    setState(() {
      //TODO: UPDATE UI IF REFRESHED
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(color: Colors.green),
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: AppBar(
            titleSpacing: 10,
            backgroundColor: Colors.green,
            leading: Container(
              decoration: BoxDecoration(shape: BoxShape.circle),
              width: 50,
              height: 100,
              child: PicCard(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  "Khrisean Stewart",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.notificationscreen);
                },
                icon: Icon(FeatherIcons.bell, color: Colors.black),
                style: IconButton.styleFrom(backgroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: hexToColor("F4F6F8"),
      drawerEnableOpenDragGesture: false,
      endDrawer: buildEndDrawer(),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SafeArea(
          child: Column(
            children: [
              buildHeader(),
              SizedBox(height: 10),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: buildFilterRow(),
                  ),
                  SizedBox(height: 4),
                  //TODO: gridview needs some tweaks with sizing
                  buildGridViewProducts(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEndDrawer() {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Filter",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ListTile(
                title: Text(
                  "Category",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 34,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: category.length,
                  itemBuilder: (context, index) {
                    final catName = category[index];
                    return Container(
                      margin: EdgeInsets.only(right: 6),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: Text(
                          catName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: Text(
                  "Price",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  Text(
                    "\$${_currentSliderPrice.round().toString()}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _currentSliderPrice,
                      min: 100,
                      max: 200000,
                      divisions: 100,
                      label: _currentSliderPrice.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderPrice = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Divider(),
              ListTile(
                title: Text(
                  "Delivery",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButton<String>(
                value: _selectedValue,
                hint: Text(_selectedValue ?? 'Select Zone'),
                onTap: () {
                  print(_selectedValue);
                },
                items: [
                  DropdownMenuItem(value: 'default', child: Text('Default')),
                  DropdownMenuItem(value: 'zone-one', child: Text('Zone 1')),
                  DropdownMenuItem(value: 'zone-two', child: Text('Zone 2')),
                  DropdownMenuItem(value: 'zone-three', child: Text('Zone 3')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                },
              ),
              Divider(),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text("Filter"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              //TODO: push agruments
              Navigator.pushNamed(
                context,
                AppRouter.productdetail,
                arguments: null,
              );
            },
            child: ProductCard(),
          );
        },
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
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
        ),
        TextButton(onPressed: () {}, child: Text("View All")),
      ],
    );
  }

  Widget buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
      child: Column(
        spacing: 20,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            onTap: () {
              Navigator.pushNamed(context, AppRouter.searchscreen);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.white,
              hint: Row(children: [Icon(Icons.search), Text("Search...")]),
            ),
          ),
        ],
      ),
    );
  }
}
