import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../constants/app_constants.dart';

/// Delta (JSON string) ↔ HTML 转换器
/// 负责：普通写作 ↔ 排版模式 的内容互转
///
/// 关键约束（来自 ExperienceRecall 100023031）：
///  - matcher 只做最小增量修改，禁止覆盖原 delta
///  - 自定义排版标记（page-setting / page-break / 交互 class）只在 layoutContent 中保留
///  - 从 HTML 导入普通写作时必须清洗掉所有自定义标记
class DeltaHtmlConverter {
  DeltaHtmlConverter._();
  static final DeltaHtmlConverter instance = DeltaHtmlConverter._();

  // ======================== Delta → HTML（用于 普通写作 → 排版模式）========================

  /// Quill Delta JSON 字符串 → 纯 HTML（用于初始生成排版内容的基础）
  /// 输出不包含任何 page-setting / page-break / 交互 class，只做基础图文转换
  String deltaToBasicHtml(String deltaJson) {
    if (deltaJson.trim().isEmpty) return '';
    try {
      final doc = quill.Document.fromJson(jsonDecode(deltaJson) as Map<String, dynamic>);
      final buffer = StringBuffer();
      final plainHtml = doc.toHtml();
      // doc.toHtml() 输出的是 Quill 默认 HTML，可能带 <p>/<h1> 等
      return _wrapWithDefaultPageSetting(plainHtml);
    } catch (e) {
      // 兜底：当作纯文本处理
      return _wrapWithDefaultPageSetting('<p>${_escapeHtml(deltaJson)}</p>');
    }
  }

  /// 给 HTML 包一层默认米白背景 page-setting
  String _wrapWithDefaultPageSetting(String innerHtml) {
    return '''
<page-setting bg="${AppConstants.defaultBgColor}" bg-mode="cover"></page-setting>
$innerHtml
'''.trim();
  }

  // ======================== HTML → Delta（用于 排版模式 → 普通写作）========================

  /// 清洗排版 HTML → 纯 Quill 可读的 HTML → 转 Delta JSON
  /// 剥离所有自定义标记，只保留基础图文
  String layoutHtmlToDelta(String layoutHtml) {
    final cleanedHtml = stripLayoutMarkers(layoutHtml);
    try {
      final delta = _parseHtmlToDelta(cleanedHtml);
      return jsonEncode(delta.toJson());
    } catch (e) {
      return jsonEncode(quill.Delta()..insert(cleanedHtml));
    }
  }

  // ======================== 核心：标记剥离 ========================

  /// 移除排版自定义标记，输出纯 HTML（用于排版→普通写作、跨模式剪贴板）
  String stripLayoutMarkers(String html) {
    var result = html;

    // 1. 移除 <page-setting .../> 或 <page-setting>...</page-setting>
    result = result.replaceAll(
      RegExp(r'<page-setting\b[^>]*/?>.*?</page-setting>', caseSensitive: false, dotAll: true),
      '',
    );
    result = result.replaceAll(
      RegExp(r'<page-setting\b[^>]*/>', caseSensitive: false),
      '',
    );

    // 2. 移除 <page-break/> 或 <page-break>
    result = result.replaceAll(
      RegExp(r'<page-break\b[^>]*/?>.*?</page-break>', caseSensitive: false, dotAll: true),
      '',
    );
    result = result.replaceAll(
      RegExp(r'<page-break\b[^>]*/>', caseSensitive: false),
      '',
    );

    // 3. 移除交互 class 包裹的外层标签，但保留内部文字
    result = result.replaceAllMapped(
      RegExp(
        r"<(\w+)\b[^>]*class\s*=\s*[""'][^""']*(wy-expand|wy-shatter|wy-pagebreak)[^""']*[""'][^>]*>(.*?)</\1>",
        caseSensitive: false,
        dotAll: true,
      ),
      (m) => m.group(3) ?? '',
    );

    // 4. 移除 data-hidden / data-* 等交互属性（保留标签）
    result = result.replaceAll(
      RegExp(r"\s+data-[a-z-]+\s*=\s*[""'][^""']*[""']", caseSensitive: false),
      '',
    );

    // 5. 过滤 script / iframe
    result = result.replaceAll(
      RegExp(r'<script\b[^>]*>.*?</script>', caseSensitive: false, dotAll: true),
      '',
    );
    result = result.replaceAll(
      RegExp(r'<iframe\b[^>]*>.*?</iframe>', caseSensitive: false, dotAll: true),
      '',
    );

    return result.trim();
  }

