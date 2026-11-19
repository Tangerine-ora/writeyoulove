import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/document.dart';
import '../models/doc_mode.dart';
import '../providers/document_provider.dart';
import '../providers/draft_list_provider.dart';
import 'document_editor_router.dart';
import 'preferences_page.dart';
import 'published_page.dart';

/// 草稿箱列表
class DraftListPage extends StatefulWidget {
  const DraftListPage({super.key});

  @override
  State<DraftListPage> createState() => _DraftListPageState();
}

class _DraftListPageState extends State<DraftListPage> {
  final Set<String> _selected = {};
  bool _selectMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DraftListProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<DraftListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectMode ? '已选 ${_selected.length} 项' : '草稿箱'),
        actions: [
          if (_selectMode)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: '批量删除',
              onPressed: _selected.isEmpty
                  ? null
                  : () async {
                      await context.read<DraftListProvider>().deleteBatch(_selected.toList());
                      setState(() {
                        _selected.clear();
                        _selectMode = false;
                      });
                    },
            ),
          if (!_selectMode) ...[
            IconButton(
              icon: const Icon(Icons.public),
              tooltip: '已发布展示页',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PublishedPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: '偏好设置',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PreferencesPage()),
              ),
            ),
          ],
          if (_selectMode)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: '退出选择',
              onPressed: () => setState(() {
                _selected.clear();
                _selectMode = false;
              }),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewDocDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildSearchBar(),
          Expanded(
            child: list.loading
                ? const Center(child: CircularProgressIndicator())
                : list.docs.isEmpty
                    ? _buildEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: list.docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _buildDocCard(list.docs[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final list = context.watch<DraftListProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final double itemWidth = (constraints.maxWidth - 18) / 4; // 4 chips + 3 gaps
          return Row(
            children: [
              _filterChip('全部', list.modeFilter == null, () => list.setModeFilter(null), itemWidth),
              _filterChip('文本', list.modeFilter == DocMode.normalWrite, () => list.setModeFilter(DocMode.normalWrite), itemWidth),
              _filterChip('排版', list.modeFilter == DocMode.layout, () => list.setModeFilter(DocMode.layout), itemWidth),
              _filterChip('开发者', list.modeFilter == DocMode.developer, () => list.setModeFilter(DocMode.developer), itemWidth),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ChoiceChip(
          label: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1)),
          selected: selected,
          onSelected: (_) => onTap(),
          labelStyle: TextStyle(
            color: selected ? Colors.white : const Color(0xFF8B5A2B),
            fontSize: 13,
          ),
          selectedColor: const Color(0xFF8B5A2B),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFD7C4A8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final list = context.read<DraftListProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: TextField(
        decoration: const InputDecoration(hintText: '搜索标题或正文…', prefixIcon: Icon(Icons.search, size: 20), isDense: true),
        onChanged: list.setKeyword,
      ),
    );
  }

  Widget _buildDocCard(Document doc) {
    final selected = _selected.contains(doc.id);
    final color = switch (doc.docMode) {
      DocMode.normalWrite => const Color(0xFF8B5A2B),
      DocMode.layout => const Color(0xFFC89B5B),
      DocMode.developer => const Color(0xFF6C8E6A),
    };
    final icon = switch (doc.docMode) {
      DocMode.normalWrite => Icons.edit_note,
      DocMode.layout => Icons.picture_as_pdf,
      DocMode.developer => Icons.code,
    };

    return Card(
      color: selected ? const Color(0xFFF2E9DA) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: () {
          setState(() => _selectMode = true);
          _selected.add(doc.id);
        },
        onTap: () async {
          if (_selectMode) {
            setState(() {
              if (selected) {
                _selected.remove(doc.id);
                if (_selected.isEmpty) _selectMode = false;
              } else {
                _selected.add(doc.id);
              }
            });
          } else {
            await context.read<DocumentProvider>().load(doc.id);
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DocumentEditorRouter()),
            ).then((_) {
              if (mounted) context.read<DraftListProvider>().refresh();
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3E2723))),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: doc.isPublished ? Colors.green.withOpacity(0.15) : const Color(0xFFD7C4A8).withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                          child: Text(doc.isPublished ? '已发布' : '草稿', style: TextStyle(fontSize: 11, color: doc.isPublished ? Colors.green : const Color(0xFF795548))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_previewOf(doc), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Color(0xFF795548))),
                    const SizedBox(height: 4),
                    Text('${doc.modeLabel} · ${_fmtTime(doc.updatedAt)}', style: const TextStyle(fontSize: 11, color: Color(0xFF795548))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox, size: 64, color: Color(0xFFD7C4A8)),
          const SizedBox(height: 12),
          Text('没有草稿，点右下角 + 创建新文档', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  String _previewOf(Document doc) {
    switch (doc.docMode) {
      case DocMode.normalWrite:
        final t = doc.rawTextContent;
        return t.isNotEmpty ? t : '（空）';
      case DocMode.layout:
        return '排版模式 · ${doc.layoutContent.length} 字符';
      case DocMode.developer:
        return '开发者模式 · ${doc.devContent.length} 字符';
    }
  }

  String _fmtTime(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '今天 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.year}-${dt.month}-${dt.day}';
  }

  Future<void> _showNewDocDialog() async {
    final nameCtrl = TextEditingController();
    DocMode selected = DocMode.normalWrite;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text('新建文档'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '标题')),
              const SizedBox(height: 16),
              const Text('默认模式'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: DocMode.values
                    .map((m) => ChoiceChip(label: Text(m.label), selected: selected == m, onSelected: (_) => set(() => selected = m)))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final title = nameCtrl.text.trim().isEmpty ? '未命名文档' : nameCtrl.text.trim();
                await context.read<DocumentProvider>().createNew(title: title, docMode: selected);
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DocumentEditorRouter()),
                ).then((_) {
                  if (mounted) context.read<DraftListProvider>().refresh();
                });
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );
  }
}
