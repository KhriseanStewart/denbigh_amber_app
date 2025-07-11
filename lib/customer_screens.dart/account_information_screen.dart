import 'package:denbigh_app/utils/validators_%20and_widgets.dart';
import 'package:denbigh_app/widgets/textField.dart';
import 'package:flutter/material.dart';

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({Key? key}) : super(key: key);

  @override
  _AccountInformationScreenState createState() => _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isSaving = false;

  void _save() {
    // Simulate a save operation the firestor logic should be here
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    Future.delayed( Duration(seconds: 2), () {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Account information saved successfully!')),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Account Information'),
      ),
      body: Padding(
        padding:  EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
                  ?  CircularProgressIndicator()
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
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