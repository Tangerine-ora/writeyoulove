import '../models/document.dart';
import 'delta_html_converter.dart';

/// 跨模式剪贴板清洗
class ClipboardSanitizer {
  ClipboardSanitizer._();
  static final ClipboardSanitizer instance = ClipboardSanitizer._();

  String sanitize({
    required String content,
    required DocMode from,
    required DocMode to,
  }) {
    if (from == to) return content;

    switch (from) {
      case DocMode.layout:
        if (to == DocMode.normalWrite) {
          return DeltaHtmlConverter.instance.stripLayoutMarkers(content);
        }
        return content;

      case DocMode.normalWrite:
        if (to == DocMode.layout) {
          return DeltaHtmlConverter.instance.deltaToBasicHtml(content);
        }
        return content;

      case DocMode.developer:
        return content;
    }
  }
}
