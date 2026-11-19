import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/document.dart';
import '../providers/document_provider.dart';
import '../services/export_service.dart';
import '../services/word_counter.dart';
import 'mode_switch_dialog.dart';
import 'preview_page.dart';

/// 排版可视化模式 —— WebView 内嵌 Tiptap/Lexical 风格编辑器
/// 所有底层 HTML 封装为按钮/弹窗/滑块，用户看不到代码
class LayoutEditorPage extends StatefulWidget {
  const LayoutEditorPage({super.key});

  @override
  State<LayoutEditorPage> createState() => _LayoutEditorPageState();
}

class _LayoutEditorPageState extends State<LayoutEditorPage> {
  late final WebViewController _controller;
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];
  bool _showSourceView = false;
  final TextEditingController _sourceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final doc = context.read<DocumentProvider>().current!;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.creamWhite)
      ..enableZoom(false)
      ..loadFlutterAsset('assets/web/layout_editor.html');
  }

  Future<void> _injectContent() async {
    final doc = context.read<DocumentProvider>().current!;
    await _controller.runJavaScript(
      'window.__WY_LOAD_CONTENT__(${jsonEncode(doc.layoutContent)});',
    );
  }

  Future<String?> _fetchContent() async {
    final result = await _controller.runJavaScriptReturningResult(
      'window.__WY_GET_CONTENT__ && window.__WY_GET_CONTENT__() || "";',
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
              icon: const Icon(Icons.undo),
              tooltip: '撤销',
              onPressed: _undoStack.isNotEmpty ? _undo : null,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              tooltip: '重做',
              onPressed: _redoStack.isNotEmpty ? _redo : null,
            ),
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
              tooltip: '切换模式',
              onPressed: () => _showModeSwitchDialog(DocMode.normalWrite),
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
            _buildFooterBar(perPage),
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

  Widget _buildFooterBar(List<int> perPage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.creamDark,
      child: Row(
        children: [
          Text('共 ${perPage.length} 页 · 逐页字数：${perPage.join('/')}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const Spacer(),
          FilledButton.tonal(onPressed: _save, child: const Text('保存草稿')),
          const SizedBox(width: 8),
          FilledButton.tonal(onPressed: _publish, child: const Text('发布')),
          const SizedBox(width: 8),
          FilledButton.tonal(onPressed: _exportHtml, child: const Text('导出')),
        ],
      ),
    );
  }

  void _onToolbarAction(String action) {
    // 把操作派发到 WebView JS Bridge
    _controller.runJavaScript('window.__WY_TOOLBAR_ACTION__("$action");');
  }

  Future<void> _save() async {
    final content = await _fetchContent();
    if (content != null) {
      await context.read<DocumentProvider>().saveCurrent(newContent: content);
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
    final doc = context.read<DocumentProvider>().current!;
    final path = await ExportService.instance.exportHtmlPackage(doc);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已导出：$path')),
      );
    }
  }

  void _undo() {} // TODO: JS Bridge 调用 WebView 内部 undo
  void _redo() {}

  Future<void> _preview() async {
    await _save();
    if (!mounted) return;
    final doc = context.read<DocumentProvider>().current!;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewPage(doc: doc)),
    );
  }

  /// 排版模式 → 普通写作：提示排版标记失效；清洗 HTML 后转 Delta
  Future<void> _showModeSwitchDialog(DocMode target) async {
    final confirmed = await showLayoutToNormalSwitchDialog(context);
    if (!confirmed) return;

    // 清洗 HTML → Delta
    final content = await _fetchContent();
    if (content != null) {
      final deltaJson = _cleanLayoutToDelta(content);
      await context.read<DocumentProvider>().saveCurrent(newContent: deltaJson);
    }
    await context.read<DocumentProvider>().switchMode(target);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DocumentEditorRouter()),
      (route) => route.isFirst,
    );
  }

  String _cleanLayoutToDelta(String layoutHtml) {
    // 移除 page-setting / page-break / 交互 class，只留基础 HTML
    final cleaned = _stripLayoutMarkers(layoutHtml);
    // 再把 HTML 粗略转 Quill Delta —— 简化版用纯文本
    return _htmlToDeltaJson(cleaned);
  }

  String _stripLayoutMarkers(String html) {
    var s = html;
    s = s.replaceAll(RegExp(r'<page-setting\b[^>]*/?>.*?</page-setting>', caseSensitive: false, dotAll: true), '');
    s = s.replaceAll(RegExp(r'<page-setting\b[^>]*/>', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'<page-break\b[^>]*/?>.*?</page-break>', caseSensitive: false, dotAll: true), '');
    s = s.replaceAll(RegExp(r'<page-break\b[^>]*/>', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'<script\b[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '');
    s = s.replaceAll(RegExp(r'<iframe\b[^>]*>.*?</iframe>', caseSensitive: false, dotAll: true), '');
    s = s.replaceAll(RegExp(r"\s+class\s*=\s*[""'][^""']*(wy-expand|wy-shatter|wy-pagebreak)[^""']*[""']", caseSensitive: false), '');
    return s.trim();
  }

  String _htmlToDeltaJson(String html) {
    final plain = html
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    // 构造最简 Delta：插入纯文本
    return jsonEncode({'ops': [{'insert': '$plain\n'}]});
  }
}

/// 可视化工具栏 —— 所有底层操作封装为按钮
class _VisualToolbar extends StatelessWidget {
  final void Function(String action) onAction;
  const _VisualToolbar({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.creamDark,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _tbtn(Icons.add_box, '插入空白页', 'insert-page'),
            _tbtn(Icons.copy, '复制当前页', 'duplicate-page'),
            _tbtn(Icons.delete, '删除当前页', 'delete-page'),
            const SizedBox(width: 12),
            _tbtn(Icons.image, '背景设置', 'bg-setting'),
            _tbtn(Icons.layers, '页面层级', 'z-layer'),
            const SizedBox(width: 12),
            _tbtn(Icons.unfold_more, '点击展开隐藏文本', 'comp-expand'),
            _tbtn(Icons.broken_image, '点击文字碎裂', 'comp-shatter'),
            _tbtn(Icons.navigate_next, '插入翻页锚点', 'comp-pagebreak'),
            const SizedBox(width: 12),
            _tbtn(Icons.text_fields, '文字衬底', 'text-bg'),
            _tbtn(Icons.auto_awesome_motion, '翻页动画', 'page-animation'),
          ],
        ),
      ),
    );
  }

  Widget _tbtn(IconData icon, String label, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: () => onAction(action),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 22, color: AppColors.warmBrown),
          ),
        ),
      ),
    );
  }
}
