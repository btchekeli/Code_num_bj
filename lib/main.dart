import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/splash_screen.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Data initialization is now moved to SplashScreen
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, child) {
        return MaterialApp(
          title: 'Code du numérique en République du Bénin',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1A237E), // Deep Blue
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            textTheme: GoogleFonts.outfitTextTheme(),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(
                  0xFF3949AB), // Slightly lighter Indigo for dark mode
              brightness: Brightness.dark,
              surface: const Color(
                  0xFF1E1E1E), // Slightly lighter than pure black for depth
              onSurface: Colors.white,
              surfaceContainerLow:
                  const Color(0xFF2C2C2C), // Better contrast for cards
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          themeMode: settings.themeMode,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(settings.textScaleFactor),
              ),
              child: child!,
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
