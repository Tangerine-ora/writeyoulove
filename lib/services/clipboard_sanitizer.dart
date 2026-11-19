import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../constants/app_constants.dart';
import 'delta_html_converter.dart';

/// 跨模式剪贴板清洗 —— 核心规则：
///   排版 → 排版：完整保留（不清洗）
///   排版 → 普通写作：剥离自定义标记，只留纯图文
///   普通写作 → 排版：纯文本→基础HTML
///   开发者模式：原样复制粘贴
class ClipboardSanitizer {
  ClipboardSanitizer._();
  static final ClipboardSanitizer instance = ClipboardSanitizer._();

  /// 根据源模式和目标模式决定清洗策略
  String sanitize({
    required String content,
    required DocMode from,
    required DocMode to,
  }) {
    // 同模式不清洗
    if (from == to) return content;

    switch (from) {
      case DocMode.layout:
        if (to == DocMode.normalWrite) {
          // 排版 → 普通写作：剥离自定义标记
          return DeltaHtmlConverter.instance.stripLayoutMarkers(content);
        }
        // 排版 → 开发者：原样
        return content;

      case DocMode.normalWrite:
        if (to == DocMode.layout) {
          // 普通写作 → 排版：纯 Delta → 基础 HTML
          return DeltaHtmlConverter.instance.deltaToBasicHtml(content);
        }
        // 普通写作 → 开发者：把 Delta 解析成纯文本
        return _deltaToPlainText(content);

      case DocMode.developer:
        // 开发者 → 任何模式：原样（开发者原生 HTML 由用户自己负责）
        return content;
    }
  }

  String _deltaToPlainText(String deltaJson) {
    try {
      final doc = quill.Document.fromJson(
        _tryDecode(deltaJson) as Map<String, dynamic>,
      );
      return doc.toPlainText();
    } catch (e) {
      return deltaJson;
    }
  }

  Object? _tryDecode(String s) {
    try {
      return const JsonDecoder().convert(s);
    } catch (_) {
      return null;
    }
  }
}
