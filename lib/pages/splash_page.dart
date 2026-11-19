import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/preferences_provider.dart';
import 'draft_list_page.dart';

/// 启动页
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesProvider>(
      builder: (ctx, prefs, _) {
        if (prefs.loading || prefs.prefs == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final entry = prefs.homeEntry;
          Navigator.of(ctx).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DraftListPage(openProfile: entry == 'published'),
            ),
          );
        });
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_note, size: 64, color: Color(0xFF8B5A2B)),
                SizedBox(height: 12),
                Text('WriteYouLove', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF8B5A2B))),
                SizedBox(height: 8),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}
