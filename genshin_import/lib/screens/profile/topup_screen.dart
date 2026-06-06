import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../services/mora_notifier.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> _packages = [
    {
      'mora': 10000,
      'price': 100000.0,
      'label': '10.000 Mora',
      'priceLabel': 'Rp 100.000',
      'image': 'assets/images/mora_icon.png',
    },
    {
      'mora': 50000,
      'price': 500000.0,
      'label': '50.000 Mora',
      'priceLabel': 'Rp 500.000',
      'image': 'assets/images/mora_icon.png',
    },
    {
      'mora': 100000,
      'price': 1000000.0,
      'label': '100.000 Mora',
      'priceLabel': 'Rp 1.000.000',
      'image': 'assets/images/small_bag_mora.png',
    },
    {
      'mora': 1000000,
      'price': 10000000.0,
      'label': '1.000.000 Mora',
      'priceLabel': 'Rp 10.000.000',
      'image': 'assets/images/big_bag_mora.png',
    },
  ];

  void _confirmTopUp(Map<String, dynamic> package) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkHeader : AppColors.lightHeader,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Top Up',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              package['image'],
              height: 60,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.monetization_on,
                  color: AppColors.gold,
                  size: 60),
            ),
            const SizedBox(height: 8),
            Text(
              package['label'],
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold),
            ),
            Text(
              package['priceLabel'],
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _doTopUp(package);
            },
            child: Text('Confirm',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _doTopUp(Map<String, dynamic> package) async {
    setState(() => _isLoading = true);
    final result = await ApiService.topUp(
        package['mora'] as int, package['price'] as double);
    setState(() => _isLoading = false);

    // DEBUG
    print('TopUp result: $result');
    print('TopUp data: ${result['data']}');

    if (!mounted) return;
    final success = result['success'] == true;

    if (success) {
      final newMora = result['data']?['mora'];
      print('New mora value: $newMora, type: ${newMora.runtimeType}');

      if (newMora != null) {
        final moraValue = double.parse(newMora.toString());
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('user_mora', moraValue);
        MoraNotifier.instance.update(moraValue);
        print('MoraNotifier updated to: $moraValue');
      } else {
        print('newMora is NULL - backend tidak return mora!');
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            result['message'] ??
                (success ? 'Top up successful!' : 'Top up failed'),
            style: GoogleFonts.poppins()),
        backgroundColor: success ? Colors.green : AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        title: Text('Top Up Mora',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 16)),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Package',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: _packages.length,
                    itemBuilder: (_, index) {
                      final pkg = _packages[index];
                      return GestureDetector(
                        onTap: () => _confirmTopUp(pkg),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkHeader
                                : AppColors.lightHeader,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 16, 16, 8),
                                  child: Image.asset(
                                    pkg['image'],
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(
                                            Icons.monetization_on,
                                            color: AppColors.gold,
                                            size: 48),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      pkg['label'],
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      pkg['priceLabel'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black38,
              child: const Center(
                  child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}