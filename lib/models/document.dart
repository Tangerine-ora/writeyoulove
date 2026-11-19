import 'doc_mode.dart';

/// 单篇文档 —— 三套独立内容，永远互不覆盖
class Document {
  Document({
    required this.id,
    required this.title,
    required this.docMode,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;

  /// 文档标题
  String title;

  /// 当前生效模式：切换模式时只改这个值，三套内容都保留
  DocMode docMode;

  /// ===== 三套独立内容 =====
  /// 普通写作模式（Quill Delta JSON 字符串）
  String rawTextContent = '';

  /// 排版可视化模式（带 page-setting / page-break / 交互 class 的 HTML）
  String layoutContent = '';

  /// 开发者模式原始 HTML
  String devContent = '';

  /// 是否已发布
  bool isPublished = false;

  /// 缩略图路径（排版模式存第一页快照）
  String? thumbnailPath;

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

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'docMode': docMode.name,
        'rawTextContent': rawTextContent,
        'layoutContent': layoutContent,
        'devContent': devContent,
        'isPublished': isPublished,
        'thumbnailPath': thumbnailPath,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory Document.fromMap(Map<String, dynamic> m) => Document(
        id: m['id'] as String,
        title: m['title'] as String,
        docMode: DocModeX.fromString(m['docMode'] as String),
        createdAt: m['createdAt'] as int,
        updatedAt: m['updatedAt'] as int,
      )
        ..rawTextContent = m['rawTextContent'] as String? ?? ''
        ..layoutContent = m['layoutContent'] as String? ?? ''
        ..devContent = m['devContent'] as String? ?? ''
        ..isPublished = m['isPublished'] as bool? ?? false
        ..thumbnailPath = m['thumbnailPath'] as String?;
}
