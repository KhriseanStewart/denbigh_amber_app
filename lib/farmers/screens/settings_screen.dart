import 'dart:io';
import 'package:denbigh_app/farmers/services/auth.dart' as farmer_auth;
import 'package:denbigh_app/farmers/services/farmer_service.dart';
import 'package:denbigh_app/farmers/widgets/textField.dart';
import 'package:denbigh_app/widgets/autoCompleter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FarmerSettingsScreen extends StatefulWidget {
  const FarmerSettingsScreen({super.key});

  @override
  State<FarmerSettingsScreen> createState() => _FarmerSettingsScreenState();
}

class _FarmerSettingsScreenState extends State<FarmerSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedLocation;
  String? _profileImageUrl;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadfarmersData();
    });
  }

  Future<void> _loadfarmersData() async {
    final auth = farmer_auth.AuthService();
    final farmer = auth.farmer;

    if (farmer != null) {
      _nameController.text = farmer.farmerName;
      _farmNameController.text = farmer.farmName;
      _emailController.text = farmer.email;
      _selectedLocation = farmer.locationName;

      // Load profile image from farmer model first
      if (farmer.profileImageUrl != null &&
          farmer.profileImageUrl!.isNotEmpty) {
        setState(() {
          _profileImageUrl = farmer.profileImageUrl;
        });
      } else {
        // Load additional farmer data from FarmerService if not in model
        try {
          final farmerService = FarmerService();
          final farmerDoc = await farmerService.getfarmersData(farmer.id);

          if (farmerDoc.exists) {
            final data = farmerDoc.data() as Map<String, dynamic>?;
            final profileImageUrl = data?['profileImageUrl'] as String?;

            if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
              setState(() {
                _profileImageUrl = profileImageUrl;
              });
            }
          }
        } catch (e) {
          print('Error loading farmer data: $e');
        }

        // Load profile image if exists (fallback to Firebase Storage)
        if (_profileImageUrl == null) {
          _loadProfileImage(farmer.id);
        }
      }
    }
  }

  Future<void> _loadProfileImage(String farmerId) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('farmer_profiles')
          .child('$farmerId.jpg');

      final url = await ref.getDownloadURL();
      setState(() {
        _profileImageUrl = url;
      });
    } catch (e) {
      // No profile image exists, which is fine
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SizedBox(
        height: 200,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final auth = farmer_auth.AuthService();
      final farmerId = auth.farmer!.id;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('farmer_profiles')
          .child('$farmerId.jpg');

      final uploadTask = storageRef.putFile(File(picked.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update farmer data with new profile image URL using FarmerService
      final farmerService = FarmerService();
      await farmerService.updatefarmersData(
        farmerId: farmerId,
        farmName: _farmNameController.text.trim(),
        profileImageUrl: downloadUrl,
      );

      setState(() {
        _profileImageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile picture updated!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = farmer_auth.AuthService();
      final farmerId = auth.farmer!.id;
      final farmerService = FarmerService();

      // Update farmer data using FarmerService
      await farmerService.updatefarmersData(
        farmerId: farmerId,
        farmerName: _nameController.text.trim(),
        farmName: _farmNameController.text.trim(),
        locationName: _selectedLocation,
        profileImageUrl: _profileImageUrl,
      );

      // Update email in Firebase Auth if changed
      if (_emailController.text.trim() != auth.farmer!.email) {
        await FirebaseAuth.instance.currentUser!.updateEmail(
          _emailController.text.trim(),
        );
      }

      // Update password if provided
      if (_newPasswordController.text.isNotEmpty) {
        final credential = EmailAuthProvider.credential(
          email: auth.farmer!.email,
          password: _currentPasswordController.text,
        );
        await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
          credential,
        );
        await FirebaseAuth.instance.currentUser!.updatePassword(
          _newPasswordController.text,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      // Reload farmer data to reflect changes
      await Future.delayed(
        Duration(milliseconds: 500),
      ); // Small delay for Firestore consistency
      _loadfarmersData();

      // Clear password fields
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _farmNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = farmer_auth.AuthService();

    return Scaffold(
      appBar: AppBar(title: Text('Settings'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              SizedBox(
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child: _profileImageUrl == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey[600],
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploadingImage
                            ? null
                            : _pickAndUploadProfileImage,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: _isUploadingImage
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Basic Information Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      CustomTextFormField(
                        controller: _nameController,
                        label: 'Farmer Name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      CustomTextFormField(
                        controller: _farmNameController,
                        label: 'Farm Name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Farm name is required';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      CustomTextFormField(
                        controller: _emailController,
                        label: 'Email',
                        inputType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Location Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          LocationAutoComplete(
                            onCategorySelected: (location) {
                              setState(() {
                                _selectedLocation = location;
                              });
                            },
                          ),
                          if (_selectedLocation != null) ...[
                            SizedBox(height: 8),
                            Text(
                              'Current: $_selectedLocation',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ],
                      ),

                      SizedBox(height: 16),

                      // RADA Number (Read-only)
                      TextFormField(
                        initialValue: auth.farmer?.radaRegistrationNumber ?? '',
                        decoration: InputDecoration(
                          labelText: 'RADA Registration Number',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          suffixIcon: Icon(Icons.lock, color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 0.5,
                            ),
                          ),
                        ),
                        enabled: false,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Change Password Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Leave blank if you don\'t want to change your password',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),

                      CustomTextFormField(
                        controller: _currentPasswordController,
                        label: 'Current Password',
                        obscureText: true,
                        validator: (value) {
                          if (_newPasswordController.text.isNotEmpty &&
                              (value == null || value.isEmpty)) {
                            return 'Current password is required to change password';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      CustomTextFormField(
                        controller: _newPasswordController,
                        label: 'New Password',
                        obscureText: true,
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      CustomTextFormField(
                        controller: _confirmPasswordController,
                        label: 'Confirm New Password',
                        obscureText: true,
                        validator: (value) {
                          if (_newPasswordController.text.isNotEmpty &&
                              value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text('Save Changes', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
