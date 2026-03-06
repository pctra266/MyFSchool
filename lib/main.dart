import 'package:flutter/material.dart';
import 'dart:io';
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/profile.dart';
import 'screens/academic_results.dart';
import 'screens/timetable.dart';
import 'screens/attendance.dart';
import 'screens/leave_request.dart';
import 'screens/notes.dart';
import 'screens/meal_plan.dart';
import 'screens/tuition.dart';
import 'screens/health_records.dart';
import 'screens/notification.dart';
import 'screens/news_detail.dart';
import 'screens/payment_confirmation.dart';
import 'screens/reset_password.dart';

const Color kPrimaryColor = Color(0xFFBFA18E);
const Color kSurfaceColor = Color(0xFFF4ECE6);

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: kPrimaryColor,
      brightness: Brightness.light,
      surface: kSurfaceColor,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyFSchool',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: kSurfaceColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kPrimaryColor,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: kPrimaryColor.withValues(alpha: 0.12),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: kPrimaryColor.withValues(alpha: 0.2)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: kPrimaryColor.withValues(alpha: 0.3)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(color: kPrimaryColor, width: 1.4),
          ),
        ),
      ),
      home: const SignInScreen(),
      routes: {
        '/academic_results': (context) => const AcademicResultsScreen(),
        '/timetable': (context) => const TimetableScreen(),
        '/attendance': (context) => const AttendanceScreen(),
        '/leave_request': (context) => const LeaveRequestScreen(),
        '/notes': (context) => const NotesScreen(),
        '/meal_plan': (context) => const MealPlanScreen(),
        '/tuition': (context) => const TuitionScreen(),
        '/health_records': (context) => const HealthRecordsScreen(),
        '/payment_confirmation': (context) => const PaymentConfirmationScreen(),
        '/news_detail': (context) => NewsDetailScreen(newsItem: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
        '/reset_password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: kPrimaryColor.withValues(alpha: 0.2),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