  // ======================== HTML → Delta（简易解析器）========================
  // 不依赖 quill_html_editor 之类的重包，自己实现一个轻量解析器
  // 处理：p/h1-h6/strong/em/u/s/img/br/blockquote/ul/ol/li

  quill.Delta _parseHtmlToDelta(String html) {
    final delta = quill.Delta();
    final segments = _htmlToSegments(html);
    for (final seg in segments) {
      delta.insert(seg.text, seg.attrs);
    }
    return delta;
  }

  List<_HtmlSegment> _htmlToSegments(String html) {
    final result = <_HtmlSegment>[];
    final tokenPattern = RegExp(r'<(\/?)(\w+)([^>]*)>');
    int cursor = 0;
    final openTagStack = <String>[];
    final attrsStack = <Map<String, dynamic>>[];
    attrsStack.add({});

    while (cursor < html.length) {
      final match = tokenPattern.firstMatch(html.substring(cursor));
      if (match == null) {
        // 剩余全部当作文本
        result.add(_HtmlSegment(html.substring(cursor), _mergeAttrs(attrsStack)));
        break;
      }
      final start = match.start + cursor;
      final end = match.end + cursor;

      // 标签前的文本
      if (start > cursor) {
        result.add(_HtmlSegment(html.substring(cursor, start), _mergeAttrs(attrsStack)));
      }

      final isClosing = match.group(1) == '/';
      final tag = (match.group(2) ?? '').toLowerCase();
      final attrsRaw = match.group(3) ?? '';
      final isSelfClosing = attrsRaw.contains('/');

      if (_isBlockTag(tag)) {
        // 块级标签：先 flush 当前 attrs + 换行
        if (result.isNotEmpty && result.last.text.isNotEmpty && !result.last.text.endsWith('\n')) {
          result.add(_HtmlSegment('\n', {}));
        }
        if (!isClosing) {
          final style = _tagToBlockAttr(tag);
          if (style != null) {
            attrsStack.last.addAll(style);
          }
          openTagStack.add(tag);
        } else {
          openTagStack.removeLast();
          attrsStack.last.removeWhere((k, _) =>
              k == 'header' || k == 'blockquote' || k == 'list' || k == 'indent');
        }
      } else if (_isInlineTag(tag)) {
        if (!isClosing && !isSelfClosing) {
          openTagStack.add(tag);
          attrsStack.last.addAll(_tagToInlineAttr(tag));
        } else if (isClosing) {
          openTagStack.removeLast();
          attrsStack.last.removeWhere((k, _) =>
              k == 'bold' || k == 'italic' || k == 'underline' || k == 'strike');
        }
      } else if (tag == 'img') {
        // 图片：暂按文本占位处理，后续 flutter_quill 的 image embed 可接管
        result.add(_HtmlSegment('[图片]', _mergeAttrs(attrsStack)));
      } else if (tag == 'br') {
        result.add(_HtmlSegment('\n', {}));
      }

      cursor = end;
    }

    // 尾部换行
    if (result.isNotEmpty && result.last.text.isNotEmpty && !result.last.text.endsWith('\n')) {
      result.add(_HtmlSegment('\n', {}));
    }

    return result;
  }

  Map<String, dynamic> _mergeAttrs(List<Map<String, dynamic>> stack) {
    final merged = <String, dynamic>{};
    for (final m in stack) {
      merged.addAll(m);
    }
    return merged;
  }

  bool _isBlockTag(String t) =>
      {'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'blockquote', 'ul', 'ol'}.contains(t);
  bool _isInlineTag(String t) => {'strong', 'b', 'em', 'i', 'u', 's', 'span'}.contains(t);

  Map<String, dynamic>? _tagToBlockAttr(String tag) {
    switch (tag) {
      case 'h1':
        return {'header': 1};
      case 'h2':
        return {'header': 2};
      case 'h3':
        return {'header': 3};
      case 'blockquote':
        return {'blockquote': true};
      case 'ul':
        return {'list': 'bullet'};
      case 'ol':
        return {'list': 'ordered'};
      default:
        return null;
    }
  }

  Map<String, dynamic> _tagToInlineAttr(String tag) {
    switch (tag) {
      case 'strong':
      case 'b':
        return {'bold': true};
      case 'em':
      case 'i':
        return {'italic': true};
      case 'u':
        return {'underline': true};
      case 's':
        return {'strike': true};
      default:
        return {};
    }
  }

  String _escapeHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

class _HtmlSegment {
  final String text;
  final Map<String, dynamic> attrs;
  _HtmlSegment(this.text, this.attrs);
}
