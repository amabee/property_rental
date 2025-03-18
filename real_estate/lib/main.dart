import 'package:flutter/material.dart';
import 'package:real_estate/pages/login_page.dart';
import 'package:real_estate/pages/admin_pages/dashboard.dart';
import 'package:real_estate/pages/staff_pages/dashboard.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();
    await Hive.openBox('myBox');
  } catch (e) {
    print('Error initializing Hive: $e');
  }

  runApp(PropertyApp());
}

class PropertyApp extends StatefulWidget {
  @override
  _PropertyAppState createState() => _PropertyAppState();
}

class _PropertyAppState extends State<PropertyApp> {
  bool _isDarkMode = false;
  Widget _initialScreen =
      const CircularProgressIndicator();

  @override
  void initState() {
    super.initState();
    _checkUserData();
  }

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // Check Hive for saved user data
  void _checkUserData() async {
    final box = Hive.box('myBox');
    final userType = box.get('type');

    if (userType != null) {
      if (userType == 1) {
        setState(() {
          _initialScreen = DashboardScreen(
            toggleTheme: toggleTheme,
            isDarkMode: _isDarkMode,
          );
        });
      } else if (userType == 2) {
        setState(() {
          _initialScreen = StaffDashboardScreen(
            toggleTheme: toggleTheme,
            isDarkMode: _isDarkMode,
          );
        });
      } else {
        _showLoginScreen(); // Unknown type, go to login
      }
    } else {
      _showLoginScreen(); // No saved data, go to login
    }
  }

  void _showLoginScreen() {
    setState(() {
      _initialScreen = LoginScreen(
        toggleTheme: toggleTheme,
        isDarkMode: _isDarkMode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Marketplace',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? _darkTheme : _lightTheme,
      home: Scaffold(body: Center(child: _initialScreen)),
    );
  }

  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      background: Colors.white,
    ),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.blue, elevation: 0),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.indigo,
    colorScheme: const ColorScheme.dark(
      primary: Colors.indigo,
      secondary: Colors.indigoAccent,
      surface: Color(0xFF1E1E1E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
