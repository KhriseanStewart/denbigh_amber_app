import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FarmerAuthService {
  final auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;

  Future<bool?> signUpWithEmail(String email, String password ) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print("Error signing in: $e");
      return false;
    }
  }

  Future<bool> logInWithEmail(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print("Error logging in $e");
      return false;
    }
  }

  Future<bool?> checkRadaId(String uid, String radaId) async {
    try {
      final docSnapshot = await db.collection("farmersData").doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey('radaRegistrationNumber')) {
          if (data['radaRegistrationNumber'] == radaId) {
            print(data['radaRegistrationNumber']);
            return true;
          } else {
            return false;
          }
        } else {
          print("Rada Registration Number not found");
          return false;
        }
      } else {
        print("Document does not exist");
        return false;
      }
    } catch (e) {
      print("Error getting Rada Id: $e");
      return false;
    }
  }

  Future<bool?> setUpdateFarmerData(
    String uid,
    String name,
    String location,
    String radaNumber,
  ) async {
    try {
      await db.collection("farmersData").doc(user!.uid).set({
        "farmerName": name,
        "location": location,
        "radaRegistrationNumber": radaNumber,
        "farmerId": uid,
        "createdAt": FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }
}
