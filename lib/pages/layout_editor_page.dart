import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/document.dart';
import '../models/doc_mode.dart';
import '../providers/document_provider.dart';
import '../providers/preferences_provider.dart';
import '../services/export_service.dart';
import '../services/word_counter.dart';
import 'document_editor_router.dart';
import 'mode_switch_dialog.dart';
import 'preview_page.dart';

/// 排版可视化模式 —— WebView 内嵌编辑器
class LayoutEditorPage extends StatefulWidget {
  const LayoutEditorPage({super.key});

  @override
  State<LayoutEditorPage> createState() => _LayoutEditorPageState();
}

class _LayoutEditorPageState extends State<LayoutEditorPage> {
  late final WebViewController _controller;
  bool _showSourceView = false;
  final TextEditingController _sourceCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final doc = context.read<DocumentProvider>().current!;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFDF8F0))
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) async {
          await _injectContent();
          _initialized = true;
        }),
      )
      ..loadFlutterAsset('assets/web/layout_editor.html');
    _sourceCtrl.text = doc.layoutContent;
  }

  Future<void> _injectContent() async {
    final doc = context.read<DocumentProvider>().current!;
    await _controller.runJavaScript(
      'window.__WY_LOAD_CONTENT__(${jsonEncode(doc.layoutContent)});',
    );
  }

  Future<String?> _fetchContent() async {
    final result = await _controller.runJavaScriptReturningResult(
      'window.__WY_GET_CONTENT__ ? window.__WY_GET_CONTENT__() : "";',
    );
    return result?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final doc = context.watch<DocumentProvider>().current!;
    final prefs = context.watch<PreferencesProvider>();
    final perPage = WordCounter.instance.countPerPage(
      doc.layoutContent,
      prefs.wordCountRule,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _save();
        if (!mounted) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('排版 · ${doc.title}'),
          actions: [
            IconButton(
              icon: Icon(_showSourceView ? Icons.visibility : Icons.code),
              tooltip: _showSourceView ? '返回可视化' : '查看源码',
              onPressed: () => setState(() => _showSourceView = !_showSourceView),
            ),
            IconButton(
              icon: const Icon(Icons.remove_red_eye),
              tooltip: '预览',
              onPressed: _preview,
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: '切换到普通写作',
              onPressed: () => _showSwitchToNormal(),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: _VisualToolbar(onAction: _onToolbarAction),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _showSourceView
                  ? _buildSourceView()
                  : WebViewWidget(controller: _controller),
            ),
            _FooterBar(perPage: perPage, onSave: _save, onPublish: _publish, onExport: _exportHtml),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceView() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _sourceCtrl,
        maxLines: null,
        expands: true,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        decoration: const InputDecoration(
          hintText: '微调源码，新手推荐用可视化编辑器',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _onToolbarAction(String action) {
    _controller.runJavaScript('window.__WY_TOOLBAR_ACTION__("$action");');
  }

  Future<void> _save() async {
    if (_showSourceView) {
      await context.read<DocumentProvider>().saveCurrent(newContent: _sourceCtrl.text);
    } else {
      final content = await _fetchContent();
      if (content != null) {
        await context.read<DocumentProvider>().saveCurrent(newContent: content);
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存')),
      );
    }
  }

  Future<void> _publish() async {
    await _save();
    await context.read<DocumentProvider>().publish(publish: true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已发布')),
      );
    }
  }

  Future<void> _exportHtml() async {
    await _save();
    final doc = context.read<DocumentProvider>().current!;
    final html = await ExportService.instance.exportHtmlPackage(doc);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('HTML 已生成：${html.length} 字符')),
      );
    }
  }

  Future<void> _preview() async {
    await _save();
    if (!mounted) return;
    final doc = context.read<DocumentProvider>().current!;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewPage(doc: doc)),
    );
  }

  Future<void> _showSwitchToNormal() async {
    final confirmed = await showLayoutToNormalSwitchDialog(context);
    if (!confirmed) return;
    final content = await _fetchContent();
    if (content != null) {
      final cleaned = _stripMarkers(content);
      final plainHtml = cleaned.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
      final deltaJson = jsonEncode({'ops': [{'insert': '$plainHtml\n'}]});
      await context.read<DocumentProvider>().saveCurrent(newContent: deltaJson);
    }
    await context.read<DocumentProvider>().switchMode(DocMode.normalWrite);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DocumentEditorRouter()),
      (route) => route.isFirst,
    );
  }

  String _stripMarkers(String html) {
    var s = html;
    s = s.replaceAll(RegExp(r'<page-setting\b[^>]*/?>.*?</page-setting>', caseSensitive: false, dotAll: true), '');
    s = s.replaceAll(RegExp(r'<page-setting\b[^>]*/>', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'<page-break\b[^>]*/?>.*?</page-break>', caseSensitive: false, dotAll: true), '');
    s = s.replaceAll(RegExp(r'<page-break\b[^>]*/>', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'<script\b[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '');
    s = s.replaceAll(RegExp(r'<iframe\b[^>]*>.*?</iframe>', caseSensitive: false, dotAll: true), '');
    return s.trim();
  }
}

class _FooterBar extends StatelessWidget {
  final List<int> perPage;
  final VoidCallback onSave;
  final VoidCallback onPublish;
  final VoidCallback onExport;
  const _FooterBar({required this.perPage, required this.onSave, required this.onPublish, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: const Color(0xFFF2E9DA),
      child: Row(
        children: [
          Text('共 ${perPage.length} 页',
              style: const TextStyle(fontSize: 12, color: Color(0xFF795548))),
          const Spacer(),
          FilledButton.tonal(onPressed: onSave, child: const Text('保存')),
          const SizedBox(width: 8),
          FilledButton.tonal(onPressed: onPublish, child: const Text('发布')),
          const SizedBox(width: 8),
          FilledButton.tonal(onPressed: onExport, child: const Text('导出')),
        ],
      ),
    );
  }
}

class _VisualToolbar extends StatelessWidget {
  final void Function(String action) onAction;
  const _VisualToolbar({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2E9DA),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _btn(Icons.add_box, '插入空白页', 'insert-page'),
            _btn(Icons.copy, '复制当前页', 'duplicate-page'),
            _btn(Icons.delete, '删除当前页', 'delete-page'),
            const SizedBox(width: 12),
            _btn(Icons.image, '背景设置', 'bg-setting'),
            _btn(Icons.layers, '页面层级', 'z-layer'),
            const SizedBox(width: 12),
            _btn(Icons.unfold_more, '点击展开', 'comp-expand'),
            _btn(Icons.broken_image, '文字碎裂', 'comp-shatter'),
            _btn(Icons.navigate_next, '翻页锚点', 'comp-pagebreak'),
            const SizedBox(width: 12),
            _btn(Icons.text_fields, '文字衬底', 'text-bg'),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, String label, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: () => onAction(action),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 22, color: const Color(0xFF8B5A2B)),
          ),
        ),
      ),
    );
  }
}
