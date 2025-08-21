import 'package:denbigh_app/farmers/model/products.dart';
import 'package:denbigh_app/farmers/services/auth.dart' as farmer_auth;
import 'package:denbigh_app/farmers/widgets/add_product_image.dart';
import 'package:denbigh_app/farmers/widgets/autocompleter_products.dart';
import 'package:denbigh_app/farmers/widgets/textField.dart';
import 'package:denbigh_app/farmers/widgets/used_list/list.dart';
import 'package:denbigh_app/widgets/autoCompleter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final _toolsFormKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _minUnitNumController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  // Controllers for Farming Tools Tab
  final TextEditingController _toolNameController = TextEditingController();
  final TextEditingController _toolDescriptionController =
      TextEditingController();
  final TextEditingController _toolPriceController = TextEditingController();
  final TextEditingController _toolStockController = TextEditingController();
  final TextEditingController _toolMinUnitController = TextEditingController();

  String _name = '';
  String? _category;
  String _description = '';
  String? _unit;
  String? _location;
  int _stock = 0;
  String _minUnitNum = '';
  double _price = 0;
  String? _imageUrl;
  bool _loading = false;
  bool _uploadingImage = false;
  bool _allFieldsFilled = false;
  final ImagePicker _picker = ImagePicker();

  // Variables for Farming Tools Tab
  String _toolName = '';
  String? _toolCategory;
  String _toolDescription = '';
  String? _toolUnit;
  String? _toolLocation;
  int _toolStock = 0;
  String _toolMinUnitNum = '';
  double _toolPrice = 0;
  String? _toolImageUrl;
  bool _toolLoading = false;
  bool _toolUploadingImage = false;
  bool _toolAllFieldsFilled = false;
  bool _isSingleItem = false; // New flag for single items like tractors

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _name = p.name;
      _category = p.category.isNotEmpty ? p.category.first : null;
      _description = p.description;
      _unit = p.unit.isNotEmpty ? p.unit.first : null;
      _location = p.customerLocation;
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

    _checkAllFieldsFilled();

    // Initialize tools listeners
    _initializeToolsListeners();
  }

  void _checkAllFieldsFilled() {
    final bool filled =
        _name.trim().isNotEmpty &&
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
        _imageUrl != null &&
        _imageUrl!.isNotEmpty;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Select Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
                title: Text('Gallery'),
                subtitle: Text('Choose from photos'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
                title: Text('Camera'),
                subtitle: Text('Take a new photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
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

      _checkAllFieldsFilled();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item picture uploaded!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            'isComplete': true,
            'isActive': true,
          });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Product info Added!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _loading = false);
      }
    }
  }

  // Methods for Farming Tools Tab
  void _initializeToolsListeners() {
    _toolDescriptionController.addListener(_checkToolAllFieldsFilled);
    _toolPriceController.addListener(_checkToolAllFieldsFilled);
    _toolMinUnitController.addListener(_checkToolAllFieldsFilled);
    _toolStockController.addListener(_checkToolAllFieldsFilled);
    _checkToolAllFieldsFilled();
  }

  void _checkToolAllFieldsFilled() {
    final bool filled =
        _toolName.trim().isNotEmpty &&
        _toolDescriptionController.text.trim().isNotEmpty &&
        _toolPriceController.text.trim().isNotEmpty &&
        double.tryParse(_toolPriceController.text.trim()) != null &&
        _toolCategory != null &&
        _toolCategory!.isNotEmpty &&
        _toolLocation != null &&
        _toolLocation!.isNotEmpty &&
        _toolImageUrl != null &&
        _toolImageUrl!.isNotEmpty &&
        // For single items, we don't require unit, stock, or min unit
        (_isSingleItem ||
            (_toolUnit != null &&
                _toolUnit!.isNotEmpty &&
                _toolMinUnitController.text.trim().isNotEmpty &&
                int.tryParse(_toolMinUnitController.text.trim()) != null &&
                _toolStockController.text.trim().isNotEmpty &&
                int.tryParse(_toolStockController.text.trim()) != null));
    if (filled != _toolAllFieldsFilled) {
      setState(() {
        _toolAllFieldsFilled = filled;
      });
    }
  }

  Future<void> _pickAndUploadToolImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Select Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
                title: Text('Gallery'),
                subtitle: Text('Choose from photos'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
                title: Text('Camera'),
                subtitle: Text('Take a new photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    setState(() => _toolUploadingImage = true);

    try {
      final productId = widget.productId;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('product_pictures')
          .child('${productId}_tool');
      final uploadTask = storageRef.putFile(File(picked.path));
      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _toolImageUrl = downloadUrl;
      });

      _checkToolAllFieldsFilled();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tool picture uploaded!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _toolUploadingImage = false);
    }
  }

  Future<void> _submitTool() async {
    if (!_toolsFormKey.currentState!.validate() ||
        _toolCategory == null ||
        (_toolUnit == null &&
            !_isSingleItem) || // Unit not required for single items
        _toolLocation == null) {
      return;
    }
    _toolsFormKey.currentState!.save();

    _toolDescription = _toolDescriptionController.text.trim();
    _toolPrice = double.tryParse(_toolPriceController.text) ?? 0;
    _toolMinUnitNum = _toolMinUnitController.text.trim();
    _toolStock = int.tryParse(_toolStockController.text) ?? 0;

    setState(() => _toolLoading = true);

    final userId = farmer_auth.AuthService().farmer!.id;

    try {
      // Create a new product document with a unique ID for the tool
      final toolDocRef = FirebaseFirestore.instance
          .collection('products')
          .doc();

      // For single items, set default values
      final unit = _isSingleItem ? ['item'] : [_toolUnit!];
      final stock = _isSingleItem ? 1 : _toolStock;
      final minUnitNum = _isSingleItem ? 1 : int.parse(_toolMinUnitNum);

      await toolDocRef.set({
        'productId': toolDocRef.id,
        'farmerId': userId,
        'name': _toolName,
        'description': _toolDescription,
        'category': [_toolCategory!],
        'price': _toolPrice,
        'unit': unit,
        'location': _toolLocation,
        'stock': stock,
        'minUnitNum': minUnitNum,
        'imageUrl': _toolImageUrl ?? '',
        'createdAt': Timestamp.now(),
        'isComplete': true,
        'isActive': true,
        'isTool': true, // Flag to identify farming tools
        'isSingleItem': _isSingleItem, // Flag for single items like tractors
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Farming tool added successfully!')),
        );

        // Reset the form
        _resetToolForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _toolLoading = false);
      }
    }
  }

  void _resetToolForm() {
    setState(() {
      _toolName = '';
      _toolCategory = null;
      _toolDescription = '';
      _toolUnit = null;
      _toolLocation = null;
      _toolStock = 0;
      _toolMinUnitNum = '';
      _toolPrice = 0;
      _toolImageUrl = null;
      _toolLoading = false;
      _toolUploadingImage = false;
      _toolAllFieldsFilled = false;
      _isSingleItem = false; // Reset single item flag
    });

    _toolNameController.clear();
    _toolDescriptionController.clear();
    _toolPriceController.clear();
    _toolStockController.clear();
    _toolMinUnitController.clear();

    _checkToolAllFieldsFilled();
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

    // Dispose tools controllers
    _toolDescriptionController.removeListener(_checkToolAllFieldsFilled);
    _toolPriceController.removeListener(_checkToolAllFieldsFilled);
    _toolMinUnitController.removeListener(_checkToolAllFieldsFilled);
    _toolStockController.removeListener(_checkToolAllFieldsFilled);
    _toolNameController.dispose();
    _toolDescriptionController.dispose();
    _toolPriceController.dispose();
    _toolStockController.dispose();
    _toolMinUnitController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.product == null) {
          await FirebaseFirestore.instance
              .collection('products')
              .doc(widget.productId)
              .delete();
        }
        Navigator.of(context).pop();
        return false;
      },
      child: DefaultTabController(
        length: 2,
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
            bottom: TabBar(
              tabs: [
                Tab(text: 'Farm Product'),
                Tab(text: 'Product & Farming Tools'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Farm Product Tab (updated with improved code)
              ListView(
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
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
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
                                          print(
                                            'AddProductScreen: Before setState',
                                          );
                                          setState(() {
                                            _location = selectedLocation;
                                            print(
                                              'AddProductScreen: Location set to: $_location',
                                            );
                                          });
                                          print(
                                            'AddProductScreen: After setState',
                                          );
                                          _checkAllFieldsFilled();
                                          print(
                                            'AddProductScreen: After _checkAllFieldsFilled',
                                          );
                                        } catch (e) {
                                          print(
                                            'Error in location selection: $e',
                                          );
                                          print(
                                            'Error stack trace: ${e.toString()}',
                                          );
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
                                        inputType:
                                            TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        validator: (v) =>
                                            v == null ||
                                                double.tryParse(v) == null
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
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFF4CAF50),
                                            ),
                                          ),
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
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
                                          padding: EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                                child:
                                                    CircularProgressIndicator(
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
                                                  await FirebaseFirestore
                                                      .instance
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
              // Product & Farming Tools Tab (complete implementation)
              ListView(
                children: [
                  // Image at the top for tools
                  if (_toolImageUrl != null && _toolImageUrl!.isNotEmpty)
                    ProductImageDisplay(
                      imageUrl: _toolImageUrl!,
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
                            key: _toolsFormKey,
                            child: ListView(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              children: [
                                Text(
                                  'Add Farming Tool or Equipment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                                SizedBox(height: 16),

                                // Single Item Toggle
                                Card(
                                  elevation: 2,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.construction,
                                          color: Color(0xFF4CAF50),
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Single Item (like a tractor, combine harvester)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Switch(
                                          value: _isSingleItem,
                                          activeColor: Color(0xFF4CAF50),
                                          onChanged: (value) {
                                            setState(() {
                                              _isSingleItem = value;
                                              // Clear unit-related fields when switching to single item
                                              if (_isSingleItem) {
                                                _toolUnit = null;
                                                _toolStock = 1;
                                                _toolMinUnitNum = '1';
                                                _toolStockController.text = '1';
                                                _toolMinUnitController.text =
                                                    '1';
                                              }
                                            });
                                            _checkToolAllFieldsFilled();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),

                                // Tool Name Field
                                CustomTextFormField(
                                  controller: _toolNameController,
                                  label: 'Tool/Equipment Name *',
                                  hintText: 'e.g., Tractor, Plow, Seeds',
                                  underlineborder: true,
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                  onChanged: (value) {
                                    setState(() {
                                      _toolName = value ?? '';
                                    });
                                    _checkToolAllFieldsFilled();
                                  },
                                  onSaved: (v) {},
                                ),
                                SizedBox(height: 16),

                                // Category Dropdown for Tools
                                DropdownButtonFormField<String>(
                                  value: _toolCategory,
                                  items:
                                      [
                                            'Farm Equipment',
                                            'Seeds',
                                            'Fertilizers',
                                            'Pesticides',
                                            'Tools',
                                            'Irrigation Equipment',
                                            'Harvesting Tools',
                                            'Other',
                                          ]
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
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                  onChanged: (v) {
                                    setState(() => _toolCategory = v);
                                    _checkToolAllFieldsFilled();
                                  },
                                  onSaved: (v) => _toolCategory = v,
                                ),
                                SizedBox(height: 16),

                                // Description Field
                                CustomTextFormField(
                                  controller: _toolDescriptionController,
                                  inputType: TextInputType.multiline,
                                  underlineborder: true,
                                  label: 'Description *',
                                  hintText: 'Describe the tool/equipment...',
                                  maxLines: 3,
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
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
                                          _toolLocation = selectedLocation;
                                        });
                                        _checkToolAllFieldsFilled();
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),

                                // Price, Unit, Stock Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextFormField(
                                        hintText: _isSingleItem
                                            ? 'e.g., 50000'
                                            : 'e.g., 500',
                                        underlineborder: true,
                                        controller: _toolPriceController,
                                        label: 'Price *',
                                        inputType:
                                            TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        validator: (v) =>
                                            v == null ||
                                                double.tryParse(v) == null
                                            ? 'Required'
                                            : null,
                                        onSaved: (v) {},
                                      ),
                                    ),
                                    if (!_isSingleItem) ...[
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: _toolUnit,
                                          items:
                                              [
                                                    'piece',
                                                    'hour',
                                                    'day',
                                                    'week',
                                                    'month',
                                                    'kg',
                                                    'litre',
                                                    'bag',
                                                    'box',
                                                    'set',
                                                  ]
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
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFF4CAF50),
                                              ),
                                            ),
                                          ),
                                          validator: (v) =>
                                              v == null || v.isEmpty
                                              ? 'Required'
                                              : null,
                                          onChanged: (v) {
                                            setState(() => _toolUnit = v);
                                            _checkToolAllFieldsFilled();
                                          },
                                          onSaved: (v) => _toolUnit = v,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: CustomTextFormField(
                                          underlineborder: true,
                                          hintText: 'e.g., 10',
                                          controller: _toolStockController,
                                          label: 'Available Quantity *',
                                          inputType: TextInputType.number,
                                          validator: (v) =>
                                              v == null ||
                                                  int.tryParse(v) == null
                                              ? 'Required'
                                              : null,
                                          onSaved: (v) {},
                                        ),
                                      ),
                                    ] else ...[
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          child: Text(
                                            'Single Item',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          child: Text(
                                            'Qty: 1',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 16),

                                // Minimum Order/Rental Amount - only show for non-single items
                                if (!_isSingleItem) ...[
                                  CustomTextFormField(
                                    underlineborder: true,
                                    controller: _toolMinUnitController,
                                    label: 'Minimum Order/Rental Amount *',
                                    hintText: 'e.g., 1',
                                    inputType: TextInputType.number,
                                    validator: (v) =>
                                        v == null || int.tryParse(v) == null
                                        ? 'Required'
                                        : null,
                                    onSaved: (v) {},
                                  ),
                                ] else ...[
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.grey[600],
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Single item - minimum purchase: 1 unit',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                SizedBox(height: 24),

                                // Add Image Button for Tools
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _toolUploadingImage
                                        ? null
                                        : _pickAndUploadToolImage,
                                    icon: _toolUploadingImage
                                        ? SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(Icons.upload),
                                    label: Text(
                                      _toolImageUrl != null &&
                                              _toolImageUrl!.isNotEmpty
                                          ? 'Change Tool Picture'
                                          : 'Add Tool Picture',
                                    ),
                                  ),
                                ),

                                // Save and Reset Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed:
                                            _toolLoading ||
                                                _toolCategory == null ||
                                                (_toolUnit == null &&
                                                    !_isSingleItem) ||
                                                _toolLocation == null ||
                                                _toolLocation!.isEmpty ||
                                                _toolImageUrl == null ||
                                                _toolImageUrl!.isEmpty
                                            ? null
                                            : _submitTool,
                                        child: _toolLoading
                                            ? SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text('Save Farming Tool'),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: _toolLoading
                                            ? null
                                            : _resetToolForm,
                                        child: Text('Reset Form'),
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
            ],
          ),
        ),
      ),
    );
  }
}
