import 'package:denbigh_app/routes.dart';
import 'package:denbigh_app/users/database/auth_service.dart';
import 'package:denbigh_app/users/screens/profile/profile_pic_card.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 32),
            Center(
              child: Builder(
                builder: (context) {
                  try {
                    return ProfilePictureUploader(); //curent logic is dependent on a logged in user
                  } catch (e) {
                    return Column(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Failed to load profile picture.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 40),
            _profileContainer('Account Information', () {
              Navigator.pushNamed(context, AppRouter.accountInformation);
            }),
            _profileContainer('My Orders', () {
              Navigator.pushNamed(context, AppRouter.userorders);
            }),
            _profileContainer('Card Information', () {
              Navigator.pushNamed(context, AppRouter.card);
            }),

            _profileContainer('Preferences', () {
              // logic to Navigate to preferences page
            }),
            _profileContainer('About Us', () {
              // logic to Navigate to about us page
            }),
          ],
        ),
      ),
    );
  }

  Widget _profileContainer(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Center(child: Text(title, style: TextStyle(fontSize: 16))),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logout?'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await AuthService().signOut();

                  Navigator.pushReplacementNamed(context, AppRouter.login);
                } catch (e) {
                  print(e);
                }
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
