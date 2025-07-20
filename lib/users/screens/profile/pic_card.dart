import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/users/screens/dashboard/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PicCard extends StatefulWidget {
  const PicCard({super.key});

  @override
  State<PicCard> createState() => _PicCardState();
}

class _PicCardState extends State<PicCard> {
  final userPhotoUrl = auth?.photoURL;

  Future<String?> getProfileString(String uid) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      return data?['photoUrl'] as String?;
    } else {
      return null;
    }
  }

  String? profileString;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    getProfileString(uid).then((value) {
      setState(() {
        profileString = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return profileString == null
        ? CircleAvatar(
            radius: 90,
            backgroundColor: Colors.green,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey[300],
              child:  Icon(Icons.person, size: 40, color: Colors.white),
            ),
          )
        : CircleAvatar(
            radius: 90,
            backgroundColor: Colors.green,
            child: CircleAvatar(
              radius: 81,
              backgroundImage: NetworkImage(profileString!),
            ),
          );
  }
}
