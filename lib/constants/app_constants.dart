/// 全局常量：标记名称、默认值、交互 class 等
class AppConstants {
  AppConstants._();

  // ===== 排版 HTML 自定义标记 =====
  static const String tagPageSetting = 'page-setting';   // 单页背景配置 <page-setting bg="..." bg-mode="cover">
  static const String tagPageBreak = 'page-break';       // 分页锚点 <page-break/>
  static const String attrBgColor = 'bg';                // 背景色
  static const String attrBgImage = 'bg-image';           // 背景图 URL
  static const String attrBgMode = 'bg-mode';            // cover / contain / repeat

  // ===== 交互组件 class =====
  static const String classExpand = 'wy-expand';         // 点击展开隐藏文本
  static const String classShatter = 'wy-shatter';       // 点击文字碎裂
  static const String classPageBreakRef = 'wy-pagebreak'; // 跳转翻页锚点
  static const String attrHiddenInitially = 'data-hidden';

  // ===== 默认值 =====
  static const String defaultBgColor = '#FDF8F0';        // 米白色
  static const String defaultFontFamily = 'Noto Serif SC';
  static const double defaultFontSize = 16;
  static const double defaultLineHeight = 1.75;

  // ===== 过滤白名单：开发者模式自定义模板 =====
  static const Set<String> allowedTagsInTemplate = {
    'div', 'span', 'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
    'img', 'br', 'hr', 'ul', 'ol', 'li', 'blockquote',
    'strong', 'em', 'u', 's', 'sub', 'sup',
    'table', 'thead', 'tbody', 'tr', 'td', 'th',
    'font', 'b', 'i', 'big', 'small',
    tagPageSetting, tagPageBreak,
  };
  static const Set<String> forbiddenTags = {'script', 'iframe', 'object', 'embed', 'link', 'style'};

  // ===== Isar 数据库名 =====
  static const String dbName = 'writeyoulove_db';

  // ===== 偏好持久化 key =====
  static const String prefKeyAutoIndent = 'auto_indent';
  static const String prefKeyDefaultFont = 'default_font';
  static const String prefKeyDefaultFontSize = 'default_font_size';
  static const String prefKeyPageTurnAnimation = 'page_turn_animation';
  static const String prefKeyBgFillMode = 'bg_fill_mode';
  static const String prefKeyHidePageTurnBtn = 'hide_page_turn_btn';
  static const String prefKeyHomeEntry = 'home_entry';
  static const String prefKeyImageCompress = 'image_compress';
  static const String prefKeyWordCountRule = 'word_count_rule';
  static const String prefKeyThemeMode = 'theme_mode';
}

/// 填充模式
enum BgFillMode { cover, contain, repeat }

/// 应用入口
enum HomeEntry { drafts, published }

/// 字数统计规则
enum WordCountRule { withFullWidthSpace, withoutSpace }
