import 'package:denbigh_app/farmers/farmers/model/products.dart';
import 'package:denbigh_app/farmers/farmers/services/auth.dart';
import 'package:denbigh_app/farmers/farmers/widgets/add_product_image.dart';
import 'package:denbigh_app/farmers/farmers/widgets/textField.dart';
import 'package:denbigh_app/farmers/farmers/widgets/used_list/list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  final String productId;
  final Product? product;
  const AddProductScreen({super.key, required this.productId, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _minSaleAmountController =
      TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  String? _category;
  String? _unit;
  String? _imageUrl;
  File? _imageFile; // New: To hold the selected image file locally

  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      // Pre-fill fields if editing an existing product
      _nameController.text = p.name;
      _descriptionController.text = p.description;
      _priceController.text = p.price == 0 ? '' : p.price.toString();
      _minSaleAmountController.text = p.minSaleAmount == '0'
          ? ''
          : p.minSaleAmount;
      _stockController.text = p.stock == 0 ? '' : p.stock.toString();
      _category = p.category.isNotEmpty ? p.category.first : null;
      _unit = p.unit.isNotEmpty ? p.unit.first : null;
      _imageUrl = p.imageUrl;
    }
  }

  /// New: This function now only picks an image and stores it locally.
  /// The upload happens when the user presses "Save".
  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
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
    );

    if (source == null) return;

    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// New: This function now handles everything: image upload and saving all data.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _category == null ||
        _unit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => _loading = true);

    String? finalImageUrl = _imageUrl; // Start with the existing image URL

    // Step 1: Upload the new image if one was picked
    if (_imageFile != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('product_images')
            .child('${widget.productId}.jpg'); // Use product ID for unique name

        final uploadTask = storageRef.putFile(_imageFile!);
        final snapshot = await uploadTask;
        finalImageUrl = await snapshot.ref
            .getDownloadURL(); // Get the public URL
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
        setState(() => _loading = false);
        return;
      }
    }

    // Step 2: Gather all data and save to Firestore
    try {
      final userId = Provider.of<AuthService>(
        context,
        listen: false,
      ).farmer!.id;
      final productData = {
        'productId': widget.productId,
        'farmerId': userId,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _category, // Save as a single string
        'price': double.tryParse(_priceController.text.trim()) ?? 0,
        'unitType': _unit, // Save as 'unitType' for consistency
        'stock': int.tryParse(_stockController.text.trim()) ?? 0,
        'minSaleAmount': _minSaleAmountController.text.trim(),
        'imageUrl': finalImageUrl ?? '', // Use the final URL
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': widget.product == null
            ? FieldValue.serverTimestamp()
            : widget.product!.createdAt,
      };

      // Use .set with merge:true to create or update the document
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .set(productData, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Product saved successfully!')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving product: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _minSaleAmountController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Add New Product' : 'Edit Product',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- New: Image display logic ---
              // Show the newly picked image, or the existing one, or a placeholder
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : (_imageUrl != null && _imageUrl!.isNotEmpty
                            ? Image.network(_imageUrl!, fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey.shade600,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Add Product Image'),
                                ],
                              )),
                ),
              ),
              SizedBox(height: 24),

              // Your TextFields and Dropdowns remain here...
              // (The following is a condensed version of your form fields for brevity)
              CustomTextFormField(
                controller: _nameController,
                label: 'Product Name *',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                items: categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Category *',
                  border: UnderlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onChanged: (v) => setState(() => _category = v),
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 2,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: _priceController,
                      label: 'Price *',
                      inputType: TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v == null || double.tryParse(v) == null
                          ? 'Required'
                          : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _unit,
                      items: units
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Unit *',
                        border: UnderlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                      onChanged: (v) => setState(() => _unit = v),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: _stockController,
                label: 'Stock Quantity *',
                inputType: TextInputType.number,
                validator: (v) =>
                    v == null || int.tryParse(v) == null ? 'Required' : null,
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: _minSaleAmountController,
                label: 'Minimum Sale Amount *',
                inputType: TextInputType.number,
                validator: (v) =>
                    v == null || int.tryParse(v) == null ? 'Required' : null,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.product == null
                            ? 'Save Product'
                            : 'Save Changes',
                      ),
              ),
              SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loading ? null : () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
