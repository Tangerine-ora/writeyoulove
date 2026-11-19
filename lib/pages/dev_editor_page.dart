import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/app_constants.dart';
import '../db/app_db.dart';
import '../models/component_template.dart';
import '../models/document.dart';
import '../providers/document_provider.dart';

/// 开发者模式 —— 左代码编辑区 + 右实时预览
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
            IconButton(icon: const Icon(Icons.refresh), tooltip: '刷新预览', onPressed: _reloadPreview),
            IconButton(icon: const Icon(Icons.widgets), tooltip: '组件模板库', onPressed: _showTemplateLibrary),
            IconButton(icon: const Icon(Icons.save_alt), tooltip: '注册为模板', onPressed: _registerAsTemplate),
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
            _FooterBar(
              autoReload: _autoReload,
              onAutoReloadChanged: (v) => setState(() => _autoReload = v),
              charCount: _codeCtrl.text.length,
              onSave: _save,
            ),
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
        Expanded(child: WebViewWidget(controller: _previewCtrl)),
      ],
    );
  }

  Widget _buildVerticalSplit() {
    return Column(
      children: [
        Expanded(child: _buildCodeEditor()),
        const Divider(height: 1, thickness: 1),
        Expanded(child: WebViewWidget(controller: _previewCtrl)),
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
        style: const TextStyle(fontFamily: 'Consolas, Fira Code, monospace', fontSize: 13, color: Color(0xFFD4D4D4)),
        decoration: InputDecoration(
          hintText: '<!doctype html>\n<html>\n  <body>\n    自由编写 HTML…\n  </body>\n</html>',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
        ),
        onChanged: _onCodeChange,
      ),
    );
  }

  void _onCodeChange(String value) {
    if (_autoReload) _reloadPreview();
    if (_undoStack.isEmpty || _undoStack.last != value) {
      _undoStack.add(value);
      _redoStack.clear();
    }
  }

  Future<void> _reloadPreview() async {
    final html = _codeCtrl.text.isEmpty ? '<p>空白</p>' : _codeCtrl.text;
    final wrapped = html.startsWith('<!doctype') || html.startsWith('<html')
        ? html
        : '<!doctype html><html><head><meta charset="utf-8"/></head><body>$html</body></html>';
    await _previewCtrl.loadRequest(
      Uri.dataFromString(wrapped, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')),
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

  /// 注册当前代码为组件模板（过滤 script/iframe）
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

    final html = _codeCtrl.text;
    if (!validateTemplateHtml(html)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('模板非法：不得包含 script / iframe')),
      );
      return;
    }

    final db = AppDb.instance;
    final now = DateTime.now().millisecondsSinceEpoch;
    final templates = await db.loadTemplates();
    templates.add(ComponentTemplate(
      id: 'template_${now}_${templates.length}',
      name: name,
      htmlTemplate: html,
      createdAt: now,
    ));
    await db.saveAllTemplates(templates);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('模板已注册')),
      );
    }
  }

  static bool validateTemplateHtml(String html) {
    for (final forbidden in AppConstants.forbiddenTags) {
      final re = RegExp('<$forbidden\\b', caseSensitive: false);
      if (re.hasMatch(html)) return false;
    }
    return true;
  }

  Future<void> _showTemplateLibrary() async {
    final templates = await AppDb.instance.loadTemplates();
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
                tooltip: '插入',
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
        ],
      ),
    );
  }
}

class _FooterBar extends StatelessWidget {
  final bool autoReload;
  final ValueChanged<bool> onAutoReloadChanged;
  final int charCount;
  final VoidCallback onSave;
  const _FooterBar({
    required this.autoReload,
    required this.onAutoReloadChanged,
    required this.charCount,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: const Color(0xFFF2E9DA),
      child: Row(
        children: [
          Switch(value: autoReload, onChanged: onAutoReloadChanged),
          const SizedBox(width: 4),
          const Text('实时预览', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 16),
          Text('$charCount 字符', style: const TextStyle(fontSize: 12, color: Color(0xFF795548))),
          const Spacer(),
          FilledButton.tonal(onPressed: onSave, child: const Text('保存草稿')),
        ],
      ),
    );
  }
}
