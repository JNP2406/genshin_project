import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/item_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AdminFormScreen extends StatefulWidget {
  final ItemModel? item;

  const AdminFormScreen({super.key, this.item});

  @override
  State<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();

  String? _selectedCategory;
  String? _selectedType;
  String? _imagePath;
  String? _existingImage;
  bool _isLoading = false;

  final List<String> _categories = ['Weapon', 'Artifact'];
  final Map<String, List<String>> _typesByCategory = {
    'Weapon': ['Sword', 'Claymore', 'Polearm', 'Bow', 'Catalyst'],
    'Artifact': ['Flower', 'Feather', 'Sands', 'Goblet', 'Circlet'],
  };

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final item = widget.item!;
      _nameController.text = item.name;
      _descController.text = item.description;
      _stockController.text = item.stock.toString();
      _priceController.text = item.price.toStringAsFixed(2);
      _selectedCategory = item.category;
      _selectedType = item.type == 'Plume' ? 'Feather' : item.type;
      _existingImage = item.image;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  String? _validate() {
    if (_nameController.text.trim().isEmpty) return 'Name is required';
    if (_selectedCategory == null) return 'Please select a category';
    if (_selectedType == null) return 'Please select a type';
    if (_descController.text.trim().isEmpty) return 'Description is required';
    if (_stockController.text.trim().isEmpty) return 'Stock is required';
    if (_priceController.text.trim().isEmpty) return 'Price is required';
    if (int.tryParse(_stockController.text.trim()) == null) {
      return 'Stock must be a number';
    }
    if (double.tryParse(_priceController.text.trim()) == null) {
      return 'Price must be a number';
    }
    if (!_isEdit && _imagePath == null) return 'Image is required';
    return null;
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error, style: GoogleFonts.poppins()),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isLoading = true);

    final itemData = {
      'name': _nameController.text.trim(),
      'category': _selectedCategory!,
      'type': _selectedType!,
      'stat': '',
      'description': _descController.text.trim(),
      'stock': _stockController.text.trim(),
      'price': double.parse(
  _priceController.text.trim().replaceAll(',', '.'),
),
    };

    Map<String, dynamic> result;
    if (_isEdit) {
      result = await ApiService.updateItem(
          widget.item!.id, itemData, _imagePath);
    } else {
      result = await ApiService.createItem(itemData, _imagePath!);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;
    final success = result['success'] == true;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          result['message'] ??
              (success
                  ? (_isEdit ? 'Item updated!' : 'Item created!')
                  : 'Failed'),
          style: GoogleFonts.poppins()),
      backgroundColor: success ? Colors.green : AppColors.red,
      behavior: SnackBarBehavior.floating,
    ));

    if (success && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTypes = _selectedCategory != null
        ? _typesByCategory[_selectedCategory]!
        : <String>[];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkHeader : AppColors.lightHeader,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Item' : 'Add Item',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Name
                _label('Weapon/Artifact Name'),
                const SizedBox(height: 6),
                _textField(_nameController, 'Enter name', isDark),
                const SizedBox(height: 16),

                // 2. Type
                _label('Type'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Dropdown kiri — Category
                    Expanded(
                      child: _dropdownWithHint(
                        value: _selectedCategory,
                        hint: 'Select category',
                        items: _categories,
                        isDark: isDark,
                        onChanged: (val) {
                          setState(() {
                            _selectedCategory = val;
                            _selectedType = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Dropdown kanan — Type (disabled kalau category belum dipilih)
                    Expanded(
                      child: _dropdownWithHint(
                        value: _selectedType,
                        hint: 'Select type',
                        items: currentTypes,
                        isDark: isDark,
                        enabled: _selectedCategory != null,
                        onChanged: _selectedCategory != null
                            ? (val) => setState(() => _selectedType = val)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Quantity
                _label('Quantity'),
                const SizedBox(height: 6),
                _textField(_stockController, 'Enter quantity', isDark,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),

                // 4. Price
                _label('Price (Mora)'),
                const SizedBox(height: 6),
                _textField(
  _priceController,
  'Enter price',
  isDark,
  keyboardType: const TextInputType.numberWithOptions(
    decimal: true,
  ),
),
                const SizedBox(height: 16),

                // 5. Description
                _label('Description'),
                const SizedBox(height: 6),
                _textField(_descController, 'Enter description...', isDark,
                    maxLines: 4),
                const SizedBox(height: 16),

                // 6. Upload Image
                _label('Upload Image'),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkHeader
                          : AppColors.lightHeader,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                    child: _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(_imagePath!),
                                fit: BoxFit.contain),
                          )
                        : _existingImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(_existingImage!,
                                    fit: BoxFit.contain),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.upload,
                                      size: 40, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text('Tap to upload image',
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: Text(
                      _isEdit ? 'Update Item' : 'Add Item',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, fontSize: 13),
      );

  Widget _textField(
    TextEditingController controller,
    String hint,
    bool isDark, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
        filled: true,
        fillColor: isDark
            ? AppColors.gold.withValues(alpha: 0.1)
            : AppColors.lightBorder.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _dropdownWithHint({
    required String? value,
    required String hint,
    required List<String> items,
    required bool isDark,
    bool enabled = true,
    void Function(String?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gold.withValues(alpha: enabled ? 0.1 : 0.05)
            : AppColors.lightBorder.withValues(alpha: enabled ? 0.4 : 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: enabled ? Colors.black54 : Colors.black26,
            ),
          ),
          dropdownColor:
              isDark ? AppColors.darkHeader : AppColors.lightHeader,
          style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: enabled ? onChanged : null,
          iconDisabledColor: Colors.black26,
          iconEnabledColor: Colors.black54,
        ),
      ),
    );
  }
}