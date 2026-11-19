import 'package:isar/isar.dart';

part 'preferences.g.dart';

/// 全局偏好 —— 不绑定单篇文档
/// 单例存储（id 固定为 1）
@collection
class Preferences {
  Preferences({this.id = 1});

  Id id = 1;

  // ===== 普通写作 =====
  bool autoIndent = true;              // 自动首行缩进
  String defaultFontFamily = 'Noto Serif SC';
  double defaultFontSize = 16;

  // ===== 排版预览 =====
  bool pageTurnAnimation = true;       // 翻页动画
  @enumerated
  BgFillMode bgFillMode = BgFillMode.cover;
  bool hidePageTurnButton = false;     // 是否隐藏翻页按钮

  // ===== App 启动入口 =====
  @enumerated
  HomeEntry homeEntry = HomeEntry.drafts;

  // ===== 图片处理 =====
  bool imageCompressEnabled = true;

  // ===== 字数统计规则 =====
  @enumerated
  WordCountRule wordCountRule = WordCountRule.withFullWidthSpace;

  // ===== 主题（预留，当前只有 warmBrown）=====
  @enumerated
  AppThemeMode themeMode = AppThemeMode.warmBrown;
}

enum BgFillMode { cover, contain, repeat }
enum HomeEntry { drafts, published }
enum WordCountRule { withFullWidthSpace, withoutSpace }
enum AppThemeMode { warmBrown, dark, inkBlue }
