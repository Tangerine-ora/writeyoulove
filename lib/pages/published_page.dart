import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/document.dart';
import '../models/doc_mode.dart';
import '../providers/draft_list_provider.dart';
import '../providers/preferences_provider.dart';
import 'preview_page.dart';

/// 已发布展示页 —— 错踪卡片墙 + 仅底部翻页，无编辑入口
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
  final Random _random = Random(42); // 固定种子，保证每次渲染错位一致

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
              'window.__WY_PREVIEW_LOAD__(${doc.layoutContent}, true);',
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

    // ====== 正在阅读某篇 ======
    if (_currentDoc != null && _controller != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            WebViewWidget(controller: _controller!),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  right: 8,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => setState(() => _currentDoc = null),
                    ),
                    Expanded(
                      child: Text(
                        _currentDoc!.title,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!prefs.hidePageTurnButton) _buildPageTurnBar(),
          ],
        ),
      );
    }

    // ====== 发布墙：错踪卡片 ======
    final published = list.docs.where((d) => d.isPublished && d.docMode == DocMode.layout).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '已发布',
          style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.w600, fontSize: 18),
        ),
        foregroundColor: const Color(0xFF8B5A2B),
        actions: [
          // 搜索
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('搜索功能待实现')),
              );
            },
          ),
          // 圆形头像 + 切换回编辑
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                context.read<DraftListProvider>().setPublishedFilter(null);
                Navigator.of(context).pop();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5A2B),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: published.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book, size: 64, color: Color(0xFFD7C4A8)),
                  SizedBox(height: 12),
                  Text('暂无已发布的排版作品', style: TextStyle(color: Color(0xFF795548))),
                ],
              ),
            )
          : _buildStaggeredWall(published),
    );
  }

  // ============= 错踪卡片墙 =============

  Widget _buildStaggeredWall(List<Document> docs) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final crossCount = constraints.maxWidth > 600 ? 2 : 1;
        final items = <Widget>[];
        for (int i = 0; i < docs.length; i++) {
          // 错踪：偶数卡片右移 + 下移，奇数卡片左移 + 上移一点
          final offsetX = (i % 2 == 0 ? 0.0 : 16.0) + (_random.nextDouble() * 6 - 3);
          final offsetY = (i % 2 == 0 ? 8.0 : -4.0) + (_random.nextDouble() * 4 - 2);
          final rotate = (_random.nextDouble() - 0.5) * 0.04; // ±1.15° 轻微倾斜

          items.add(
            Transform.translate(
              offset: Offset(offsetX, offsetY),
              child: Transform.rotate(
                angle: rotate,
                child: _PublishedCard(doc: docs[i], onTap: () => _openDoc(docs[i])),
              ),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items,
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
}

/// 已发布作品卡片 —— 半透明缩略 + 半透明简介 + 主标题
class _PublishedCard extends StatelessWidget {
  final Document doc;
  final VoidCallback onTap;
  const _PublishedCard({required this.doc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final preview = _extractPreview(doc);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5A2B).withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 半透明缩略区（假图，用渐变色块模拟）
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF8B5A2B).withOpacity(0.18),
                    const Color(0xFFC89B5B).withOpacity(0.22),
                    const Color(0xFFFDF8F0).withOpacity(0.3),
                  ],
                ),
              ),
              child: Center(
                child: Icon(Icons.menu_book, size: 42, color: const Color(0xFF8B5A2B).withOpacity(0.4)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 半透明字体简介
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF3E2723).withOpacity(0.45), // 半透明
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 主标题
                  Text(
                    doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 模式标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5A2B).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      doc.modeLabel,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF8B5A2B)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractPreview(Document doc) {
    var s = doc.layoutContent;
    s = s.replaceAll(RegExp(r'<[^>]+>'), '');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (s.length > 50) s = s.substring(0, 50);
    return s.isEmpty ? '尚未添加内容简介' : s;
  }
}
