import 'dart:convert';

import 'package:dart_quill_delta/dart_quill_delta.dart';

import '../constants/app_constants.dart';
import '../models/doc_mode.dart';

/// Delta (JSON string) ↔ HTML 转换器
class DeltaHtmlConverter {
  DeltaHtmlConverter._();
  static final DeltaHtmlConverter instance = DeltaHtmlConverter._();

  // ======================== Delta → HTML ========================

  String deltaToBasicHtml(String deltaJson) {
    if (deltaJson.trim().isEmpty) return '';
    try {
      final ops = jsonDecode(deltaJson);
      final list = ops is List ? ops : (ops as Map<String, dynamic>)['ops'] as List<dynamic>? ?? [];
      final plain = _deltaToPlain(Delta.fromJson(list));
      final paragraphs = plain.split('\n').where((p) => p.isNotEmpty).map((p) => '<p>${_escapeHtml(p)}</p>').join('\n');
      return _wrapWithDefaultPageSetting(paragraphs);
    } catch (e) {
      return _wrapWithDefaultPageSetting('<p>${_escapeHtml(deltaJson)}</p>');
    }
  }

  /// Delta → 纯文本（dart_quill_delta 10.x 没有 toPlainText，自己遍历 ops）
  String _deltaToPlain(Delta delta) {
    final buffer = StringBuffer();
    final ops = delta.toJson();
    for (final op in ops) {
      if (op is Map<String, dynamic>) {
        final insert = op['insert'];
        if (insert is String) buffer.write(insert);
      }
    }
    return buffer.toString();
  }

  String _wrapWithDefaultPageSetting(String innerHtml) {
    return '''
<page-setting bg="${AppConstants.defaultBgColor}" bg-mode="cover"></page-setting>
$innerHtml
'''.trim();
  }

  // ======================== HTML → Delta ========================

  String layoutHtmlToDelta(String layoutHtml) {
    final cleanedHtml = stripLayoutMarkers(layoutHtml);
    final plain = _htmlToPlain(cleanedHtml);
    final delta = Delta()..insert('$plain\n');
    return jsonEncode(delta.toJson());
  }

  // ======================== 标记剥离 ========================

  String stripLayoutMarkers(String html) {
    var result = html;
    result = result.replaceAll(RegExp(r'<page-setting\b[^>]*/?>.*?</page-setting>', caseSensitive: false, dotAll: true), '');
    result = result.replaceAll(RegExp(r'<page-setting\b[^>]*/>', caseSensitive: false), '');
    result = result.replaceAll(RegExp(r'<page-break\b[^>]*/?>.*?</page-break>', caseSensitive: false, dotAll: true), '');
    result = result.replaceAll(RegExp(r'<page-break\b[^>]*/>', caseSensitive: false), '');
    result = result.replaceAllMapped(
      RegExp(r"<(\w+)\b[^>]*class\s*=\s*[""'][^""]*(wy-expand|wy-shatter|wy-pagebreak)[^""]*[""][^>]*>(.*?)</\1>", caseSensitive: false, dotAll: true),
      (Match m) => m.group(3) ?? '',
    );
    result = result.replaceAll(RegExp(r"\s+data-[a-z-]+\s*=\s*[""'][^""]*[""']", caseSensitive: false), '');
    result = result.replaceAll(RegExp(r'<script\b[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '');
    result = result.replaceAll(RegExp(r'<iframe\b[^>]*>.*?</iframe>', caseSensitive: false, dotAll: true), '');
    return result.trim();
  }

  String _htmlToPlain(String html) {
    var s = html;
    s = s.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    s = s.replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n');
    s = s.replaceAll(RegExp(r'</h[1-6]\s*>', caseSensitive: false), '\n');
    s = s.replaceAll(RegExp(r'<[^>]+>'), '');
    s = s.replaceAll('&nbsp;', ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.trim();
  }

  String _escapeHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
