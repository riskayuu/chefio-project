import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chefio/services/theme_provider.dart';
import 'package:chefio/page/GetStarted.dart';
import 'package:chefio/page/Homepage.dart';
import 'package:chefio/page/sign_in.dart';
import 'package:chefio/page/sign_up.dart';
import 'package:chefio/page/SuccessfulPage.dart';
import 'package:chefio/page/forgot_password.dart';
import 'package:chefio/page/breakfast_page.dart';
import 'package:chefio/page/lunch_dinner_page.dart';
import 'package:chefio/page/milkshake_page.dart';
import 'package:chefio/page/dessert_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://cwkgrvnnnreiqjbmwvni.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3a2dydm5ubnJlaXFqYm13dm5pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzNTgxMTIsImV4cCI6MjA4NzkzNDExMn0.NwVXsu2XzlXpbxKr9kIJI9yni6vmhu_MO3Nf7u1XLkU",
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    const primaryColor = Color(0xFFE91E63);

    return MaterialApp(
      title: 'Chefio',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey.shade50,
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          primary: primaryColor,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        cardColor: const Color(0xFF2C2C2C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF212121),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
          primary: primaryColor,
        ),
      ),
      home: const AuthStream(),
      routes: {
        '/getstarted': (context) => const GetStarted(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/success': (context) => const SuccessfulPage(),
        '/home': (context) => const HomePage(initialIndex: 0),
        '/profile': (context) => const HomePage(initialIndex: 2),
        '/breakfast': (context) => const BreakfastPage(),
        '/milkshake': (context) => const MilkshakePage(),
        '/dessert': (context) => const DessertPage(),
        '/lunch': (context) => const LunchDinnerPage(),
      },
    );
  }
}

class AuthStream extends StatelessWidget {
  const AuthStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data?.session != null) {
          return const HomePage();
        }
        return const GetStarted();
      },
    );
  }
}