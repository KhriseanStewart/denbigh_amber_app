import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title:  Text('Profile',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        actions: [
          IconButton(
            icon:  Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
           SizedBox(height: 32),
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              child:  CircleAvatar(
                radius: 56,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
           SizedBox(height: 40),
          _profileContainer('Account Information', () {
            // logic to Navigate to account information page
          }),
          _profileContainer('Card Information', () {
            // logic to Navigate to card information page
          }),
          _profileContainer('Others', () {
            // logic to Navigate to others page
          }),
          _profileContainer('Preferences', () {
            // logic to Navigate to preferences page
          }),
          _profileContainer('Settings', () {
            // logic to Navigate to settings page
          }),
        ],
      ),
    );

  }
  Widget _profileContainer(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:  EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontSize: 16),
        ),
      ),
      ),
    );
  }
  
  Widget _logout(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.logout, color: Colors.red),
        onPressed: () {
          showDialog(
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
                  onPressed: () {
                  //navigation logic needed
                   
                  },
                  child: Text('Logout'),
                ),
               
              ],
            );
          },
        );
      }
    
    );
}
}