import 'package:denbigh_app/users/database/auth_service.dart';
import 'package:denbigh_app/users/screens/dashboard/home.dart';
import 'package:denbigh_app/utils/validators_%20and_widgets.dart';
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
      print(e);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Information')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextFormField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'Jason Mitch',
                inputType: TextInputType.text,
                validator: validateNotEmpty,
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: _emailController,
                label: 'Email Address',
                hintText: 'jason.mitch@example.com',
                inputType: TextInputType.emailAddress,
                validator: emailValidator,
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: _phoneController,
                label: 'Phone Number',
                hintText: '8761234567',
                inputType: TextInputType.phone,
                validator: phoneNumberValidator,
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: _locationController,
                label: 'Location',
                inputType: TextInputType.text,
                validator: validateNotEmpty,
                hintText: 'May Pen, Jamaica',
              ),
              SizedBox(height: 32),
              _isSaving
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 32.0,
                        ),
                        textStyle: TextStyle(fontSize: 16.0),
                      ),
                      onPressed: _save,
                      child: Text('Save Changes'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
