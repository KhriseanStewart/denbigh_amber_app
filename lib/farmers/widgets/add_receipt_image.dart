// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class AddOrderImage extends StatefulWidget {
//   final String orderId;
//   final void Function(String? imageUrl)? onImageUploaded;
//   const AddOrderImage({Key? key, required this.orderId, this.onImageUploaded}) : super(key: key);

//   @override
//   State<AddOrderImage> createState() => _AddOrderImageState();
// }

// class _AddOrderImageState extends State<AddOrderImage> {
//   File? _imageFile;
//   bool _uploading = false;
//   String? _uploadedUrl;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickAndUploadImage({ImageSource source = ImageSource.gallery}) async {
//     final picked = await _picker.pickImage(source: source, imageQuality: 80);
//     if (picked == null) return;

//     setState(() {
//       _imageFile = File(picked.path);
//       _uploading = true;
//     });

//     try {
//       final orderId = widget.orderId;
//       if (orderId.isEmpty) throw Exception('Order ID is missing.');

//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('order_pictures')
//           .child(orderId);

//       final uploadTask = storageRef.putFile(_imageFile!);
//       final snapshot = await uploadTask;
//       final downloadUrl = await snapshot.ref.getDownloadURL();

//       await FirebaseFirestore.instance
//           .collection('orders')
//           .doc(orderId)
//           .update({'imageUrl': downloadUrl});

//       setState(() {
//         _uploadedUrl = downloadUrl;
//         _imageFile = null;
//       });

//       widget.onImageUploaded?.call(downloadUrl);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Order picture uploaded!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload failed: $e')),
//       );
//       widget.onImageUploaded?.call(null);
//     } finally {
//       setState(() {
//         _uploading = false;
//       });
//     }
//   }

//   void _showImageSourceActionSheet() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: Icon(Icons.photo_library),
//               title: Text('Gallery'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickAndUploadImage(source: ImageSource.gallery);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.camera_alt),
//               title: Text('Camera'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickAndUploadImage(source: ImageSource.camera);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showFullImageDialog(String imageUrl) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.black,
//         child: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Image.network(imageUrl, fit: BoxFit.contain),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orderId = widget.orderId;
//     if (orderId.isEmpty) {
//       return Center(
//         child: Text('Order ID is missing. Cannot upload or display image.'),
//       );
//     }
//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
//       builder: (context, snapshot) {
//         String? photoUrl;
//         if (snapshot.hasData && snapshot.data!.data() != null) {
//           photoUrl = (snapshot.data!.data() as Map<String, dynamic>?)?['imageUrl'] as String?;
//         }

//         ImageProvider? displayImage;
//         if (_imageFile != null) {
//           displayImage = FileImage(_imageFile!);
//         } else if (_uploadedUrl != null && _uploadedUrl!.isNotEmpty) {
//           displayImage = NetworkImage(_uploadedUrl!);
//         } else if (photoUrl != null && photoUrl.isNotEmpty) {
//           displayImage = NetworkImage(photoUrl);
//         }

//         final bool hasImage = displayImage != null;

//         return Column(
//           children: [
//             if (hasImage)
//               GestureDetector(
//                 onTap: photoUrl != null && photoUrl.isNotEmpty
//                     ? () => _showFullImageDialog(photoUrl!)
//                     : null,
//                 child: Container(
//                   width: 160,
//                   height: 160,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(24),
//                     border: Border.all(color: Colors.green, width: 3),
//                     image: displayImage != null
//                         ? DecorationImage(image: displayImage, fit: BoxFit.cover)
//                         : null,
//                   ),
//                   alignment: Alignment.center,
//                 ),
//               ),
//             if (hasImage) SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.shade200,
//                     iconColor: Colors.green,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//                   ),
//                   onPressed: _uploading ? null : _showImageSourceActionSheet,
//                   icon: _uploading
//                       ? SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : Icon(Icons.upload),
//                   label: Text(
//                     hasImage ? 'Change Picture' : 'Add Picture',
//                   ),
//                 ),

//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddReceiptImage extends StatefulWidget {
  final String orderId;
  final void Function(String? imageUrl)? onImageUploaded;
  const AddReceiptImage({Key? key, required this.orderId, this.onImageUploaded})
    : super(key: key);

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
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(source: ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(source: ImageSource.camera);
              },
            ),
          ],
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
      final quantitySold = item['quantity'] as int? ?? 0;

      if (productId.isNotEmpty && quantitySold > 0) {
        // Get current product data
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        if (productDoc.exists) {
          final productData = productDoc.data()!;
          final currentStock = productData['stock'] as int? ?? 0;
          final currentTotalSold = productData['totalSold'] as int? ?? 0;
          final currentTotalEarnings =
              (productData['totalEarnings'] as num?)?.toDouble() ?? 0.0;
          final itemTotalPrice = (item['price'] as num? ?? 0) * quantitySold;

          // Update product: reduce stock, increase total sold and earnings
          await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .update({
                'stock': currentStock - quantitySold,
                'totalSold': currentTotalSold + quantitySold,
                'totalEarnings': currentTotalEarnings + itemTotalPrice,
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
            (item['price'] as int? ?? 0) * (item['quantity'] as num? ?? 1),
        'date': Timestamp.now(),
        'customerId': orderData['customerId'] ?? '',
        'farmerId': orderData['farmerId'] ?? '',
        'unit': item['unit'] ?? '',
        'imageUrl': orderData['imageUrl'] ?? '',
        'status': 'completed',
      };

      // Store individual sale in Firestore
      final saleDocRef = await FirebaseFirestore.instance
          .collection('sales')
          .add(saleData);
      await saleDocRef.update({'salesId': saleDocRef.id});
    }

    // Delete the order from Firestore after processing all items
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
      return Center(
        child: Text('Order ID is missing. Cannot upload or display image.'),
      );
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {}

        // Only show image if user just uploaded one (not from Firestore at start)
        if (_imageFile != null) {
        } else if (_uploadedUrl != null && _uploadedUrl!.isNotEmpty) {
        } else {}
        final bool hasImage =
            _imageFile != null ||
            (_uploadedUrl != null && _uploadedUrl!.isNotEmpty);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_imageFile != null)
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.green, width: 3),
                    image: DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.center,
                )
              else if (_uploadedUrl != null && _uploadedUrl!.isNotEmpty)
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CachedNetworkImage(
                      imageUrl: _uploadedUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error, color: Colors.red),
                      width: 160,
                      height: 160,
                    ),
                  ),
                ),
              if (hasImage) SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  iconColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _uploading ? null : _showImageSourceActionSheet,
                icon: _uploading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.receipt_long),
                label: Text(hasImage ? 'Change Receipt' : 'Add Receipt'),
              ),
              if (hasImage)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade400,
                          iconColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: Icon(Icons.visibility),
                        label: Text('View Picture'),
                        onPressed: () {
                          if (_uploadedUrl != null &&
                              _uploadedUrl!.isNotEmpty) {
                            _showFullImageDialog(_uploadedUrl!);
                          }
                        },
                      ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          iconColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: Icon(Icons.done_all),
                        label: Text('Done'),
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
                                    ),
                                  );
                                }
                              },
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
