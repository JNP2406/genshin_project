import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../services/mora_notifier.dart';
import 'edit_profile_screen.dart';
import 'topup_screen.dart';
import '../auth/login_screen.dart';
import '../../services/api_service.dart';
import '../../main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String? _bio;
  String? _profilePicture;
  String? _coverPhoto;
  bool _isDark = false;
  String _role = '';
  double _mora = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    MoraNotifier.instance.addListener(_onMoraChanged);
  }

  void _onMoraChanged() {
    setState(() => _mora = MoraNotifier.instance.value);
  }

  @override
  void dispose() {
    MoraNotifier.instance.removeListener(_onMoraChanged);
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? '';
      _email = prefs.getString('user_email') ?? '';
      _role = prefs.getString('user_role') ?? '';
      _bio = prefs.getString('user_bio');
      _profilePicture = prefs.getString('user_profile_picture');
      _coverPhoto = prefs.getString('user_cover_photo');
      _isDark = prefs.getBool('isDarkMode') ?? false;
      final savedMora = prefs.getDouble('user_mora') ?? 0;
      if (MoraNotifier.instance.value > 0) {
        _mora = MoraNotifier.instance.value;
      } else {
        _mora = savedMora;
      }
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() => _isDark = value);
    if (mounted) {
      GenshinImportApp.of(context)?.toggleTheme(value);
    }
  }

  Future<void> _logout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkHeader : AppColors.lightHeader,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to log out?',
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Log Out',
                style:
                    GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      await ApiService.clearUserData();
      MoraNotifier.instance.update(0);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: RefreshIndicator(
        onRefresh: _loadUser,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Cover + PP + Edit Button
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: isDark
                        ? AppColors.darkHeader
                        : AppColors.lightHeader,
                    child: _coverPhoto != null
                        ? Image.network(
                            ApiService.buildImageUrl(_coverPhoto ?? ''),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          )
                        : null,
                  ),

                  // Edit button
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.white),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const EditProfileScreen()),
                                );
                                _loadUser();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Profile Picture
                  Positioned(
                    bottom: -40,
                    left: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            AppColors.gold.withOpacity(0.3),
                        backgroundImage: _profilePicture != null
                            ? NetworkImage(ApiService.buildImageUrl(_profilePicture ?? ''))
                            : null,
                        child: _profilePicture == null
                            ? Text(
                                _name.isNotEmpty
                                    ? _name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gold),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 52),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Email + Role
                    Text(
                      _name,
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _email,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      _role.isNotEmpty
                          ? _role[0].toUpperCase() +
                              _role.substring(1)
                          : '',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 12),

                    // Bio
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
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
                      child: Text(
                        (_bio != null && _bio!.isNotEmpty)
                            ? _bio!
                            : 'No bio yet...',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: (_bio != null && _bio!.isNotEmpty)
                              ? (isDark
                                  ? Colors.white70
                                  : Colors.black87)
                              : Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Dark Mode Toggle
                    _settingTile(
                      isDark: isDark,
                      icon: _isDark
                          ? Icons.wb_sunny
                          : Icons.dark_mode,
                      label: _isDark ? 'Light Mode' : 'Dark Mode',
                      trailing: Switch(
                        value: _isDark,
                        onChanged: _toggleDarkMode,
                        activeColor: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Top Up
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TopUpScreen()),
                        );
                        await _loadUser();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_card,
                                size: 22, color: AppColors.gold),
                            const SizedBox(width: 10),
                            Text(
                              'Top Up',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Log Out
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.logout, size: 20),
                        label: Text(
                          'Log Out',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                        ),
                        onPressed: _logout,
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingTile({
    required bool isDark,
    required IconData icon,
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? labelColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            Icon(icon,
                size: 20, color: iconColor ?? AppColors.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: labelColor),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}