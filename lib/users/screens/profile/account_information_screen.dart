import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/users/database/auth_service.dart';
import 'package:denbigh_app/users/database/customer_service.dart'
    hide AuthService;
import 'package:denbigh_app/users/screens/dashboard/home.dart';
import 'package:denbigh_app/users/screens/profile/pic_card.dart';
import 'package:denbigh_app/utils/validators_%20and_widgets.dart';
import 'package:denbigh_app/widgets/autoCompleter.dart';
import 'package:denbigh_app/widgets/custom_btn.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:denbigh_app/widgets/textField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  _AccountInformationScreenState createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? location;
  bool _isSaving = false;

  void _save() async {
    // Simulate a save operation the firestor logic should be here
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final uid = auth!.uid;
      // ignore: unnecessary_null_comparison
      if (uid == null) {
        return;
      } else {
        // await FirebaseAuth.instance.currentUser!.verifyBeforeUpdateEmail(
        //   _emailController.text,
        // );
        AuthService().updateInformation(
          uid: uid,
          name: _nameController.text,
          location: _locationController.text,
          telephone: _phoneController.text,
        );
      }
    } on FirebaseException catch (e) {
      setState(() {
        _isSaving = false;
      });
    }

    setState(() {
      _isSaving = false;
    });
    displaySnackBar(context, 'Account information saved successfully!');
  }

  void disposeText() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
  }

  @override
  void dispose() {
    disposeText();
    super.dispose();
  }

  Future<DocumentSnapshot?> getUserData() async {
    if (auth?.uid != null) {
      try {
        return await CustomerService().getUserInformation(auth!.uid);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Information'),
        surfaceTintColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              Future.microtask(() {
                Navigator.pop(context);
              });
            }

            final data = snapshot.data;
            final docData = data?.data() as Map<String, dynamic>?;
            location = docData?['location'];

            // Extract user data with fallbacks
            final userName = docData?['name']?.toString() ?? 'Name';
            final userEmail = docData?['email']?.toString() ?? 'Email';
            final userPhone =
                docData?['telephone']?.toString() ?? 'Phone Number';

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    PicCard(),
                    SizedBox(height: 26),
                    CustomTextFormField(
                      controller: _nameController,
                      label: userName,
                      hintText: 'Jason Mitch',
                      inputType: TextInputType.text,
                      validator: validateNotEmpty,
                    ),
                    SizedBox(height: 16),
                    CustomTextFormField(
                      enabled: false,
                      controller: _emailController,
                      label: userEmail,
                      hintText: userEmail,
                      inputType: TextInputType.emailAddress,
                      validator: emailValidator,
                    ),
                    SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _phoneController,
                      label: userPhone,
                      hintText: '8761234567',
                      inputType: TextInputType.phone,
                      validator: phoneNumberValidator,
                    ),
                    SizedBox(height: 16),
                    LocationAutoComplete(
                      onCategorySelected: (p0) {
                        location = p0;
                        print(location);
                      },
                    ),
                    SizedBox(height: 32),
                    _isSaving
                        ? CircularProgressIndicator()
                        : CustomButtonElevated(
                            btntext: "Save changes",
                            textcolor: Colors.white,
                            size: 18,
                            isBoldtext: true,
                            onpress: _save,
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
