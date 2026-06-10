import 'package:agrohub_app/pages/app_entry_gate.dart';
import 'package:agrohub_app/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    sqflite.databaseFactory = databaseFactoryFfiWeb;
  }
  await ThemeService.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildLightTheme() {
    const seedColor = Color(0xFF24961F);
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

      return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: seedColor,
        secondary: const Color(0xFF1B6E18),
        surface: const Color(0xFFF8FAF7),
      ),
      scaffoldBackgroundColor: const Color(0xFFF3F6F2),
      appBarTheme: const AppBarTheme(
        backgroundColor: seedColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const seedColor = Color(0xFF24961F);
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: seedColor,
        secondary: const Color(0xFF86D97F),
        surface: const Color(0xFF1B1E1B),
      ),
      scaffoldBackgroundColor: const Color(0xFF111311),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1D3C1B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.notifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AgroHub',
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeMode,
          home: const AppEntryGate(),
        );
      },
    );
  }
}
