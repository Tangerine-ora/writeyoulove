import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/document.dart';
import '../db/app_db.dart';
import '../models/component_template.dart';
import '../services/export_service.dart';
import 'mode_switch_dialog.dart';

/// 开发者模式 —— 左代码编辑区 + 右实时预览双栏
/// 自由编写原生 HTML；page-setting/page-break 不会自动解析生效
/// 只有此模式可编写/注册自定义组件模板
class DevEditorPage extends StatefulWidget {
  const DevEditorPage({super.key});

  @override
  State<DevEditorPage> createState() => _DevEditorPageState();
}

class _DevEditorPageState extends State<DevEditorPage> {
  late final TextEditingController _codeCtrl;
  late final WebViewController _previewCtrl;
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];
  bool _autoReload = true;

  @override
  void initState() {
    super.initState();
    final doc = context.read<DocumentProvider>().current!;
    _codeCtrl = TextEditingController(text: doc.devContent);
    _previewCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white);
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doc = context.watch<DocumentProvider>().current!;

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
          title: Text('开发者 · ${doc.title}'),
          actions: [
            IconButton(icon: const Icon(Icons.undo), tooltip: '撤销', onPressed: _undoStack.isNotEmpty ? _undo : null),
            IconButton(icon: const Icon(Icons.redo), tooltip: '重做', onPressed: _redoStack.isNotEmpty ? _redo : null),
            IconButton(icon: const Icon(Icons.refresh), tooltip: '刷新预览', onPressed: _reloadPreview),
            IconButton(icon: const Icon(Icons.widgets), tooltip: '组件模板库', onPressed: _showTemplateLibrary),
            IconButton(icon: const Icon(Icons.save_alt), tooltip: '导出原始 HTML', onPressed: _exportRawHtml),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  if (isWide) return _buildHorizontalSplit();
                  return _buildVerticalSplit();
                },
              ),
            ),
            _buildFooterBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalSplit() {
    return Row(
      children: [
        Expanded(child: _buildCodeEditor()),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(child: _buildPreview()),
      ],
    );
  }

  Widget _buildVerticalSplit() {
    return Column(
      children: [
        Expanded(child: _buildCodeEditor()),
        const Divider(height: 1, thickness: 1),
        Expanded(child: _buildPreview()),
      ],
    );
  }

  Widget _buildCodeEditor() {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _codeCtrl,
        maxLines: null,
        expands: true,
        style: const TextStyle(
          fontFamily: 'Consolas, Fira Code, monospace',
          fontSize: 13,
          color: Color(0xFFD4D4D4),
        ),
        decoration: InputDecoration(
          hintText: '<!doctype html>\n<html>\n  <head><title>原始 HTML</title></head>\n  <body>\n    自由编写 HTML…\n  </body>\n</html>',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
        ),
        onChanged: _onCodeChange,
      ),
    );
  }

  Widget _buildPreview() {
    return WebViewWidget(controller: _previewCtrl);
  }

  void _onCodeChange(String value) {
    if (_autoReload) _reloadPreview();
    if (_undoStack.isEmpty || _undoStack.last != value) {
      _undoStack.add(value);
      _redoStack.clear();
      if (_undoStack.length > 1000) _undoStack.removeAt(0);
    }
  }

  Future<void> _reloadPreview() async {
    final html = _codeCtrl.text.isEmpty ? '<p>空白</p>' : _codeCtrl.text;
    await _previewCtrl.loadRequest(
      Uri.dataFromString(
        html.startsWith('<!doctype') || html.startsWith('<html')
            ? html
            : '<!doctype html><html><head><meta charset="utf-8"/></head><body>$html</body></html>',
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ),
    );
  }

  Widget _buildFooterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.creamDark,
      child: Row(
        children: [
          Switch(
            value: _autoReload,
            onChanged: (v) => setState(() => _autoReload = v),
          ),
          const SizedBox(width: 4),
          const Text('实时预览', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 16),
          Text('${_codeCtrl.text.length} 字符',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const Spacer(),
          FilledButton.tonal(onPressed: _save, child: const Text('保存草稿')),
        ],
      ),
    );
  }

  Future<void> _save() async {
    await context.read<DocumentProvider>().saveCurrent(newContent: _codeCtrl.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存')),
      );
    }
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    final cur = _codeCtrl.text;
    _redoStack.add(cur);
    final prev = _undoStack.removeLast();
    _codeCtrl.text = prev;
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    final next = _redoStack.removeLast();
    _codeCtrl.text = next;
    _undoStack.add(next);
  }

  Future<void> _exportRawHtml() async {
    final doc = context.read<DocumentProvider>().current!;
    final path = await ExportService.instance.exportHtmlPackage(doc);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已导出：$path')),
      );
    }
  }

  /// 开发者模式独有：注册组件模板
  Future<void> _registerAsTemplate() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('注册为组件模板'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: '模板名称'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    // 校验：过滤 script / iframe
    final html = _codeCtrl.text;
    if (!validateTemplateHtml(html)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('模板非法：不得包含 script / iframe')),
      );
      return;
    }

    final db = await AppDb.instance;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.writeTxn(() async {
      await db.componentTemplates.put(ComponentTemplate(
        id: Isar.autoIncrement,
        name: name,
        htmlTemplate: html,
        createdAt: now,
      ));
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('模板已注册')),
      );
    }
  }

  /// 模板合法性校验：白名单标签，过滤 script/iframe
  static bool validateTemplateHtml(String html) {
    // 禁止标签
    for (final forbidden in AppConstants.forbiddenTags) {
      final re = RegExp('<$forbidden\\b', caseSensitive: false);
      if (re.hasMatch(html)) return false;
    }
    // 允许标签白名单（仅做提示性校验，不强制报错）
    return true;
  }

  Future<void> _showTemplateLibrary() async {
    final db = await AppDb.instance;
    final templates = await db.componentTemplates.where().findAll();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('组件模板库'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: templates.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(templates[i].name),
              subtitle: Text(templates[i].description),
              trailing: IconButton(
                icon: const Icon(Icons.insert_drive_file),
                tooltip: '插入到编辑器',
                onPressed: () {
                  _codeCtrl.text += '\n${templates[i].htmlTemplate}\n';
                  Navigator.pop(ctx);
                },
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
          TextButton(
            onPressed: _registerAsTemplate,
            child: const Text('把当前代码存为模板'),
          ),
        ],
      ),
    );
  }
}
