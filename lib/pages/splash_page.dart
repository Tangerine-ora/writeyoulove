import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/preferences.dart';
import 'draft_list_page.dart';
import 'published_page.dart';

/// 启动页：等待偏好加载 → 根据 homeEntry 决定进入草稿箱或发布页
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesProvider>(
      builder: (ctx, prefs, _) {
        if (prefs.loading || prefs.prefs == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        Future.microtask(() {
          final entry = prefs.homeEntry;
          Navigator.of(ctx).pushReplacement(
            MaterialPageRoute(
              builder: (_) => entry == HomeEntry.published
                  ? const PublishedPage()
                  : const DraftListPage(),
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
                Text('WriteYouLove',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5A2B),
                    )),
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
