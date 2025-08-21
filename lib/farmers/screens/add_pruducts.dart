import 'package:denbigh_app/farmers/model/products.dart';
import 'package:denbigh_app/farmers/services/auth.dart' as farmer_auth;
import 'package:denbigh_app/farmers/widgets/autocompleter_products.dart';
import 'package:denbigh_app/farmers/widgets/textField.dart';
import 'package:denbigh_app/farmers/widgets/used_list/list.dart';
import 'package:denbigh_app/widgets/autoCompleter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// Widget for displaying product images with consistent styling
class ProductImageDisplay extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double borderRadius;

  const ProductImageDisplay({
    super.key,
    required this.imageUrl,
    this.height = 300,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}

/// Custom app bar widget for consistent styling
class CustomGradientAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget> tabs;

  const CustomGradientAppBar({
    super.key,
    required this.title,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
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
            colors: [Color(0xFF66BB6A), Color(0xFF4CAF50), Color(0xFF2E7D32)],
          ),
        ),
      ),
      bottom: TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        tabs: tabs,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}

/// Custom form container widget with gradient background
class CustomFormContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const CustomFormContainer({
    super.key,
    required this.child,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 540,
        child: Container(
          margin: margin ?? EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFFAFCFA)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.all(32.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Enhanced section header with icon and description
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFF2E7D32),
                ),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom toggle switch with enhanced styling
class SingleItemToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SingleItemToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E8)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.construction, color: Colors.white, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Single Item',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'For unique items like tractors, combine harvesters',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: value,
              activeColor: Color(0xFF4CAF50),
              activeTrackColor: Color(0xFF4CAF50).withOpacity(0.3),
              inactiveThumbColor: Colors.grey[400],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom info box for single item mode
class SingleItemInfoBox extends StatelessWidget {
  const SingleItemInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E8)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.info, color: Colors.white, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Single Item Mode: This is a unique item that sells as one unit',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom button with consistent styling
class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? backgroundColor;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.green,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: loading ? null : onPressed,
      icon: loading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : (icon != null ? Icon(icon) : SizedBox.shrink()),
      label: Text(text),
    );
  }
}

/// Custom image picker button with upload functionality
class ImageUploadButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool uploading;

  const ImageUploadButton({
    super.key,
    required this.text,
    this.onPressed,
    this.uploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: uploading ? null : onPressed,
        icon: uploading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.upload),
        label: Text(text),
      ),
    );
  }
}

/// Custom dropdown field with consistent styling
class CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String labelText;
  final FormFieldValidator<T>? validator;
  final ValueChanged<T?>? onChanged;
  final FormFieldSetter<T>? onSaved;

  const CustomDropdownField({
    super.key,
    this.value,
    required this.items,
    required this.labelText,
    this.validator,
    this.onChanged,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items
          .map(
            (item) =>
                DropdownMenuItem(value: item, child: Text(item.toString())),
          )
          .toList(),
      decoration: InputDecoration(
        labelText: labelText,
        border: UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4CAF50)),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }
}

/// Location field widget with label
class LocationField extends StatelessWidget {
  final ValueChanged<String?> onLocationSelected;

