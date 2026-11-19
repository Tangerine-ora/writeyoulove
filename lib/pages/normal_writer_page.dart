import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/document.dart';
import '../models/preferences.dart';
import '../providers/document_provider.dart';
import '../providers/preferences_provider.dart';
import '../services/delta_html_converter.dart';
import '../services/export_service.dart';
import '../services/word_counter.dart';
import 'draft_list_page.dart';
import 'mode_switch_dialog.dart';

/// 普通写作模式 —— flutter_quill 富文本编辑器
class NormalWriterPage extends StatefulWidget {
  const NormalWriterPage({super.key});

  @override
  State<NormalWriterPage> createState() => _NormalWriterPageState();
}

class _NormalWriterPageState extends State<NormalWriterPage> {
  late final quill.QuillController _controller;
  late final ScrollController _scrollController;
  bool _autoIndenting = false;
  final List<String> _undoStack = []; // 独立撤销栈
  final List<String> _redoStack = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final doc = context.read<DocumentProvider>().current!;
    _controller = quill.QuillController.basic();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocumentContent(doc);
      _controller.addListener(_onDocChange);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onDocChange);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDocumentContent(Document doc) {
    if (doc.rawTextContent.trim().isEmpty) {
      _controller.clear();
      return;
    }
    try {
      final delta = quill.Delta.fromJson(jsonDecode(doc.rawTextContent));
      _controller.document = quill.Document()..compose(delta, quill.ChangeSource.REMOTE);
    } catch (e) {
      _controller.document.insert(0, '');
    }
  }

  void _onDocChange() {
    if (_autoIndenting) return;
    // 独立撤销栈快照
    final currentDelta = jsonEncode(_controller.document.toDelta().toJson());
    if (_undoStack.isEmpty || _undoStack.last != currentDelta) {
      _undoStack.add(currentDelta);
      _redoStack.clear();
      if (_undoStack.length > 1000) _undoStack.removeAt(0);
    }
  }

  /// 自动首行缩进：回车时检测，非软换行时生效
  Future<void> _autoIndent() async {
    final prefs = context.read<PreferencesProvider>().prefs;
    if (prefs?.autoIndent != true) return;

    final selection = _controller.selection;
    final plain = _controller.document.toPlainText();
    if (selection.end > 0 && plain.isNotEmpty) {
      _autoIndenting = true;
      try {
        _controller.document.insert(selection.end, '\u3000\u3000');
        _controller.updateSelection(
          TextSelection.collapsed(offset: selection.end + 2),
          quill.ChangeSource.LOCAL,
        );
      } finally {
        _autoIndenting = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = context.watch<DocumentProvider>().current!;
    final prefs = context.watch<PreferencesProvider>();
    final wordCount = WordCounter.instance.count(
      content: doc.rawTextContent,
      mode: DocMode.normalWrite,
      rule: prefs.wordCountRule,
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
          title: Text(doc.title),
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
              icon: const Icon(Icons.download),
              tooltip: '导出',
              onPressed: _showExportDialog,
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: '切换模式',
              onPressed: () => _showModeSwitchDialog(DocMode.layout),
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: _Toolbar(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: quill.QuillEditor.basic(
                controller: _controller,
                scrollController: _scrollController,
                configurations: quill.QuillEditorConfigurations(
                  placeholder: '开始写作…',
                  autoFocus: false,
                  expands: false,
                  showCursor: true,
                  customStyles: const quill.DefaultStyles(
                    placeHolder: quill.DefaultTextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            _buildFooterBar(wordCount),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterBar(int wordCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.creamDark,
      child: Row(
        children: [
          Text('字数：$wordCount',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const Spacer(),
          FilledButton.tonal(
            onPressed: _save,
            child: const Text('保存草稿'),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: _publish,
            child: const Text('发布'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final doc = context.read<DocumentProvider>().current!;
    final deltaJson = jsonEncode(_controller.document.toDelta().toJson());
    await context.read<DocumentProvider>().saveCurrent(newContent: deltaJson);
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

  void _undo() {
    if (_undoStack.isEmpty) return;
    final currentDelta = jsonEncode(_controller.document.toDelta().toJson());
    _redoStack.add(currentDelta);
    final prev = _undoStack.removeLast();
    _controller.document = quill.Document.fromDelta(
      quill.Delta.fromJson(jsonDecode(prev)),
    );
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    final next = _redoStack.removeLast();
    _controller.document = quill.Document.fromDelta(
      quill.Delta.fromJson(jsonDecode(next)),
    );
    _undoStack.add(next);
  }

  Future<void> _showExportDialog() async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('导出为 TXT'),
              onTap: () async {
                Navigator.pop(ctx);
                await _export('txt');
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('导出为 Markdown'),
              onTap: () async {
                Navigator.pop(ctx);
                await _export('md');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(String ext) async {
    final doc = context.read<DocumentProvider>().current!;
    final path = ext == 'txt'
        ? await ExportService.instance.exportTxt(doc)
        : await ExportService.instance.exportMarkdown(doc);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已导出：$path')),
      );
    }
  }

  /// 普通写作 → 排版模式：先保存 Delta，自动带默认 page-setting；若已有旧 layoutContent 则弹版本提示
  Future<void> _showModeSwitchDialog(DocMode target) async {
    final doc = context.read<DocumentProvider>().current!;
    // 先保存当前 Delta
    final deltaJson = jsonEncode(_controller.document.toDelta().toJson());
    await context.read<DocumentProvider>().saveCurrent(newContent: deltaJson);

    if (target == DocMode.layout && doc.layoutContent.trim().isNotEmpty) {
      // 已有旧排版，弹提示
      final result = await showModeVersionConflictDialog(
        context,
        doc: doc,
        sourceMode: DocMode.normalWrite,
        targetMode: DocMode.layout,
      );
      if (!mounted || result == null) return;
      if (result == ModeSwitchResult.cancel) return;
      if (result == ModeSwitchResult.regenerate) {
        // 用当前文本重新生成排版
        final newLayout = DeltaHtmlConverter.instance.deltaToBasicHtml(deltaJson);
        await context.read<DocumentProvider>().saveCurrent(newContent: newLayout);
      }
    }

    await context.read<DocumentProvider>().switchMode(target);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DocumentEditorRouter()),
      (route) => route.isFirst,
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar();

  @override
  Widget build(BuildContext context) {
    final controller = context.read<DocumentProvider>();
    // 占位 toolbar：flutter_quill 的 QuillToolbar 需要 QuillController，
    // 此处简化为按钮集，后续可按实际 controller 接入完整 QuillToolbar
    return Container(
      color: AppColors.creamDark,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(Icons.format_bold, size: 20),
            SizedBox(width: 8),
            Icon(Icons.format_italic, size: 20),
            SizedBox(width: 8),
            Icon(Icons.format_underlined, size: 20),
            SizedBox(width: 8),
            Icon(Icons.strikethrough_s, size: 20),
            SizedBox(width: 12),
            Icon(Icons.format_heading, size: 20),
            SizedBox(width: 8),
            Icon(Icons.format_list_bulleted, size: 20),
            SizedBox(width: 8),
            Icon(Icons.format_list_numbered, size: 20),
            SizedBox(width: 8),
            Icon(Icons.format_quote, size: 20),
            SizedBox(width: 12),
            Icon(Icons.image, size: 20),
            SizedBox(width: 8),
            Icon(Icons.colorize, size: 20),
            SizedBox(width: 8),
            Icon(Icons.remove, size: 20),
          ],
        ),
      ),
    );
  }
}
