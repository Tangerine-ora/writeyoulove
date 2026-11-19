import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_colors.dart';
import 'db/app_db.dart';
import 'models/preferences.dart';
import 'providers/document_provider.dart';
import 'providers/draft_list_provider.dart';
import 'providers/preferences_provider.dart';
import 'pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Isar 初始化（首次访问会触发）
  await AppDb.instance;
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
          final mode = prefs.prefs?.themeMode ?? AppThemeMode.warmBrown;
          return MaterialApp(
            title: 'WriteYouLove',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(mode),
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
