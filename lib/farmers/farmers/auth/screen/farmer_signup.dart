// ignore_for_file: use_build_context_synchronously

import 'package:denbigh_app/farmers/farmers/auth/authentification/auth.dart';
import 'package:denbigh_app/farmers/farmers/auth/screen/farmer_login.dart';
import 'package:denbigh_app/routes.dart';
import 'package:denbigh_app/users/database/auth_service.dart';
import 'package:denbigh_app/users/screens/dashboard/home.dart';
import 'package:denbigh_app/utils/validators_%20and_widgets.dart';
import 'package:denbigh_app/widgets/autoCompleter.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FarmerSignUp extends StatefulWidget {
  const FarmerSignUp({super.key});

  @override
  State<FarmerSignUp> createState() => _FarmerSignUpState();
}

bool _obscurePassword = true;
bool _obscureId = true;
bool _rememberMe = false;
bool isLoggin = false;

class _FarmerSignUpState extends State<FarmerSignUp> {
  String? location;
  final _signinkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController radaNumberController = TextEditingController();
  final TextEditingController authpasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void handleSubmit() async {
      setState(() {
        isLoggin = true;
      });
      if (_signinkey.currentState?.validate() ?? false) {
        final email = emailController.text.trim();
        final password = passwordController.text;
        final radaNum = radaNumberController.text;
        final authpassword = authpasswordController.text;
        final name = nameController.text;
        if (password == authpassword) {
          try {
            final result = await FarmerAuthService().signUpWithEmail(
              email,
              password,
            );
            if (result == true) {
              final dataResult = await FarmerAuthService().setUpdateFarmerData(
                auth!.uid,
                name,
                location ?? '',
                radaNum,
              );
              if (dataResult == true) {
                //TODO: add farmer mainLayout
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FarmerLogin()),
                );
              } else {
                displaySnackBar(context, "Something went wrong");
              }
            } else {
              displaySnackBar(
                context,
                "Invalid email or password",
                backgroundColor: Colors.red,
              );
            }
          } on FirebaseAuth catch (e) {
            displaySnackBar(
              context,
              "Error happened: $e",
              backgroundColor: Colors.red,
            );
            setState(() {
              isLoggin = false;
            });
          }
        } else {
          displaySnackBar(context, "Passwords incorrect");
        }
      }
      setState(() {
        isLoggin = false;
      });
    }

    void pushFarmerLogIn() {
      Navigator.pushReplacementNamed(context, AppRouter.farmerlogin);
    }

    void pushForgetPassword() async {
      final email = emailController.text.trim();
      try {
        await AuthService().sendPasswordResetEmail(email);
      } on FirebaseAuth catch (e) {
        displaySnackBar(context, "Error occured: $e");
      }
    }

    void pushUserLogin() {
      Navigator.pushNamed(context, AppRouter.login);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: hexToColor("F4F6F8")),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _signinkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.agriculture,
                      size: 64,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "AgriConnect - Farmer",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "Create Farmer Account",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      "Welcome to AgriConnect - Enjoy your stay",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 📧 Name Field
                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration(
                      "Enter Your Name",
                      Icons.person,
                    ),
                    validator: validateNotEmpty,
                  ),

                  const SizedBox(height: 16),

                  // 📧 Email Field
                  TextFormField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration(
                      "Enter Your Email",
                      Icons.email,
                    ),
                    validator: emailValidator,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: radaNumberController,
                          obscureText: _obscureId,
                          style: const TextStyle(color: Colors.black),
                          decoration: _inputDecoration(
                            "RADA ID Number",
                            Icons.lock,
                            suffix: IconButton(
                              icon: Icon(
                                _obscureId
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureId = !_obscureId;
                                });
                              },
                            ),
                          ),
                          validator: validateNotEmpty,
                        ),
                      ),
                      Expanded(
                        child: //Location
                        LocationAutoComplete(
                          onCategorySelected: (p0) {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 🔒 Password Field
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration(
                      "Enter Your Password",
                      Icons.password,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: passwordValidator,
                  ),
                  const SizedBox(height: 8),
                  // 🔒 Password Field
                  TextFormField(
                    controller: authpasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration(
                      "Confirm Password",
                      Icons.lock,
                      suffix: Icon(Icons.visibility_off, color: Colors.black),
                    ),
                    validator: passwordValidator,
                  ),
                  const SizedBox(height: 8),
                  // 🔘 Remember me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                            activeColor: Colors.black,
                            checkColor: Colors.black,
                          ),
                          const Text(
                            "Remember me",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () async {
                          pushForgetPassword();
                          //forgot password logic
                        },
                        child: const Text(
                          "Forget Password?",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 🟢 Log In Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        //loginLogic
                        isLoggin ? null : handleSubmit();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade800,
                      ),
                      child: isLoggin
                          ? CircularProgressIndicator()
                          : Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ⚫ Divider
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.black)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "Or Continue With",
                          style: TextStyle(color: Colors.black38),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 🌐 Social Logins
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _socialButton("Google", Icons.g_mobiledata),
                      // _socialButton("Apple", Icons.apple),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 🆕 Sign Up prompt
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have a Farmer account? ",
                          style: TextStyle(color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to Sign Up
                            pushFarmerLogIn();
                          },
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Log in as User? ",
                          style: TextStyle(color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to Sign Up
                            pushUserLogin();
                          },
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black),
      prefixIcon: Icon(icon, color: Colors.grey),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _socialButton(String label, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AuthService().signInWithGoogle();
        },
        child: Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
