import 'package:flutter/material.dart';
import 'package:denbigh_app/src/farmers/services/auth.dart' as farmer_auth;

class FarmerProfileReadOnlyScreen extends StatelessWidget {
  const FarmerProfileReadOnlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = farmer_auth.AuthService();
    final farmer = auth.farmer;

    return Scaffold(
      backgroundColor: Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(
          'My Profile (Read Only)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66BB6A), Color(0xFF4CAF50), Color(0xFF2E7D32)],
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: farmer == null
          ? Center(
              child: Text(
                'No farmer data available',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner notice
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your account is suspended. You can view but not edit your information.',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Profile Image Section
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey[300]!, width: 3),
                      ),
                      child:
                          farmer.profileImageUrl != null &&
                              farmer.profileImageUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                farmer.profileImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[400],
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Profile Information Cards
                  _buildInfoCard(
                    'Farmer Name',
                    farmer.farmerName.isNotEmpty
                        ? farmer.farmerName
                        : 'Not provided',
                    Icons.person,
                  ),
                  SizedBox(height: 16),

                  _buildInfoCard(
                    'Farm Name',
                    farmer.farmName.isNotEmpty
                        ? farmer.farmName
                        : 'Not provided',
                    Icons.agriculture,
                  ),
                  SizedBox(height: 16),

                  _buildInfoCard('Email', farmer.email, Icons.email),
                  SizedBox(height: 16),

                  _buildInfoCard(
                    'RADA Registration Number',
                    farmer.radaRegistrationNumber.isNotEmpty
                        ? farmer.radaRegistrationNumber
                        : 'Not provided',
                    Icons.card_membership,
                  ),
                  SizedBox(height: 16),

                  _buildInfoCard(
                    'Location',
                    farmer.locationName.isNotEmpty
                        ? farmer.locationName
                        : 'Not provided',
                    Icons.location_on,
                  ),
                  SizedBox(height: 16),

                  // Account Status
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
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
                              color: Colors.orange,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Account Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),

                        _buildStatusRow('Banned', farmer.isBanned),
                        SizedBox(height: 8),
                        _buildStatusRow('Flagged', farmer.isFlagged),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF66BB6A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Color(0xFF66BB6A), size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: status
                ? Colors.red.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: status
                  ? Colors.red.withOpacity(0.3)
                  : Colors.green.withOpacity(0.3),
            ),
          ),
          child: Text(
            status ? 'Yes' : 'No',
            style: TextStyle(
              color: status ? Colors.red[700] : Colors.green[700],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
