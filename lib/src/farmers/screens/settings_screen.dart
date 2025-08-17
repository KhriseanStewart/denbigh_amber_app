import 'dart:io';
import 'package:denbigh_app/src/farmers/services/auth.dart' as farmer_auth;
import 'package:denbigh_app/src/farmers/services/farmer_service.dart';
import 'package:denbigh_app/src/farmers/widgets/textField.dart';
import 'package:denbigh_app/src/widgets/autoCompleter.dart';
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
        } catch (e) {}

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

      // Refresh auth service to update farmer data
      final authService = farmer_auth.AuthService();
      await authService.refreshFarmerData();

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

      // Refresh auth service to update farmer data
      await auth.refreshFarmerData();

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
      backgroundColor: Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(
          'Farm Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF2E7D32),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Welcome Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                margin: EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.agriculture, size: 32, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'Manage Your Farm Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Update your information and settings',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Picture Section
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.photo_camera,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Profile Picture',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFF4CAF50),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.2),
                                  spreadRadius: 0,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Color(0xFFF1F8E9),
                              backgroundImage: _profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : null,
                              child: _profileImageUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Color(0xFF4CAF50),
                                    )
                                  : null,
                            ),
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
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF66BB6A),
                                      Color(0xFF4CAF50),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.4),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
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
                  ],
                ),
              ),

              // Basic Information Card
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_circle,
                          color: Color(0xFF4CAF50),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Farm Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

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
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Color(0xFF4CAF50),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Farm Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F8E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF4CAF50).withOpacity(0.3),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: LocationAutoComplete(
                              onCategorySelected: (location) {
                                setState(() {
                                  _selectedLocation = location;
                                });
                              },
                            ),
                          ),
                        ),
                        if (_selectedLocation != null) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Color(0xFF4CAF50).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Color(0xFF4CAF50),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Current: $_selectedLocation',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 20),

                    // RADA Number (Read-only)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              color: Color(0xFF4CAF50),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'RADA Registration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  auth.farmer?.radaRegistrationNumber ??
                                      'Not Available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Change Password Card
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Color(0xFF4CAF50),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Security Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xFFFF9800).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFFFF9800),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Leave password fields blank if you don\'t want to change your password',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

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

              // Save Button
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _updateProfile,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: _isLoading
                            ? [Colors.grey[400]!, Colors.grey[400]!]
                            : [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _isLoading
                              ? Colors.transparent
                              : Colors.green.withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading)
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        else ...[
                          Icon(Icons.save, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Save Farm Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
