import 'package:denbigh_app/src/farmers/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _radaRegController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // This is a placeholder. Replace with real geocoding logic.
  Future<GeoPoint> _getGeoPointFromAddress(String address) async {
    // TODO: Implement using a geocoding package or API.
    // Example: return GeoPoint(lat, lng);
    // For now, just return Kingston, Jamaica
    return GeoPoint(18.0179, -76.8099);
  }

  void _submit() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      if (_isLogin) {
        await auth.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw Exception('Passwords do not match.');
        }
        final geoPoint = await _getGeoPointFromAddress(
          _locationController.text.trim(),
        );
        await auth.signUp(
          _emailController.text.trim(),
          _passwordController.text,
          farmerName: _nameController.text.trim(),
          radaRegistrationNumber: _radaRegController.text.trim(),
          locationName: _locationController.text.trim(),
          location: geoPoint,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: EdgeInsets.all(24),
            child: Padding(
              padding: EdgeInsets.all(24.0),

              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isLogin ? 'Sign In' : 'Sign Up',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    if (!_isLogin) ...[
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                      ),
                      SizedBox(height: 8),
                    ],
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          color: Colors.black,
                        ),
                      ),
                      obscureText: _obscurePassword,
                    ),
                    SizedBox(height: 8),
                    if (!_isLogin) ...[
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                                  color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _radaRegController,
                        decoration: InputDecoration(
                          labelText: 'RADA Registration Number',
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location (e.g. Kingston, Jamaica)',
                        ),
                      ),
                    ],
                    if (_error != null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isLogin ? 'Sign In' : 'Sign Up'),
                    ),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                      child: Text(
                        _isLogin ? 'Create an account' : 'Back to Sign In',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
