import 'package:cloud_firestore/cloud_firestore.dart';

class CheckUserRole {
  final _instance = FirebaseFirestore.instance;
  Future<String> getRole(String uid) async {
    //to check if the user exists in users
    final _user = _instance.collection("users");
    final DocumentSnapshot _userDoc = await _user.doc(uid).get();

    //to check if user exists in farmer
    final _farmer = _instance.collection("farmersData");
    final _farmerDoc = await _farmer.doc(uid).get();
    if (_userDoc.exists) {
      return 'user';
    } else if (_farmerDoc.exists) {
      return 'farmer';
    } else {
      return 'unknown';
    }
  }
}
