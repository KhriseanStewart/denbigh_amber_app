import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:denbigh_app/users/database/order_service.dart';

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
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return;

      setState(() {
        _imageFile = File(picked.path);
        _uploading = true;
      });

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
    } on PlatformException catch (e) {
      // Handle the MissingPluginException specifically
      if (e.code == 'MissingPluginException') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Image picker not available. Please restart the app completely.',
            ),
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: ${e.message}')));
      }
      widget.onImageUploaded?.call(null);
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
    try {
      // Get the uploaded image URL from the order
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order not found.')));
        return;
      }

      final orderData = orderDoc.data()!;
      final receiptImageUrl = orderData['imageUrl'] ?? '';

      if (receiptImageUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a receipt image first.')),
        );
        return;
      }

      // Use the OrderService to create consolidated sale
      await OrderService().convertOrderToSale(orderId, receiptImageUrl);

      // Delete the order from the orders collection since it's now converted to sales
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();

      setState(() {
        _donePressed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Order converted to Sale! All items consolidated under one sale record.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Error converting order to sale: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to convert order to sale: $e')),
      );
    }
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
