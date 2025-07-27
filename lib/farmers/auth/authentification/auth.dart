import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FarmerAuthService {
  final auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;

  Future<bool?> signUpWithEmail(String email, String password) async {
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
      print("Checking RADA ID for UID: $uid with RADA ID: $radaId");
      final docSnapshot = await db.collection("farmersData").doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        print("Document data: $data");
        if (data != null && data.containsKey('radaRegistrationNumber')) {
          final storedRadaId = data['radaRegistrationNumber'];
          print("Stored RADA ID: $storedRadaId, Input RADA ID: $radaId");
          if (storedRadaId == radaId) {
            print("RADA ID match successful");
            return true;
          } else {
            print(
              "RADA ID mismatch: stored '$storedRadaId' vs input '$radaId'",
            );
            return false;
          }
        } else {
          print("Rada Registration Number field not found in document");
          print("Available fields: ${data?.keys}");
          return false;
        }
      } else {
        print("Document does not exist for UID: $uid");
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
