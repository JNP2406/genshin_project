import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/mora_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final token = prefs.getString('token') ?? '';
  final mora = prefs.getDouble('user_mora') ?? 0; 
  MoraNotifier.instance.update(mora);              

  runApp(GenshinImportApp(isDarkMode: isDarkMode, token: token));
}

class GenshinImportApp extends StatefulWidget {
  final bool isDarkMode;
  final String token;

  const GenshinImportApp({
    super.key,
    required this.isDarkMode,
    required this.token,
  });

  static GenshinImportAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<GenshinImportAppState>();

  @override
  State<GenshinImportApp> createState() => GenshinImportAppState();
}

class GenshinImportAppState extends State<GenshinImportApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genshin Import',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: widget.token.isNotEmpty
          ? const MainScreen()
          : const LoginScreen(),
    );
  }
}