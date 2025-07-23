import 'package:denbigh_app/farmers/model/products.dart';
import 'package:denbigh_app/farmers/services/auth.dart' as farmer_auth;
import 'package:denbigh_app/farmers/widgets/add_product_image.dart';
import 'package:denbigh_app/farmers/widgets/textField.dart';
import 'package:denbigh_app/farmers/widgets/used_list/list.dart';
import 'package:denbigh_app/widgets/autoCompleter.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  String _name = '';
  String? _category;
  String _description = '';
  String? _unit;
  String? _location; // Added location variable
  int _stock = 0;
  String _minSaleAmount = '';
  double _price = 0;
  String? _imageUrl;
  bool _loading = false;
  bool _uploadingImage = false;
  bool _allFieldsFilled = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _name = p.name;
      _category = p.category.isNotEmpty ? p.category.first : null;
      _description = p.description;
      _unit = p.unit.isNotEmpty ? p.unit.first : null;
      _location =
          p.customerLocation; // Initialize location from existing product
      _stock = p.stock;
      _minSaleAmount = p.minSaleAmount;
      _price = p.price;
      _imageUrl = p.imageUrl;

      _nameController.text = _name;
      _descriptionController.text = _description;
      _priceController.text = _price == 0 ? '' : _price.toString();
      _minSaleAmountController.text = _minSaleAmount == '0'
          ? ''
          : _minSaleAmount;
      _stockController.text = _stock == 0 ? '' : _stock.toString();
    }
    _nameController.addListener(_checkAllFieldsFilled);
    _descriptionController.addListener(_checkAllFieldsFilled);
    _priceController.addListener(_checkAllFieldsFilled);
    _minSaleAmountController.addListener(_checkAllFieldsFilled);
    _stockController.addListener(_checkAllFieldsFilled);

    // Check if all fields are filled after initialization
    _checkAllFieldsFilled();
  }

  void _checkAllFieldsFilled() {
    final bool filled =
        _nameController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _priceController.text.trim().isNotEmpty &&
        double.tryParse(_priceController.text.trim()) != null &&
        _minSaleAmountController.text.trim().isNotEmpty &&
        int.tryParse(_minSaleAmountController.text.trim()) != null &&
        _stockController.text.trim().isNotEmpty &&
        int.tryParse(_stockController.text.trim()) != null &&
        _category != null &&
        _category!.isNotEmpty &&
        _unit != null &&
        _unit!.isNotEmpty &&
        _location != null &&
        _location!.isNotEmpty;
    if (filled != _allFieldsFilled) {
      setState(() {
        _allFieldsFilled = filled;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    // Ask to choose the photo source
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Container(
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

    setState(() => _uploadingImage = true);

    try {
      final productId = widget.productId;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('product_pictures')
          .child(productId);
      final uploadTask = storageRef.putFile(File(picked.path));
      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({'imageUrl': downloadUrl});

      setState(() {
        _imageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item picture uploaded!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _uploadingImage = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _category == null ||
        _unit == null ||
        _location == null) {
      return;
    }
    _formKey.currentState!.save();

    _name = _nameController.text.trim();
    _description = _descriptionController.text.trim();
    _price = double.tryParse(_priceController.text) ?? 0;
    _minSaleAmount = _minSaleAmountController.text.trim();
    _stock = int.tryParse(_stockController.text) ?? 0;

    setState(() => _loading = true);

    final userId = Provider.of<farmer_auth.AuthService>(
      context,
      listen: false,
    ).farmer!.id;

    try {
      int minUnitNum = int.parse(_minSaleAmount);
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
            'productId': widget.productId,
            'farmerId': userId,
            'name': _name,
            'description': _description,
            'category': [_category!],
            'price': _price,
            'unit': [_unit!],
            'location': _location,
            'stock': _stock,
            'minSaleAmount': minUnitNum,
            'imageUrl': _imageUrl ?? '',
            'createdAt': Timestamp.now(),
          });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Product info Added!')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkAllFieldsFilled);
    _descriptionController.removeListener(_checkAllFieldsFilled);
    _priceController.removeListener(_checkAllFieldsFilled);
    _minSaleAmountController.removeListener(_checkAllFieldsFilled);
    _stockController.removeListener(_checkAllFieldsFilled);
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _minSaleAmountController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button the same way as Cancel button
        if (widget.product == null) {
          // For new products, delete the empty product document
          await FirebaseFirestore.instance
              .collection('products')
              .doc(widget.productId)
              .delete();
        }
        // For edited products, do nothing (just go back)
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_name.isEmpty ? 'Add New Product' : 'Edit Product'),
        ),
        body: ListView(
          children: [
            // Image at the top
            if (_imageUrl != null && _imageUrl!.isNotEmpty)
              ProductImageDisplay(
                imageUrl: _imageUrl!,
                height: 300,
                borderRadius: 12,
              ),
            Center(
              child: SizedBox(
                width: 540,
                child: Card(
                  margin: EdgeInsets.all(24),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        children: [
                          CustomTextFormField(
                            controller: _nameController,
                            inputType: TextInputType.text,
                            label: 'Product Name *',
                            hintText: 'e.g., Fresh Tomatoes',
                            underlineborder: true,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                            onSaved: (v) {},
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _category,
                            items: categories
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                .toList(),
                            decoration: InputDecoration(
                              labelText: 'Category *',
                              border: UnderlineInputBorder(),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                            onChanged: (v) {
                              setState(() => _category = v);
                              _checkAllFieldsFilled();
                            },
                            onSaved: (v) => _category = v,
                          ),
                          SizedBox(height: 16),
                          CustomTextFormField(
                            controller: _descriptionController,
                            inputType: TextInputType.multiline,
                            underlineborder: true,
                            label: 'Description',
                            hintText: 'Describe your product...',
                            maxLines: 2,
                            onSaved: (v) {},
                          ),
                          SizedBox(height: 16),
                          // Location Auto Complete Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location *',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              LocationAutoComplete(
                                underlineBorder: true,
                                onCategorySelected: (selectedLocation) {
                                  setState(() {
                                    _location = selectedLocation;
                                  });
                                  _checkAllFieldsFilled();
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  hintText: 'e.g., 200',
                                  underlineborder: true,
                                  controller: _priceController,
                                  label: 'Price *',
                                  inputType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  validator: (v) =>
                                      v == null || double.tryParse(v) == null
                                      ? 'Required'
                                      : null,
                                  onSaved: (v) {},
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _unit,
                                  items: units
                                      .map(
                                        (unit) => DropdownMenuItem(
                                          value: unit,
                                          child: Text(unit),
                                        ),
                                      )
                                      .toList(),
                                  decoration: InputDecoration(
                                    labelText: 'Unit *',
                                    border: UnderlineInputBorder(),
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                  onChanged: (v) {
                                    setState(() => _unit = v);
                                    _checkAllFieldsFilled();
                                  },
                                  onSaved: (v) => _unit = v,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: CustomTextFormField(
                                  underlineborder: true,
                                  hintText: 'e.g., 100',
                                  controller: _stockController,
                                  label: 'Stock Quantity',
                                  inputType: TextInputType.number,
                                  validator: (v) =>
                                      v == null || int.tryParse(v) == null
                                      ? 'Required'
                                      : null,
                                  onSaved: (v) {},
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          CustomTextFormField(
                            underlineborder: true,
                            controller: _minSaleAmountController,
                            label: 'Minimum Sale Amount *',
                            hintText: 'e.g., 100 , ',
                            inputType: TextInputType.text,
                            validator: (v) =>
                                v == null || int.tryParse(v) == null
                                ? 'Required'
                                : null,
                            onSaved: (v) {},
                          ),
                          SizedBox(height: 24),
                          // Only show Add/Change Image Button if all fields are filled
                          if (_allFieldsFilled)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _uploadingImage
                                    ? null
                                    : _pickAndUploadImage,
                                icon: _uploadingImage
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(Icons.upload),
                                label: Text(
                                  _imageUrl != null && _imageUrl!.isNotEmpty
                                      ? 'Change Item Picture'
                                      : 'Add Item Picture',
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed:
                                      _loading ||
                                          _category == null ||
                                          categories.isEmpty ||
                                          _unit == null ||
                                          units.isEmpty ||
                                          _location == null ||
                                          _location!.isEmpty
                                      ? null
                                      : _submit,
                                  child: _loading
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          _name.isEmpty
                                              ? 'Save Product Info'
                                              : 'Save Changes',
                                        ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _loading
                                      ? null
                                      : () async {
                                          // this part is for deleting the product
                                          if (widget.product == null) {
                                            await FirebaseFirestore.instance
                                                .collection('products')
                                                .doc(widget.productId)
                                                .delete();
                                          }
                                          Navigator.of(
                                            context,
                                          ).pop(); // Navigate back in both cases
                                        },
                                  child: Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
