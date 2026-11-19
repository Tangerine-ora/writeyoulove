import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/preferences.dart';
import '../providers/preferences_provider.dart';

/// 全局偏好面板 —— 不绑定单篇文档
class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();
    final p = prefs.prefs;

    return Scaffold(
      appBar: AppBar(title: const Text('偏好设置')),
      body: prefs.loading || p == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _section('普通写作'),
                SwitchListTile(
                  title: const Text('自动首行缩进'),
                  subtitle: const Text('回车新建段落自动加两个全角空格；Shift+Enter 软换行不触发'),
                  value: p.autoIndent,
                  onChanged: (v) => prefs.updatePrefs((pp) => pp..autoIndent = v),
                ),
                _divider(),
                _section('排版预览'),
                SwitchListTile(
                  title: const Text('翻页动画'),
                  value: p.pageTurnAnimation,
                  onChanged: (v) => prefs.updatePrefs((pp) => pp..pageTurnAnimation = v),
                ),
                SwitchListTile(
                  title: const Text('隐藏翻页按钮'),
                  subtitle: const Text('本期仅支持底部翻页按钮，不支持点击翻页或键盘快捷键'),
                  value: p.hidePageTurnButton,
                  onChanged: (v) => prefs.updatePrefs((pp) => pp..hidePageTurnButton = v),
                ),
                _divider(),
                _section('App 启动入口'),
                SegmentedButton<HomeEntry>(
                  segments: const [
                    ButtonSegment(value: HomeEntry.drafts, label: Text('草稿箱')),
                    ButtonSegment(value: HomeEntry.published, label: Text('已发布展示页')),
                  ],
                  selected: {p.homeEntry},
                  onSelectionChanged: (s) =>
                      prefs.updatePrefs((pp) => pp..homeEntry = s.first),
                ),
                _divider(),
                _section('图片处理'),
                SwitchListTile(
                  title: const Text('图片压缩'),
                  subtitle: const Text('上传图片时自动压缩，节省本地存储空间'),
                  value: p.imageCompressEnabled,
                  onChanged: (v) => prefs.updatePrefs((pp) => pp..imageCompressEnabled = v),
                ),
                _divider(),
                _section('字数统计规则'),
                SegmentedButton<WordCountRule>(
                  segments: const [
                    ButtonSegment(value: WordCountRule.withFullWidthSpace, label: Text('含全角空格')),
                    ButtonSegment(value: WordCountRule.withoutSpace, label: Text('不含空格')),
                  ],
                  selected: {p.wordCountRule},
                  onSelectionChanged: (s) =>
                      prefs.updatePrefs((pp) => pp..wordCountRule = s.first),
                ),
                _divider(),
                _section('主题（预留）'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _themeChip(AppThemeMode.warmBrown, '暖棕米白', AppColors.warmBrown),
                      _themeChip(AppThemeMode.dark, '深色（待实现）', Colors.grey),
                      _themeChip(AppThemeMode.inkBlue, '墨蓝（待实现）', Colors.blueGrey),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('完成'),
                ),
              ],
            ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.warmBrown)),
      );

  Widget _divider() => const Divider(height: 1);

  Widget _themeChip(AppThemeMode mode, String label, Color color) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: false,
      onSelected: mode == AppThemeMode.warmBrown ? (_) {} : null,
    );
  }
}
