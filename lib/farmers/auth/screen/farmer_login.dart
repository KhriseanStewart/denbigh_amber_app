// ignore_for_file: use_build_context_synchronously

import 'package:denbigh_app/farmers/auth/authentification/auth.dart';
import 'package:denbigh_app/routes.dart';
import 'package:denbigh_app/users/database/auth_service.dart';
import 'package:denbigh_app/utils/validators_%20and_widgets.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FarmerLogin extends StatefulWidget {
  const FarmerLogin({super.key});

  @override
  State<FarmerLogin> createState() => _FarmerLoginState();
}

bool _obscurePassword = true;
bool _rememberMe = false;
bool isLoggin = false;

class _FarmerLoginState extends State<FarmerLogin> {
  final _signinkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController radaNumController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void handleSubmit() async {
      setState(() {
        isLoggin = true;
      });
      if (_signinkey.currentState?.validate() ?? false) {
        final email = emailController.text.trim();
        final password = passwordController.text;
        final radaNum = radaNumController.text;
        try {
          final result = await FarmerAuthService().logInWithEmail(
            email,
            password,
          );
          final currentUser = FirebaseAuth.instance.currentUser;

          if (result == true) {
            final uid = await FirebaseAuth.instance.currentUser!.uid;
            final radaResult = await FarmerAuthService().checkRadaId(
              uid,
              radaNum,
            );
            if (radaResult == true) {
              Navigator.pushReplacementNamed(
                context,
                AppRouter.farmermainlayout,
              );
            } else {
              displaySnackBar(context, "Incorrect RADA ID doesnt work");
            }
          } else {
            displaySnackBar(
              context,
              "Invalid email or password",
              backgroundColor: Colors.red,
            );
          }
        } on FirebaseAuthException catch (e) {
          displaySnackBar(
            context,
            "Error happened: ${e.message}",
            backgroundColor: Colors.red,
          );
          setState(() {
            isLoggin = false;
          });
        }
      }
      setState(() {
        isLoggin = false;
      });
    }

    void pushSignUp() {
      Navigator.pushReplacementNamed(context, AppRouter.farmersignup);
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
      Navigator.pushReplacementNamed(context, AppRouter.login);
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
                   Center(
                    child: Icon(
                      Icons.agriculture,
                      size: 64,
                      color: Colors.green,
                    ),
                  ),
                  Center(
                    child: Text(
                      "AgriConnect - Farmer",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Sign in to your account",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      "Welcome back! Select method to log in",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 32),

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

                  // 🔒 Password Field
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration(
                      "Enter Your Password",
                      Icons.lock,
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
                    validator: validateNotEmpty,
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: radaNumController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration(
                      "Enter Your RADA ID",
                      Icons.lock,
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
                    validator: validateNotEmpty,
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

                  //  Log In Button
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
                              "Log In",
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
                            pushSignUp();
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
