import 'package:flutter/material.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  @override
  Widget build(BuildContext context) {
    //there is no card information available yet, so we will show a placeholder

    return Scaffold(
      appBar: AppBar(
        title: Text('Card Information'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.construction, size: 48, color: Colors.blue),
                    SizedBox(height: 8.0),
                    Text('Card content coming soon!'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
