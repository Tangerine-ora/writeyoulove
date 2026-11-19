import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/document.dart';
import '../models/doc_mode.dart';
import '../providers/draft_list_provider.dart';
import '../providers/preferences_provider.dart';

/// 已发布展示页 —— 排版阅读，逻辑与预览页一致，无编辑入口
class PublishedPage extends StatefulWidget {
  const PublishedPage({super.key});

  @override
  State<PublishedPage> createState() => _PublishedPageState();
}

class _PublishedPageState extends State<PublishedPage> {
  Document? _currentDoc;
  WebViewController? _controller;
  int _currentPage = 0;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DraftListProvider>().setPublishedFilter(true);
    });
  }

  Future<void> _openDoc(Document doc) async {
    setState(() {
      _currentDoc = doc;
      _currentPage = 0;
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFFDF8F0))
        ..loadFlutterAsset('assets/web/preview.html')
        ..setNavigationDelegate(
          NavigationDelegate(onPageFinished: (_) async {
            await _controller!.runJavaScript(
              'window.__WY_PREVIEW_LOAD__(${jsonEncode(doc.layoutContent)}, true);',
            );
            final count = await _controller!.runJavaScriptReturningResult('window.__WY_PAGE_COUNT__ || 1');
            setState(() => _totalPages = int.tryParse(count?.toString() ?? '1') ?? 1);
          }),
        );
    });
  }

  Future<void> _goPage(int idx) async {
    if (_controller == null) return;
    if (idx < 0 || idx >= _totalPages) return;
    setState(() => _currentPage = idx);
    await _controller!.runJavaScript('window.__WY_GO_PAGE__($idx);');
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<DraftListProvider>();
    final prefs = context.watch<PreferencesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('已发布'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.inbox),
            tooltip: '回到草稿箱',
            onPressed: () {
              context.read<DraftListProvider>().setPublishedFilter(null);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: _currentDoc == null
          ? _buildPublishedList(list)
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (!prefs.hidePageTurnButton) _buildPageTurnBar(),
              ],
            ),
    );
  }

  Widget _buildPublishedList(DraftListProvider list) {
    final published = list.docs.where((d) => d.isPublished && d.docMode == DocMode.layout).toList();
    if (published.isEmpty) {
      return const Center(child: Text('暂无已发布的排版作品'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: published.length,
      itemBuilder: (_, i) {
        final doc = published[i];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openDoc(doc),
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Color(0xFF8B5A2B)),
              title: Text(doc.title),
              subtitle: Text('${doc.modeLabel} · ${_fmtTime(doc.updatedAt)}'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageTurnBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: _currentPage > 0 ? () => _goPage(_currentPage - 1) : null),
              Text('${_currentPage + 1} / $_totalPages'),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: _currentPage < _totalPages - 1 ? () => _goPage(_currentPage + 1) : null),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtTime(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
