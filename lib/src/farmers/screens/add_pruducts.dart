import 'package:denbigh_app/src/farmers/model/products.dart';
import 'package:denbigh_app/src/farmers/services/auth.dart' as farmer_auth;
import 'package:denbigh_app/src/farmers/widgets/add_product_image.dart';
import 'package:denbigh_app/src/farmers/widgets/autocompleter_products.dart';
import 'package:denbigh_app/src/farmers/widgets/textField.dart';
import 'package:denbigh_app/src/farmers/widgets/used_list/list.dart';
import 'package:denbigh_app/src/widgets/autoCompleter.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _minUnitNumController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String _name = '';
  String? _category;
  String _description = '';
  String? _unit;
  String? _location; // Added location variable
  int _stock = 0;
  String _minUnitNum = '';
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
      _minUnitNum = p.minUnitNum;
      _price = p.price;
      _imageUrl = p.imageUrl;

      _descriptionController.text = _description;
      _priceController.text = _price == 0 ? '' : _price.toString();
      _minUnitNumController.text = _minUnitNum == '0' ? '' : _minUnitNum;
      _stockController.text = _stock == 0 ? '' : _stock.toString();
    }
    _descriptionController.addListener(_checkAllFieldsFilled);
    _priceController.addListener(_checkAllFieldsFilled);
    _minUnitNumController.addListener(_checkAllFieldsFilled);
    _stockController.addListener(_checkAllFieldsFilled);

    // Check if all fields are filled after initialization
    _checkAllFieldsFilled();
  }

  void _checkAllFieldsFilled() {
    final bool filled =
        _name.trim().isNotEmpty && // Changed from _nameController.text to _name
        _descriptionController.text.trim().isNotEmpty &&
        _priceController.text.trim().isNotEmpty &&
        double.tryParse(_priceController.text.trim()) != null &&
        _minUnitNumController.text.trim().isNotEmpty &&
        int.tryParse(_minUnitNumController.text.trim()) != null &&
        _stockController.text.trim().isNotEmpty &&
        int.tryParse(_stockController.text.trim()) != null &&
        _category != null &&
        _category!.isNotEmpty &&
        _unit != null &&
        _unit!.isNotEmpty &&
        _location != null &&
        _location!.isNotEmpty &&
        _imageUrl != null && // Image must be uploaded
        _imageUrl!.isNotEmpty; // Image URL must not be empty
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
      builder: (context) => SizedBox(
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

      _checkAllFieldsFilled(); // Update button state after image upload

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

    // _name is already set by the AutocompleterProducts onNameSelected callback
    _description = _descriptionController.text.trim();
    _price = double.tryParse(_priceController.text) ?? 0;
    _minUnitNum = _minUnitNumController.text.trim();
    _stock = int.tryParse(_stockController.text) ?? 0;

    setState(() => _loading = true);

    final userId = farmer_auth.AuthService().farmer!.id;

    try {
      int minUnitNum = int.parse(_minUnitNum);
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
            'minUnitNum': minUnitNum,
            'imageUrl': _imageUrl ?? '',
            'createdAt': Timestamp.now(),
            'isComplete':
                true, // Mark as complete only when all fields are saved
            'isActive': true, // Product is now active and visible to users
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
    _descriptionController.removeListener(_checkAllFieldsFilled);
    _priceController.removeListener(_checkAllFieldsFilled);
    _minUnitNumController.removeListener(_checkAllFieldsFilled);
    _stockController.removeListener(_checkAllFieldsFilled);
    _descriptionController.dispose();
    _priceController.dispose();
    _minUnitNumController.dispose();
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
        backgroundColor: Color(0xFFF8FBF8),
        appBar: AppBar(
          title: Text(
            _name.isEmpty ? 'Add New Product' : 'Edit Product',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
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
                          AutocompleterProducts(
                            underlineBorder: true,
                            onNameSelected: (selectedName) {
                              setState(() {
                                _name = selectedName ?? '';
                              });
                              _checkAllFieldsFilled();
                            },
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
                                  print(
                                    'AddProductScreen: Location selected callback called with: $selectedLocation',
                                  );
                                  try {
                                    print('AddProductScreen: Before setState');
                                    setState(() {
                                      _location = selectedLocation;
                                      print(
                                        'AddProductScreen: Location set to: $_location',
                                      );
                                    });
                                    print('AddProductScreen: After setState');
                                    _checkAllFieldsFilled();
                                    print(
                                      'AddProductScreen: After _checkAllFieldsFilled',
                                    );
                                  } catch (e) {
                                    print('Error in location selection: $e');
                                    print('Error stack trace: ${e.toString()}');
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error selecting location: $e',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
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
                            controller: _minUnitNumController,
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
                          // Add/Change Image Button - always visible
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
                                          _location!.isEmpty ||
                                          _imageUrl ==
                                              null || // Image must be uploaded
                                          _imageUrl!
                                              .isEmpty // Image URL must not be empty
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
                                          widget.product == null
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
