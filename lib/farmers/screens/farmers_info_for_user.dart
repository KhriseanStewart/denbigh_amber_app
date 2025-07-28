import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FarmerInfoPopup {
  static Future<void> showFarmerInfo(BuildContext context, String farmerId) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: FarmerInfoDialogContent(farmerId: farmerId),
        );
      },
    );
  }
}

class FarmerInfoDialogContent extends StatefulWidget {
  final String farmerId;

  const FarmerInfoDialogContent({super.key, required this.farmerId});

  @override
  State<FarmerInfoDialogContent> createState() =>
      _FarmerInfoDialogContentState();
}

class _FarmerInfoDialogContentState extends State<FarmerInfoDialogContent> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('farmersData')
          .doc(widget.farmerId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 300,
            height: 400,
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(color: Colors.green),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Container(
            width: 300,
            height: 200,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 50, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Farmer information not available',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            ),
          );
        }

        final farmerData = snapshot.data!.data() as Map<String, dynamic>;
        final farmerName =
            farmerData['farmerName'] ??
            farmerData['name'] ??
            farmerData['firstName'] ??
            'Unknown Farmer';
        final location = farmerData['locationName'] ?? 'Unknown Location';
        final farmName =
            farmerData['farmName'] ??
            farmerData['businessName'] ??
            farmerData['farm'] ??
            'Farm name not provided';

        // Primary field name is profileImageUrl
        final profileImageUrl = farmerData['profileImageUrl'] as String?;

        final radaRegistrationNumber =
            farmerData['radaRegistrationNumber'] ?? 'N/A';

        return Container(
          width: 320,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Farmer Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.grey),
                    iconSize: 20,
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Profile picture - Simplified approach
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade100,
                ),
                child: ClipOval(
                  child: profileImageUrl != null && profileImageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: profileImageUrl,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          placeholder: (context, url) => Container(
                            color: Colors.green.shade100,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.green,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            return Container(
                              color: Colors.green.shade100,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.green.shade600,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.green.shade100,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.green.shade600,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 16),

              // Farmer name
              Text(
                farmerName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 4),

              // Farm name
              if (farmName != 'Farm name not provided')
                Text(
                  farmName,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

              SizedBox(height: 8),

              // RADA number
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  'RADA: $radaRegistrationNumber',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Location
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.green.shade600,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      location,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
