import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  String? _profilePicturePath;
  String? _coverPhotoPath;
  String? _existingProfilePic;
  String? _existingCoverPhoto;
  bool _isLoading = false;
  bool _removeProfilePicture = false; // ← tambah
  bool _removeCoverPhoto = false;     // ← tambah

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('user_name') ?? '';
    _emailController.text = prefs.getString('user_email') ?? '';
    _bioController.text = prefs.getString('user_bio') ?? '';
    setState(() {
      _existingProfilePic = prefs.getString('user_profile_picture');
      _existingCoverPhoto = prefs.getString('user_cover_photo');
    });
  }

  Future<void> _pickImage(bool isProfile) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        if (isProfile) {
          _profilePicturePath = picked.path;
          _removeProfilePicture = false;
        } else {
          _coverPhotoPath = picked.path;
          _removeCoverPhoto = false;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Name cannot be empty', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.updateProfile(
      {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'bio': _bioController.text.trim(),
      },
      _profilePicturePath,
      _coverPhotoPath,
      removeProfilePicture: _removeProfilePicture,
      removeCoverPhoto: _removeCoverPhoto,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;
    final success = result['success'] == true;

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('user_email', _emailController.text.trim());
      await prefs.setString('user_bio', _bioController.text.trim());
      final data = result['data'];
      if (data != null) {
        if (data['profile_picture'] != null) {
          await prefs.setString('user_profile_picture', data['profile_picture']);
        } else {
          await prefs.remove('user_profile_picture');
        }
        if (data['cover_photo'] != null) {
          await prefs.setString('user_cover_photo', data['cover_photo']);
        } else {
          await prefs.remove('user_cover_photo');
        }
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            result['message'] ?? (success ? 'Profile updated!' : 'Failed'),
            style: GoogleFonts.poppins()),
        backgroundColor: success ? Colors.green : AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (success && mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCover = _coverPhotoPath != null ||
        (_existingCoverPhoto != null && !_removeCoverPhoto);
    final hasProfilePic = _profilePicturePath != null ||
        (_existingProfilePic != null && !_removeProfilePicture);

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
        title: Text('Edit Profile',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Photo
            Stack(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(false),
                  child: Container(
                    width: double.infinity,
                    height: 130,
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
                    child: hasCover
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _coverPhotoPath != null
                                ? Image.file(File(_coverPhotoPath!),
                                    fit: BoxFit.cover)
                                : Image.network(
                                    ApiService.buildImageUrl(
                                        _existingCoverPhoto!),
                                    fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 36, color: Colors.grey),
                              Text('Tap to add cover photo',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                // Tombol hapus cover
                if (hasCover)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _removeCoverPhoto = true;
                        _coverPhotoPath = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Profile Picture
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(true),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.gold.withOpacity(0.2),
                      backgroundImage: hasProfilePic
                          ? (_profilePicturePath != null
                              ? FileImage(File(_profilePicturePath!))
                              : NetworkImage(ApiService.buildImageUrl(
                                  _existingProfilePic!)) as ImageProvider)
                          : null,
                      child: !hasProfilePic
                          ? Icon(Icons.person,
                              size: 48, color: AppColors.gold)
                          : null,
                    ),
                  ),
                  // Tombol kamera
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickImage(true),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 14, color: Colors.black),
                      ),
                    ),
                  ),
                  // Tombol hapus profile picture
                  if (hasProfilePic)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _removeProfilePicture = true;
                          _profilePicturePath = null;
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name
            _label('Username'),
            const SizedBox(height: 6),
            _textField(_nameController, 'Enter username', isDark),
            const SizedBox(height: 16),

            // Email
            _label('Email'),
            const SizedBox(height: 6),
            _textField(_emailController, 'Enter email', isDark,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),

            // Bio
            _label('Bio'),
            const SizedBox(height: 6),
            _textField(
                _bioController, 'Write something about you...', isDark,
                maxLines: 3),
            const SizedBox(height: 32),

            // Save Button
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
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black),
                      )
                    : Text('Save Changes',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style:
            GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
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
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: isDark
            ? AppColors.gold.withOpacity(0.1)
            : AppColors.lightBorder.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color:
                  isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color:
                  isDark ? AppColors.darkBorder : AppColors.lightBorder),
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
}