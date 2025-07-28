import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddReceiptImage extends StatefulWidget {
  final String orderId;
  final void Function(String? imageUrl)? onImageUploaded;
  const AddReceiptImage({
    super.key,
    required this.orderId,
    this.onImageUploaded,
  });

  @override
  State<AddReceiptImage> createState() => _AddReceiptImageState();
}

class _AddReceiptImageState extends State<AddReceiptImage> {
  File? _imageFile;
  bool _uploading = false;
  String? _uploadedUrl;
  bool _donePressed = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _uploading = true;
    });

    try {
      final orderId = widget.orderId;
      if (orderId.isEmpty) throw Exception('Order ID is missing.');

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('order_pictures')
          .child(orderId);

      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'imageUrl': downloadUrl},
      );

      setState(() {
        _uploadedUrl = downloadUrl;
        _imageFile = null;
      });

      widget.onImageUploaded?.call(downloadUrl);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Receipt uploaded!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      widget.onImageUploaded?.call(null);
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.all(8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Add Receipt Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
                ),
                title: Text('Camera'),
                subtitle: Text('Take a new photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(source: ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
                ),
                title: Text('Gallery'),
                subtitle: Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(source: ImageSource.gallery);
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
    );
  }

  Future<void> _convertOrderToSale(String orderId) async {
    // Get order data
    final doc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get();
    if (!doc.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order not found.')));
      return;
    }
    final orderData = doc.data()!;

    // Process each item in the order
    final items = orderData['items'] as List<dynamic>? ?? [];

    for (final item in items) {
      final productId = item['productId'] as String? ?? '';
      final quantitySold = (item['quantity'] as num? ?? 0).toInt();

      if (productId.isNotEmpty && quantitySold > 0) {
        // Get current product data
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        if (productDoc.exists) {
          final productData = productDoc.data()!;
          final currentStock = (productData['stock'] as num? ?? 0).toInt();
          final currentTotalSold = (productData['totalSold'] as num? ?? 0)
              .toInt();
          final currentTotalEarnings =
              (productData['totalEarnings'] as num?)?.toInt() ?? 0;
          final itemTotalPrice = (item['price'] as num? ?? 0) * quantitySold;

          // Update product: reduce stock, increase total sold and earnings
          await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .update({
                'stock': currentStock - quantitySold,
                'totalSold': currentTotalSold + quantitySold,
                'totalEarnings': currentTotalEarnings + itemTotalPrice.toInt(),
              });
        }
      }

      // Create individual sale record for each item
      final saleData = {
        'salesId': '', // will update with doc ID below
        'orderId': orderId, // links the sale to the original order
        'productId': item['productId'] ?? '',
        'name': item['name'] ?? '',
        'quantity': item['quantity'] ?? 1,
        'totalPrice':
            (item['price'] as num? ?? 0) * (item['quantity'] as num? ?? 1),
        'date': Timestamp.now(),
        'customerId': orderData['customerId'] ?? '',
        'farmerId': orderData['farmerId'] ?? '',
        'unit': item['unit'] ?? '',
        'imageUrl': orderData['imageUrl'] ?? '',
        'status': 'completed',
        'orderSessionId': orderData['orderSessionId'] ?? '',
        'customerLocation': item['customerLocation'] ?? '',
      };

      // Store individual sale in Firestore
      final saleDocRef = await FirebaseFirestore.instance
          .collection('sales')
          .add(saleData);
      await saleDocRef.update({'salesId': saleDocRef.id});
    }

    // Delete the order from the orders collection since it's now converted to sales
    await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();

    setState(() {
      _donePressed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order converted to Sale! Stock updated for all items.'),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    if (orderId.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFFF8FBF8),
        appBar: AppBar(
          title: Text(
            'Receipt Image',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF66BB6A),
                  Color(0xFF4CAF50),
                  Color(0xFF2E7D32),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.red[600], size: 48),
                SizedBox(height: 12),
                Text(
                  'Order ID Missing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Cannot upload or display image without Order ID.',
                  style: TextStyle(color: Colors.red[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(
          'Receipt Image',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66BB6A), Color(0xFF4CAF50), Color(0xFF2E7D32)],
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          final bool hasImage =
              _imageFile != null ||
              (_uploadedUrl != null && _uploadedUrl!.isNotEmpty);

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
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
                      Icon(Icons.receipt_long, size: 32, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'Order Receipt',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Upload receipt image to complete the order',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Status Indicator
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF4CAF50).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasImage ? Icons.check_circle : Icons.receipt_long,
                        color: hasImage ? Color(0xFF4CAF50) : Colors.orange,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hasImage
                              ? 'Receipt image ready'
                              : 'Receipt image required',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (hasImage ? Color(0xFF4CAF50) : Colors.orange)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hasImage ? 'Ready' : 'Pending',
                          style: TextStyle(
                            fontSize: 12,
                            color: hasImage
                                ? Color(0xFF2E7D32)
                                : Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Image Display Section
                if (hasImage) ...[
                  Text(
                    'Receipt Image',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xFF4CAF50).withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4CAF50).withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : (_uploadedUrl != null && _uploadedUrl!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: _uploadedUrl!,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 300,
                                color: Color(0xFFF1F8E9),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 300,
                                color: Color(0xFFF1F8E9),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error,
                                        color: Color(0xFFE57373),
                                        size: 48,
                                      ),
                                      Text(
                                        'Failed to load image',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(height: 300, color: Color(0xFFF1F8E9)),
                    ),
                  ),
                  SizedBox(height: 24),
                ],

                // Add/Change Receipt Button
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Color(0xFF4CAF50),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Color(0xFF4CAF50), width: 2),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _uploading ? null : _showImageSourceActionSheet,
                    icon: _uploading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                Color(0xFF4CAF50),
                              ),
                            ),
                          )
                        : Icon(hasImage ? Icons.edit : Icons.add_a_photo),
                    label: Text(
                      hasImage ? 'Change Receipt' : 'Add Receipt',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Action Buttons (only if image exists)
                if (hasImage) ...[
                  // View Picture Button
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (_uploadedUrl != null &&
                              _uploadedUrl!.isNotEmpty) {
                            _showFullImageDialog(_uploadedUrl!);
                          }
                        },
                        icon: Icon(Icons.visibility, color: Colors.white),
                        label: Text(
                          'View Full Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Complete Order Button
                  Container(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _donePressed
                              ? [Colors.grey[400]!, Colors.grey[400]!]
                              : [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _donePressed
                            ? null
                            : () async {
                                if (_uploadedUrl != null &&
                                    _uploadedUrl!.isNotEmpty) {
                                  await _convertOrderToSale(orderId);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please upload a receipt image first!',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                        icon: Icon(Icons.done_all, color: Colors.white),
                        label: Text(
                          'Complete Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
