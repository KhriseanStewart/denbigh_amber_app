import 'package:denbigh_app/routes.dart';
import 'package:denbigh_app/users/database/auth_service.dart';
import 'package:denbigh_app/utils/validators_%20and_widgets.dart';
import 'package:denbigh_app/widgets/autoCompleter.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _signupkey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController farmerId = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? selectedRole;
  String? selectedLocation; // Store selected location from autocomplete
  bool isLoggingIn = false;

  @override
  Widget build(BuildContext context) {
    void handleSubmit() async {
      setState(() {
        isLoggingIn = true;
      });
      if (_signupkey.currentState!.validate()) {
        final name = nameController.text;
        final location =
            selectedLocation ?? ''; // Use selected location from autocomplete
        final email = emailController.text;
        final password = passwordController.text;
        final radaId = farmerId.text; // Get RADA ID from the controller

        if (password == confirmPasswordController.text) {
          if (selectedRole != null) {
            if (selectedLocation != null && selectedLocation!.isNotEmpty) {
              try {
                await AuthService().signUpWithEmail(
                  email: email,
                  password: password,
                  role: selectedRole!,
                  location: location,
                  name: name,
                  farmerId: selectedRole == 'farmer'
                      ? radaId
                      : null, // Only pass RADA ID for farmers
                );

                // Navigate based on role
                if (selectedRole == 'farmer') {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRouter.farmermainlayout,
                  );
                } else {
                  // For users and other roles, go to main layout
                  Navigator.pushReplacementNamed(context, AppRouter.mainlayout);
                }
              } on FirebaseAuthException catch (e) {
                setState(() {
                  isLoggingIn = false;
                });
                displaySnackBar(context, "Error signing up: $e");
              }
            } else {
              setState(() {
                isLoggingIn = false;
              });
              displaySnackBar(context, "Please select a location");
            }
          } else {
            setState(() {
              isLoggingIn = false;
            });
            displaySnackBar(context, "Please select a role");
          }
        } else {
          setState(() {
            isLoggingIn = false;
          });
          displaySnackBar(context, "Passwords not the same");
        }
      } else {
        setState(() {
          isLoggingIn = false;
        });
        displaySnackBar(context, "Something is wrong. Please check the Form");
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: hexToColor("F4F6F8")),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _signupkey,
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
                      "AgriConnect",
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
                      "Create a new account",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 👤 Name
                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration(
                      "Enter Your Full Name",
                      Icons.person,
                    ),
                    validator: validateNotEmpty,
                  ),
                  const SizedBox(height: 16),

                  // 📍 Location
                  LocationAutoComplete(
                    onCategorySelected: (location) {
                      selectedLocation = location; // Capture selected location
                    },
                  ),
                  const SizedBox(height: 16),

                  // 📧 Email
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

                  // 🔒 Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration(
                      "Create a Password",
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
                    validator: passwordValidator,
                  ),
                  const SizedBox(height: 16),

                  // 🔒 Confirm Password
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration(
                      "Confirm Password",
                      Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: passwordValidator,
                  ),
                  const SizedBox(height: 24),

                  // 🟢 Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Hook up registration logic here
                        handleSubmit();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLoggingIn
                            ? Colors.transparent
                            : Colors.green.shade800,
                      ),
                      child: isLoggingIn
                          ? CircularProgressIndicator()
                          : Text(
                              "Sign Up",
                              style: TextStyle(
                                color: isLoggingIn
                                    ? Colors.black
                                    : Colors.white,
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
                          "Or Register With",
                          style: TextStyle(color: Colors.black),
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

                  // 🔁 Sign In Prompt
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRouter.login,
                            );
                          },
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
    );
  }
}
