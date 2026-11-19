import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/repositories/document_repository.dart';
import '../models/document.dart';
import '../models/doc_mode.dart';
import '../providers/document_provider.dart';
import '../providers/draft_list_provider.dart';
import 'document_editor_router.dart';
import 'preferences_page.dart';
import 'published_page.dart';

/// 草稿箱列表（含个人主页视图，可来回切换）
class DraftListPage extends StatefulWidget {
  final bool openProfile;

  const DraftListPage({super.key, this.openProfile = false});

  @override
  State<DraftListPage> createState() => _DraftListPageState();
}

class _DraftListPageState extends State<DraftListPage> {
  final Set<String> _selected = {};
  bool _selectMode = false;
  bool _showProfile = false;
  List<Document> _publishedDocs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DraftListProvider>().refresh();
      if (widget.openProfile) _switchToProfile();
    });
  }

  Future<void> _switchToProfile() async {
    final docs = await DocumentRepository.instance.listAll(isPublished: true);
    if (!mounted) return;
    setState(() {
      _publishedDocs = docs.where((d) => d.docMode == DocMode.layout).toList();
      _showProfile = true;
      _selectMode = false;
      _selected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<DraftListProvider>();

    // ====== 个人主页视图 ======
    if (_showProfile) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDF8F0),
        body: PublishedView(
          docs: _publishedDocs,
          onSwitchBack: () => setState(() => _showProfile = false),
        ),
      );
    }

    // ====== 草稿箱视图 ======
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _selectMode ? Text('已选 ${_selected.length} 项') : null,
        centerTitle: false,
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
            // 筛选 + 搜索
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: '筛选与搜索',
              onPressed: _showFilterSheet,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: '偏好设置',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PreferencesPage()),
              ),
            ),
            // 头像 → 个人主页
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 2),
              child: GestureDetector(
                onTap: _switchToProfile,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF8B5A2B),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
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
        onPressed: _showNewModeSheet,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildActiveFilterChip(),
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

  // =====================================
  // 筛选：当前激活筛选 Chip + 点击弹 BottomSheet
  // =====================================

  Widget _buildActiveFilterChip() {
    final list = context.watch<DraftListProvider>();
    final chips = <Widget>[];
    if (list.modeFilter != null) {
      chips.add(_activeChip('筛选：${list.modeFilter!.label}', () => list.setModeFilter(null)));
    }
    if (list.keyword.trim().isNotEmpty) {
      chips.add(_activeChip('搜索：${list.keyword.trim()}', () => list.setKeyword('')));
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Wrap(spacing: 8, runSpacing: 6, children: chips),
    );
  }

  Widget _activeChip(String text, VoidCallback onClear) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5A2B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF8B5A2B))),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 14, color: Color(0xFF8B5A2B)),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterSheet() async {
    final list = context.read<DraftListProvider>();
    final current = list.modeFilter;
    final kwCtrl = TextEditingController(text: list.keyword);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Text('筛选与搜索', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3E2723))),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    controller: kwCtrl,
                    decoration: const InputDecoration(
                      hintText: '搜索标题或正文…',
                      prefixIcon: Icon(Icons.search, size: 20),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: list.setKeyword,
                  ),
                ),
                _filterOption('全部', null, current, Icons.all_inclusive),
                _filterOption('文本模式', DocMode.normalWrite, current, Icons.edit_note),
                _filterOption('排版模式', DocMode.layout, current, Icons.picture_as_pdf),
                _filterOption('开发者模式', DocMode.developer, current, Icons.code),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filterOption(String label, DocMode? mode, DocMode? current, IconData icon) {
    final selected = mode == current;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8B5A2B) : const Color(0xFF8B5A2B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: selected ? Colors.white : const Color(0xFF8B5A2B), size: 20),
      ),
      title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      trailing: selected ? const Icon(Icons.check, color: Color(0xFF8B5A2B)) : null,
      onTap: () {
        context.read<DraftListProvider>().setModeFilter(mode);
        Navigator.pop(context);
      },
    );
  }

  // =====================================
  // 新建：先弹模式 → 再弹标题
  // =====================================

  Future<void> _showNewModeSheet() async {
    final picked = await showModalBottomSheet<DocMode>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Text('选择创作模式', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3E2723))),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              _modeOption(DocMode.normalWrite, Icons.edit_note, '纯文本写作', '适合写小说、散文、日常稿'),
              _modeOption(DocMode.layout, Icons.picture_as_pdf, '排版可视化', 'WebView 所见即所得，支持分页'),
              _modeOption(DocMode.developer, Icons.code, '开发者模式', '手写原生 HTML，完全可控'),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (picked == null || !mounted) return;
    await _showNewTitleDialog(picked);
  }

  Widget _modeOption(DocMode mode, IconData icon, String title, String subtitle) {
    final color = switch (mode) {
      DocMode.normalWrite => const Color(0xFF8B5A2B),
      DocMode.layout => const Color(0xFFC89B5B),
      DocMode.developer => const Color(0xFF6C8E6A),
    };
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF795548))),
      onTap: () => Navigator.pop(context, mode),
    );
  }

  Future<void> _showNewTitleDialog(DocMode mode) async {
    final nameCtrl = TextEditingController();
    final color = switch (mode) {
      DocMode.normalWrite => const Color(0xFF8B5A2B),
      DocMode.layout => const Color(0xFFC89B5B),
      DocMode.developer => const Color(0xFF6C8E6A),
    };

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('输入标题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('模式：${mode.label}', style: TextStyle(fontSize: 12, color: color)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '文档标题',
                hintText: '未命名文档',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _createAndClose(ctx, nameCtrl, mode),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: color),
            onPressed: () => _createAndClose(ctx, nameCtrl, mode),
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<void> _createAndClose(BuildContext ctx, TextEditingController nameCtrl, DocMode mode) async {
    Navigator.pop(ctx);
    if (!mounted) return;
    final title = nameCtrl.text.trim().isEmpty ? '未命名文档' : nameCtrl.text.trim();
    await context.read<DocumentProvider>().createNew(title: title, docMode: mode);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DocumentEditorRouter()),
    ).then((_) {
      if (mounted) context.read<DraftListProvider>().refresh();
    });
  }

  // =====================================
  // 卡片 / 空态 / 工具方法
  // =====================================

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
}
