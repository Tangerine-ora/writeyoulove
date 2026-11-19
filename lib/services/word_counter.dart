import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../models/preferences.dart';
import '../constants/app_constants.dart';

/// 字数统计
class WordCounter {
  WordCounter._();
  static final WordCounter instance = WordCounter._();

  /// 统计 Delta / 纯文本 / HTML 的字数
  int count({
    required String content,
    required DocMode mode,
    WordCountRule rule = WordCountRule.withFullWidthSpace,
  }) {
    final plain = _extractPlainText(content, mode);
    switch (rule) {
      case WordCountRule.withFullWidthSpace:
        // 含全角空格：直接数 rune
        return plain.runes.length;
      case WordCountRule.withoutSpace:
        // 不含空格：过滤掉空格再数
        return plain.replaceAll(RegExp(r'[\s\u3000]+'), '').runes.length;
    }
  }

  String _extractPlainText(String content, DocMode mode) {
    switch (mode) {
      case DocMode.normalWrite:
        try {
          final doc = quill.Document.fromJson(
            jsonDecode(content) as Map<String, dynamic>,
          );
          return doc.toPlainText();
        } catch (_) {
          return content;
        }
      case DocMode.layout:
      case DocMode.developer:
        // 简易 HTML 转纯文本
        return _htmlToPlainText(content);
    }
  }

  String _htmlToPlainText(String html) {
    // 剥离排版自定义标记
    var s = html;
    s = s.replaceAll(RegExp(r'<page-setting\b[^>]*/?>.*?</page-setting>', caseSensitive: false, dotAll: true), '');
    s = s.replaceAll(RegExp(r'<page-setting\b[^>]*/>', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'<page-break\b[^>]*/?>.*?</page-break>', caseSensitive: false, dotAll: true), '');
    s = s.replaceAll(RegExp(r'<page-break\b[^>]*/>', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'<script\b[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '');
    s = s.replaceAll(RegExp(r'<[^>]+>', ''));
    s = s.replaceAll('&nbsp;', ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.trim();
  }

  /// 排版模式：逐页字数统计
  /// 按 <page-break> 或 <page-setting> 切分页
  List<int> countPerPage(String layoutHtml, WordCountRule rule) {
    final pages = _splitPages(layoutHtml);
    return pages.map((p) => count(content: p, mode: DocMode.layout, rule: rule)).toList();
  }

  List<String> _splitPages(String html) {
    // 先把 page-setting 也当作分页标记
    final splitBy = RegExp(
      r'(?=<page-setting\b|<page-break\b)',
      caseSensitive: false,
    );
    final parts = html.split(splitBy).where((s) => s.trim().isNotEmpty).toList();
    return parts.isEmpty ? [html] : parts;
  }
}
