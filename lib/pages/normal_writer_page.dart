import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
import '../models/doc_mode.dart';
import '../providers/document_provider.dart';
import '../providers/preferences_provider.dart';
import '../services/delta_html_converter.dart';
import '../services/export_service.dart' hide deltaFromJsonString, deltaToPlain;
import '../services/word_counter.dart' show WordCounter, deltaFromJsonString, deltaToPlain;
import 'document_editor_router.dart';
import 'mode_switch_dialog.dart';

/// 普通写作模式 —— flutter_quill 富文本编辑器
class NormalWriterPage extends StatefulWidget {
  const NormalWriterPage({super.key});
  @override
  State<NormalWriterPage> createState() => _NormalWriterPageState();
}

class _NormalWriterPageState extends State<NormalWriterPage> {
  late final quill.QuillController _controller;
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];

  @override
  void initState() {
    super.initState();
    _controller = quill.QuillController.basic();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocumentContent();
      _controller.addListener(_onDocChange);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onDocChange);
    _controller.dispose();
    super.dispose();
  }

  void _loadDocumentContent() {
    final doc = context.read<DocumentProvider>().current!;
    if (doc.rawTextContent.trim().isEmpty) return;
    try {
      final delta = deltaFromJsonString(doc.rawTextContent);
      // quill 11.x 使用 QuillDocument 避免和我们的 Document 模型冲突
      final quillDoc = quill.Document.fromDelta(delta);
      _controller.document = quillDoc;
    } catch (_) {
      _controller.clear();
    }
  }

  void _onDocChange() {
    final currentDelta = jsonEncode(_controller.document.toDelta().toJson());
    if (_undoStack.isEmpty || _undoStack.last != currentDelta) {
      _undoStack.add(currentDelta);
      _redoStack.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = context.watch<DocumentProvider>().current!;
    final prefs = context.watch<PreferencesProvider>();
    final wordCount = WordCounter.instance.count(content: doc.rawTextContent, mode: DocMode.normalWrite, rule: prefs.wordCountRule);

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
            IconButton(icon: const Icon(Icons.undo), tooltip: '撤销', onPressed: _undoStack.isNotEmpty ? _undo : null),
            IconButton(icon: const Icon(Icons.redo), tooltip: '重做', onPressed: _redoStack.isNotEmpty ? _redo : null),
            IconButton(icon: const Icon(Icons.swap_horiz), tooltip: '切换到排版模式', onPressed: _showModeSwitchToLayout),
          ],
        ),
        body: Column(
          children: [
            quill.QuillSimpleToolbar(controller: _controller),
            Expanded(child: quill.QuillEditor.basic(controller: _controller)),
            _FooterBar(wordCount: wordCount),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final deltaJson = jsonEncode(_controller.document.toDelta().toJson());
    await context.read<DocumentProvider>().saveCurrent(newContent: deltaJson);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
    }
  }

  Future<void> _publish() async {
    await _save();
    await context.read<DocumentProvider>().publish(publish: true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已发布')));
    }
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    final currentDelta = jsonEncode(_controller.document.toDelta().toJson());
    _redoStack.add(currentDelta);
    final prev = _undoStack.removeLast();
    final delta = deltaFromJsonString(prev);
    _controller.document = quill.Document.fromDelta(delta);
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    final next = _redoStack.removeLast();
    final delta = deltaFromJsonString(next);
    _controller.document = quill.Document.fromDelta(delta);
    _undoStack.add(next);
  }

  Future<void> _showModeSwitchToLayout() async {
    final doc = context.read<DocumentProvider>().current!;
    final deltaJson = jsonEncode(_controller.document.toDelta().toJson());
    await context.read<DocumentProvider>().saveCurrent(newContent: deltaJson);

    if (doc.layoutContent.trim().isNotEmpty) {
      final result = await showModeVersionConflictDialog(context);
      if (!mounted || result == null) return;
      if (result == ModeSwitchResult.cancel) return;
      if (result == ModeSwitchResult.regenerate) {
        final newLayout = DeltaHtmlConverter.instance.deltaToBasicHtml(deltaJson);
        await context.read<DocumentProvider>().saveCurrent(newContent: newLayout);
      }
    }

    await context.read<DocumentProvider>().switchMode(DocMode.layout);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DocumentEditorRouter()),
      (route) => route.isFirst,
    );
  }
}

class _FooterBar extends StatelessWidget {
  final int wordCount;
  const _FooterBar({required this.wordCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: const Color(0xFFF2E9DA),
      child: Row(
        children: [
          Text('字数：$wordCount', style: const TextStyle(fontSize: 12, color: Color(0xFF795548))),
          const Spacer(),
          FilledButton.tonal(onPressed: () async {
            final state = context.findAncestorStateOfType<_NormalWriterPageState>();
            await state?._save();
          }, child: const Text('保存')),
          const SizedBox(width: 8),
          FilledButton.tonal(onPressed: () async {
            final state = context.findAncestorStateOfType<_NormalWriterPageState>();
            await state?._publish();
          }, child: const Text('发布')),
        ],
      ),
    );
  }
}
