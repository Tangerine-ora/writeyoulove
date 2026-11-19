import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import '../models/component_template.dart';
import '../models/document.dart';
import '../models/preferences.dart';

/// Isar 单例 —— 应用启动时初始化
class AppDb {
  AppDb._();
  static Isar? _instance;

  static Future<Isar> get instance async {
    if (_instance != null) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [
        DocumentSchema,
        PreferencesSchema,
        ComponentTemplateSchema,
      ],
      directory: dir.path,
      name: AppConstants.dbName,
    );
    return _instance!;
  }

  static void reset() {
    _instance = null;
  }
}
