import 'package:isar/isar.dart';

part 'document.g.dart';

/// 文档模式，对应三套独立内容
enum DocMode { normalWrite, layout, developer }

/// 单篇文档 —— 三套内容独立存储，互不覆盖
@collection
class Document {
  Document({
    required this.id,
    required this.title,
    required this.docMode,
    required this.createdAt,
    required this.updatedAt,
  });

  Id id;

  /// 文档标题
  String title;

  /// 当前生效模式：切换模式时只改这个值，三套内容都保留
  @enumerated
  DocMode docMode;

  /// ===== 三套独立内容，永远互不覆盖 =====
  /// 普通写作模式（Quill Delta JSON 字符串）
  String rawTextContent = '';

  /// 排版可视化模式（带 page-setting / page-break / 交互 class 的 HTML）
  String layoutContent = '';

  /// 开发者模式原始 HTML
  String devContent = '';

  /// ===== 排版元信息（可选）=====
  /// 排版模式每页独立背景配置 JSON（同 layoutContent 同步，加速渲染）
  String pageSettingsJson = '';

  /// 是否已发布
  bool isPublished = false;

  /// 字数（冗余缓存，每次保存时更新）
  int wordCount = 0;

  /// 缩略图路径（排版模式存第一页快照）
  String? thumbnailPath;

  /// 关联的图片资源路径列表（JSON 数组）
  String assetPathsJson = '[]';

  int createdAt;
  int updatedAt;

  // ===== 便捷方法 =====
  String getCurrentContent() {
    switch (docMode) {
      case DocMode.normalWrite:
        return rawTextContent;
      case DocMode.layout:
        return layoutContent;
      case DocMode.developer:
        return devContent;
    }
  }

  void setCurrentContent(String content) {
    switch (docMode) {
      case DocMode.normalWrite:
        rawTextContent = content;
      case DocMode.layout:
        layoutContent = content;
      case DocMode.developer:
        devContent = content;
    }
    updatedAt = DateTime.now().millisecondsSinceEpoch;
  }

  String get modeLabel {
    switch (docMode) {
      case DocMode.normalWrite:
        return '文本';
      case DocMode.layout:
        return '排版';
      case DocMode.developer:
        return '开发者';
    }
  }
}
