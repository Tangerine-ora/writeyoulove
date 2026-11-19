import 'dart:convert';
import 'dart:io';

import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:path_provider/path_provider.dart';

import '../models/document.dart';
import '../constants/app_constants.dart';
import 'delta_html_converter.dart';

/// 导出服务：TXT / Markdown / HTML 压缩包 / PDF / 图片快照
class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  Future<String> exportTxt(Document doc) async {
    final plain = _extractPlain(doc);
    final path = await _makeExportPath(doc, 'txt');
    await File(path).writeAsString(plain, encoding: utf8);
    return path;
  }

  Future<String> exportMarkdown(Document doc) async {
    final md = _toMarkdown(doc);
    final path = await _makeExportPath(doc, 'md');
    await File(path).writeAsString(md, encoding: utf8);
    return path;
  }

  Future<String> exportHtmlPackage(Document doc) async {
    // 排版模式：带交互 HTML + 资源文件夹，打成 ZIP
    // 本期先输出单体 HTML，ZIP 打包后续迭代
    final html = _resolveContent(doc);
    final path = await _makeExportPath(doc, 'html');
    await File(path).writeAsString(html, encoding: utf8);
    return path;
  }

  // ========= 辅助 =========
  String _resolveContent(Document doc) {
    switch (doc.docMode) {
      case DocMode.normalWrite:
        try {
          final d = quill.Document.fromJson(jsonDecode(doc.rawTextContent) as Map<String, dynamic>);
          return '<!doctype html><html><head><meta charset="utf-8"/><title>${doc.title}</title></head><body>${d.toHtml()}</body></html>';
        } catch (_) {
          return '<!doctype html><html><body>${doc.rawTextContent}</body></html>';
        }
      case DocMode.layout:
        return '''<!doctype html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width"/>
<title>${doc.title}</title>
<style>
page-setting { display: block; padding: 24px; min-height: 80vh; }
page-break { display: block; page-break-after: always; }
.wy-expand { cursor: pointer; border-bottom: 1px dashed #8B5A2B; }
.wy-expand .hidden { display: none; }
.wy-expand.open .hidden { display: inline; }
.wy-shatter { cursor: pointer; transition: opacity .6s; }
.wy-shatter.shattered { opacity: 0; letter-spacing: 10px; }
</style>
</head>
<body>${doc.layoutContent}</body>
<script>
document.addEventListener('click', e => {
  const exp = e.target.closest('.wy-expand');
  if (exp) { exp.classList.toggle('open'); return; }
  const sh = e.target.closest('.wy-shatter');
  if (sh) { sh.classList.add('shattered'); const next = sh.nextElementSibling; if (next) next.style.display='inline'; return; }
});
document.querySelectorAll('.wy-shatter + *').forEach(n => n.style.display = 'none');
</script>
</html>''';
      case DocMode.developer:
        return doc.devContent;
    }
  }

  String _extractPlain(Document doc) {
    switch (doc.docMode) {
      case DocMode.normalWrite:
        try {
          final d = quill.Document.fromJson(jsonDecode(doc.rawTextContent) as Map<String, dynamic>);
          return d.toPlainText();
        } catch (_) {
          return doc.rawTextContent;
        }
      case DocMode.layout:
      case DocMode.developer:
        return _htmlToPlain(doc.getCurrentContent());
    }
  }

  String _toMarkdown(Document doc) {
    // 简单实现：排版 HTML 先清洗再转 Markdown 近似
    final plain = _extractPlain(doc);
    return '# ${doc.title}\n\n$plain';
  }

  String _htmlToPlain(String html) {
    var s = DeltaHtmlConverter.instance.stripLayoutMarkers(html);
    s = s.replaceAll(RegExp(r'<[^>]+>'), '');
    s = s.replaceAll('&nbsp;', ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.trim();
  }

  Future<String> _makeExportPath(Document doc, String ext) async {
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) await exportDir.create(recursive: true);
    final safeTitle = doc.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return '${exportDir.path}/${safeTitle}_${doc.id}.$ext';
  }
}
