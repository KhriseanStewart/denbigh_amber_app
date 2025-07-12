import 'package:flutter/material.dart';

class PicCard extends StatefulWidget {
  const PicCard({super.key});

  @override
  State<PicCard> createState() => _PicCardState();
}

class _PicCardState extends State<PicCard> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 90,
      backgroundColor: Colors.green,
      child: CircleAvatar(
        radius: 80,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.person, size: 40, color: Colors.white),
      ),
    );
  }
}
