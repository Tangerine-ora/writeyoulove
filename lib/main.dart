import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/document_provider.dart';
import 'providers/preferences_provider.dart';
import 'providers/draft_list_provider.dart';
import 'pages/splash_page.dart';

void main() {
  runApp(const WriteYouLoveApp());
}

class WriteYouLoveApp extends StatelessWidget {
  const WriteYouLoveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferencesProvider()..load()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => DraftListProvider()..refresh()),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (ctx, prefs, _) {
          return MaterialApp(
            title: 'WriteYouLove',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(),
            home: const SplashPage(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    const warmBrown = Color(0xFF8B5A2B);
    const creamWhite = Color(0xFFFDF8F0);
    final scheme = ColorScheme.fromSeed(
      seedColor: warmBrown,
      brightness: Brightness.light,
      surface: creamWhite,
      primary: warmBrown,
      secondary: Color(0xFFC89B5B),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: creamWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: warmBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFD7C4A8), width: 0.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: warmBrown,
        foregroundColor: Colors.white,
      ),
    );
  }
}
