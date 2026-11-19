import 'dart:convert';

import 'package:dart_quill_delta/dart_quill_delta.dart';

import '../models/document.dart';
import '../models/doc_mode.dart';

/// 纯文本 Delta 转换
String deltaToPlain(Delta delta) {
  final buffer = StringBuffer();
  for (final op in delta.toJson()) {
    if (op is Map<String, dynamic>) {
      final insert = op['insert'];
      if (insert is String) buffer.write(insert);
    }
  }
  return buffer.toString();
}

Delta deltaFromJsonString(String json) {
  final ops = jsonDecode(json);
  final list = ops is List ? ops : (ops as Map<String, dynamic>)['ops'] as List<dynamic>? ?? [];
  return Delta.fromJson(list);
}

/// 字数统计
class WordCounter {
  WordCounter._();
  static final WordCounter instance = WordCounter._();

  int count({required String content, required DocMode mode, String rule = 'withFullWidthSpace'}) {
    final plain = _extractPlainText(content, mode);
    switch (rule) {
      case 'withoutSpace':
        return plain.replaceAll(RegExp(r'[\s\u3000]+'), '').runes.length;
      default:
        return plain.runes.length;
    }
  }

  String _extractPlainText(String content, DocMode mode) {
    switch (mode) {
      case DocMode.normalWrite:
        try {
          return deltaToPlain(deltaFromJsonString(content));
        } catch (_) {
          return content;
        }
      case DocMode.layout:
      case DocMode.developer:
        return _htmlToPlain(content);
    }
  }

  String _htmlToPlain(String html) {
    var s = html;
    s = s.replaceAll(RegExp(r'<page-setting\b[^>]*/?>.*?</page-setting>', caseSensitive: false, dotAll: true), '');
    s = s.replaceAll(RegExp(r'<page-setting\b[^>]*/>', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'<page-break\b[^>]*/?>.*?</page-break>', caseSensitive: false, dotAll: true), '');
    s = s.replaceAll(RegExp(r'<page-break\b[^>]*/>', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'<script\b[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '');
    s = s.replaceAll(RegExp(r'<[^>]+>'), '');
    s = s.replaceAll('&nbsp;', ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.trim();
  }

  List<int> countPerPage(String layoutHtml, String rule) {
    final pages = _splitPages(layoutHtml);
    return pages.map((p) => count(content: p, mode: DocMode.layout, rule: rule)).toList();
  }

  List<String> _splitPages(String html) {
    final splitBy = RegExp(r'(?=<page-setting\b|<page-break\b)', caseSensitive: false);
    final parts = html.split(splitBy).where((s) => s.trim().isNotEmpty).toList();
    return parts.isEmpty ? [html] : parts;
  }
}
