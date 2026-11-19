/// 全局偏好 —— 不绑定单篇文档
class Preferences {
  Preferences();

  // ===== 普通写作 =====
  bool autoIndent = true;
  String defaultFontFamily = 'Noto Serif SC';
  double defaultFontSize = 16;

  // ===== 排版预览 =====
  bool pageTurnAnimation = true;
  String bgFillMode = 'cover'; // cover / contain / repeat
  bool hidePageTurnButton = false;

  // ===== App 启动入口 =====
  String homeEntry = 'drafts'; // drafts / published

  // ===== 图片处理 =====
  bool imageCompressEnabled = true;

  // ===== 字数统计规则 =====
  String wordCountRule = 'withFullWidthSpace'; // withFullWidthSpace / withoutSpace

  // ===== 主题（预留）=====
  String themeMode = 'warmBrown';

  Map<String, dynamic> toMap() => {
        'autoIndent': autoIndent,
        'defaultFontFamily': defaultFontFamily,
        'defaultFontSize': defaultFontSize,
        'pageTurnAnimation': pageTurnAnimation,
        'bgFillMode': bgFillMode,
        'hidePageTurnButton': hidePageTurnButton,
        'homeEntry': homeEntry,
        'imageCompressEnabled': imageCompressEnabled,
        'wordCountRule': wordCountRule,
        'themeMode': themeMode,
      };

  factory Preferences.fromMap(Map<String, dynamic> m) {
    final p = Preferences();
    p.autoIndent = m['autoIndent'] as bool? ?? true;
    p.defaultFontFamily = m['defaultFontFamily'] as String? ?? 'Noto Serif SC';
    p.defaultFontSize = (m['defaultFontSize'] as num?)?.toDouble() ?? 16;
    p.pageTurnAnimation = m['pageTurnAnimation'] as bool? ?? true;
    p.bgFillMode = m['bgFillMode'] as String? ?? 'cover';
    p.hidePageTurnButton = m['hidePageTurnButton'] as bool? ?? false;
    p.homeEntry = m['homeEntry'] as String? ?? 'drafts';
    p.imageCompressEnabled = m['imageCompressEnabled'] as bool? ?? true;
    p.wordCountRule = m['wordCountRule'] as String? ?? 'withFullWidthSpace';
    p.themeMode = m['themeMode'] as String? ?? 'warmBrown';
    return p;
  }
}
