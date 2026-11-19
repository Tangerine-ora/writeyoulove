import 'dart:convert';

import '../models/document.dart';
import '../models/doc_mode.dart';
import '../db/app_db.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

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

/// 导出服务
class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  Future<String> exportTxt(Document doc) async => _extractPlain(doc);
  Future<String> exportMarkdown(Document doc) async => '# ${doc.title}\n\n${_extractPlain(doc)}';

  Future<String> exportHtmlPackage(Document doc) async {
    switch (doc.docMode) {
      case DocMode.normalWrite:
        try { return deltaToPlain(deltaFromJsonString(doc.rawTextContent)); } catch (_) { return doc.rawTextContent; }
      case DocMode.layout:
        return '''<!doctype html>
<html><head><meta charset="utf-8"/><title>${doc.title}</title>
<style>
page-setting{display:block;padding:24px;background:var(--bg,#FDF8F0);}
page-break{display:block;page-break-after:always;}
.wy-expand{cursor:pointer;border-bottom:1px dashed #8B5A2B;}
.wy-expand .wy-hidden{display:none;}
.wy-expand.open .wy-hidden{display:inline;}
.wy-shatter{cursor:pointer;transition:opacity .6s;}
.wy-shatter.shattered{opacity:0;letter-spacing:10px;}
</style></head><body>${doc.layoutContent}</body>
<script>
document.addEventListener('click',e=>{
  const exp=e.target.closest('.wy-expand');if(exp){exp.classList.toggle('open');return;}
  const sh=e.target.closest('.wy-shatter');if(sh){sh.classList.add('shattered');return;}
});
</script></html>''';
      case DocMode.developer:
        return doc.devContent;
    }
  }

  String _extractPlain(Document doc) {
    switch (doc.docMode) {
      case DocMode.normalWrite:
        try { return deltaToPlain(deltaFromJsonString(doc.rawTextContent)); } catch (_) { return doc.rawTextContent; }
      case DocMode.layout:
      case DocMode.developer:
        return _htmlToPlain(doc.getCurrentContent());
    }
  }

  String _htmlToPlain(String html) {
    var s = html;
    s = s.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    s = s.replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n');
    s = s.replaceAll(RegExp(r'<[^>]+>'), '');
    s = s.replaceAll('&nbsp;', ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.trim();
  }
}