  const LocationField({super.key, required this.onLocationSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location *',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        SizedBox(height: 8),
        LocationAutoComplete(
          underlineBorder: true,
          onCategorySelected: onLocationSelected,
        ),
      ],
    );
  }
}

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

        // Navigate back after successful submission
        Navigator.of(context).pop();
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
          appBar: CustomGradientAppBar(
            title: _name.isEmpty ? 'Add New Product' : 'Edit Product',
            tabs: [
              Tab(text: 'Farm Product'),
              Tab(text: 'Product & Farming Tools'),
            ],
          ),
          body: TabBarView(
            children: [_buildFarmProductTab(), _buildToolsTab()],
          ),
        ),
      ),
    );
  }

  /// Build Farm Product Tab - Main product form
  Widget _buildFarmProductTab() {
    return ListView(
      children: [
        // Display product image if available
        if (_imageUrl != null && _imageUrl!.isNotEmpty)
          ProductImageDisplay(imageUrl: _imageUrl!),

        CustomFormContainer(
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: [
                // Product name autocompleter
                AutocompleterProducts(
                  underlineBorder: true,
                  onNameSelected: (selectedName) {
                    setState(() => _name = selectedName ?? '');
                    _checkAllFieldsFilled();
                  },
                ),
                SizedBox(height: 16),

                // Category dropdown
                CustomDropdownField<String>(
                  value: _category,
                  items: categories,
                  labelText: 'Category *',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  onChanged: (v) {
                    setState(() => _category = v);
                    _checkAllFieldsFilled();
                  },
                  onSaved: (v) => _category = v,
                ),
                SizedBox(height: 16),

                // Description field
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

                // Location field
                LocationField(
                  onLocationSelected: (selectedLocation) {
                    try {
                      setState(() => _location = selectedLocation);
                      _checkAllFieldsFilled();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error selecting location: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                SizedBox(height: 16),

                // Price, Unit, Stock row
                _buildPriceUnitStockRow(),
                SizedBox(height: 16),

                // Minimum sale amount field
                CustomTextFormField(
                  underlineborder: true,
                  controller: _minUnitNumController,
                  label: 'Minimum Sale Amount *',
                  hintText: 'e.g., 100',
                  inputType: TextInputType.text,
                  validator: (v) =>
                      v == null || int.tryParse(v) == null ? 'Required' : null,
                  onSaved: (v) {},
                ),
                SizedBox(height: 24),

                // Image upload button
                ImageUploadButton(
                  text: _imageUrl != null && _imageUrl!.isNotEmpty
                      ? 'Change Item Picture'
                      : 'Add Item Picture',
                  onPressed: _pickAndUploadImage,
                  uploading: _uploadingImage,
                ),

                // Action buttons row
                _buildActionButtonsRow(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build Tools Tab - Farming tools form
  Widget _buildToolsTab() {
    return ListView(
      children: [
        // Display tool image if available
        if (_toolImageUrl != null && _toolImageUrl!.isNotEmpty)
          ProductImageDisplay(imageUrl: _toolImageUrl!),

        CustomFormContainer(
          child: Form(
            key: _toolsFormKey,
            child: ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: [
                // Header section
                SectionHeader(
                  icon: Icons.agriculture,
                  title: 'Add Farming Tool or Equipment',
                  description: 'List your farming equipment for sale',
                ),
                SizedBox(height: 24),

                // Single item toggle
                SingleItemToggle(
                  value: _isSingleItem,
                  onChanged: (value) {
                    setState(() {
                      _isSingleItem = value;
                      if (_isSingleItem) {
                        _toolUnit = null;
                        _toolStock = 1;
                        _toolMinUnitNum = '1';
                        _toolStockController.text = '1';
                        _toolMinUnitController.text = '1';
                      }
                    });
                    _checkToolAllFieldsFilled();
                  },
                ),
                SizedBox(height: 20),

                // Tool name field
                CustomTextFormField(
                  controller: _toolNameController,
                  label: 'Tool/Equipment Name *',
                  hintText: 'e.g., Tractor, Plow, Seeds',
                  underlineborder: true,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  onChanged: (value) {
                    setState(() => _toolName = value ?? '');
                    _checkToolAllFieldsFilled();
                  },
                  onSaved: (v) {},
                ),
                SizedBox(height: 16),

                // Category dropdown for tools
                CustomDropdownField<String>(
                  value: _toolCategory,
                  items: toolCategories,
                  labelText: 'Category *',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  onChanged: (v) {
                    setState(() => _toolCategory = v);
                    _checkToolAllFieldsFilled();
                  },
                  onSaved: (v) => _toolCategory = v,
                ),
                SizedBox(height: 16),

                // Description field
                CustomTextFormField(
                  controller: _toolDescriptionController,
                  inputType: TextInputType.multiline,
                  underlineborder: true,
                  label: 'Description *',
                  hintText: 'Describe the tool/equipment...',
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  onSaved: (v) {},
                ),
                SizedBox(height: 16),

                // Location field for tools
                LocationField(
                  onLocationSelected: (selectedLocation) {
                    setState(() => _toolLocation = selectedLocation);
                    _checkToolAllFieldsFilled();
                  },
                ),
                SizedBox(height: 16),

                // Price, Unit, Stock row for tools
                _buildToolPriceUnitStockRow(),
                SizedBox(height: 16),

                // Minimum order/rental amount or single item info
                if (!_isSingleItem) ...[
                  CustomTextFormField(
                    underlineborder: true,
                    controller: _toolMinUnitController,
                    label: 'Minimum Order/Rental Amount *',
                    hintText: 'e.g., 1',
                    inputType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null
                        ? 'Required'
                        : null,
                    onSaved: (v) {},
                  ),
                ] else ...[
                  SingleItemInfoBox(),
                ],
                SizedBox(height: 24),

                // Tool image upload button
                ImageUploadButton(
                  text: _toolImageUrl != null && _toolImageUrl!.isNotEmpty
                      ? 'Change Tool Picture'
                      : 'Add Tool Picture',
                  onPressed: _pickAndUploadToolImage,
                  uploading: _toolUploadingImage,
                ),

                // Tool action buttons row
                _buildToolActionButtonsRow(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build price, unit, and stock row for main product form
  Widget _buildPriceUnitStockRow() {
    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            hintText: 'e.g., 200',
            underlineborder: true,
            controller: _priceController,
            label: 'Price *',
            inputType: TextInputType.numberWithOptions(decimal: true),
            validator: (v) =>
                v == null || double.tryParse(v) == null ? 'Required' : null,
            onSaved: (v) {},
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: CustomDropdownField<String>(
            value: _unit,
            items: units,
            labelText: 'Unit *',
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                v == null || int.tryParse(v) == null ? 'Required' : null,
            onSaved: (v) {},
          ),
        ),
      ],
    );
  }

  /// Build price, unit, and stock row for tools form
  Widget _buildToolPriceUnitStockRow() {
    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            hintText: _isSingleItem ? 'e.g., 50000' : 'e.g., 500',
            underlineborder: true,
            controller: _toolPriceController,
            label: 'Price *',
            inputType: TextInputType.numberWithOptions(decimal: true),
            validator: (v) =>
                v == null || double.tryParse(v) == null ? 'Required' : null,
            onSaved: (v) {},
          ),
        ),
        if (!_isSingleItem) ...[
          SizedBox(width: 16),
          Expanded(
            child: CustomDropdownField<String>(
              value: _toolUnit,
              items: toolUnits,
              labelText: 'Unit *',
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                  v == null || int.tryParse(v) == null ? 'Required' : null,
              onSaved: (v) {},
            ),
          ),
        ] else ...[
          SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Single Item',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Qty: 1',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build action buttons row for main product form
  Widget _buildActionButtonsRow() {
    return Row(
      children: [
        Expanded(
          child: CustomElevatedButton(
            text: widget.product == null ? 'Save Product Info' : 'Save Changes',
            loading: _loading,
            onPressed:
                _loading ||
                    _category == null ||
                    categories.isEmpty ||
                    _unit == null ||
                    units.isEmpty ||
                    _location == null ||
                    _location!.isEmpty ||
                    _imageUrl == null ||
                    _imageUrl!.isEmpty
                ? null
                : _submit,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _loading
                ? null
                : () async {
                    if (widget.product == null) {
                      await FirebaseFirestore.instance
                          .collection('products')
                          .doc(widget.productId)
                          .delete();
                    }
                    Navigator.of(context).pop();
                  },
            child: Text('Cancel'),
          ),
        ),
      ],
    );
  }

  /// Build action buttons row for tools form
  Widget _buildToolActionButtonsRow() {
    return Row(
      children: [
        Expanded(
          child: CustomElevatedButton(
            text: 'Save Farming Tool',
            loading: _toolLoading,
            onPressed:
                _toolLoading ||
                    _toolCategory == null ||
                    (_toolUnit == null && !_isSingleItem) ||
                    _toolLocation == null ||
                    _toolLocation!.isEmpty ||
                    _toolImageUrl == null ||
                    _toolImageUrl!.isEmpty
                ? null
                : _submitTool,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _toolLoading ? null : _resetToolForm,
            child: Text('Reset Form'),
          ),
        ),
      ],
    );
  }
}
