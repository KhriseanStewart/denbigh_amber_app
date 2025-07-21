// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureUploader extends StatefulWidget {
  ProfilePictureUploader({Key? key}) : super(key: key);

  @override
  _ProfilePictureUploaderState createState() => _ProfilePictureUploaderState();
}

class _ProfilePictureUploaderState extends State<ProfilePictureUploader> {
  File? _imageFile;
  bool _uploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _uploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not signed in');

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(user.uid);

      // Upload file
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore user profile with new photo URL
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'photoUrl': downloadUrl},
      );

      await FirebaseAuth.instance.currentUser!.updatePhotoURL(downloadUrl);

      setState(() {
        _imageFile = null;
      });
      displaySnackBar(context, 'Profile photo updated!');
    } catch (e) {
      displaySnackBar(context, 'Upload failed: $e');
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Not signed in: Show person icon, no text fallback
      return Column(
        children: [
          CircleAvatar(
            radius: 90,
            backgroundColor: Colors.green,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey[300],
              child:  Icon(Icons.person, size: 80, color: Colors.white70),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: null,
            icon: Icon(Icons.upload),
            label: Text('Change Profile Picture'),
          ),
        ],
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String? photoUrl;
        if (snapshot.hasData && snapshot.data!.data() != null) {
          photoUrl =
              (snapshot.data!.data() as Map<String, dynamic>?)?['photoUrl']
                  as String?;
        }

        ImageProvider? displayImage;
        if (_imageFile != null) {
          displayImage = FileImage(_imageFile!);
        } else if (photoUrl != null && photoUrl.isNotEmpty) {
          displayImage = NetworkImage(photoUrl);
        }

        return Column(
          children: [
            CircleAvatar(
              radius: 89,
              backgroundColor: Colors.green,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.grey[300],
                backgroundImage: displayImage,
                child: (displayImage == null)
                    ? Icon(Icons.person, size: 80, color: Colors.white70)
                    : null,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _uploading ? null : _pickAndUploadImage,
              icon: _uploading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.upload),
              label: Text('Change Profile Picture'),
            ),
          ],
        );
      },
    );
  }
}
