import 'package:flutter/foundation.dart';

import '../db/repositories/preferences_repository.dart';
import '../models/preferences.dart';

/// 全局偏好 Provider —— 应用启动时从 Isar 加载单例 Preferences
class PreferencesProvider with ChangeNotifier {
  Preferences? _prefs;
  bool _loading = true;

  Preferences? get prefs => _prefs;
  bool get loading => _loading;

  Future<void> load() async {
    _prefs = await PreferencesRepository.instance.get();
    _loading = false;
    notifyListeners();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    await load();
  }

  Future<void> updatePrefs(Preferences Function(Preferences p) updater) async {
    if (_prefs == null) await load();
    _prefs = updater(_prefs!);
    await PreferencesRepository.instance.save(_prefs!);
    notifyListeners();
  }

  // ===== 便捷访问 =====
  bool get autoIndent => _prefs?.autoIndent ?? true;
  bool get pageTurnAnimation => _prefs?.pageTurnAnimation ?? true;
  bool get hidePageTurnButton => _prefs?.hidePageTurnButton ?? false;
  HomeEntry get homeEntry => _prefs?.homeEntry ?? HomeEntry.drafts;
  WordCountRule get wordCountRule =>
      _prefs?.wordCountRule ?? WordCountRule.withFullWidthSpace;
}
