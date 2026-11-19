import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/document.dart';
import '../models/doc_mode.dart';
import '../providers/draft_list_provider.dart';
import '../providers/preferences_provider.dart';

/// 已发布展示页 —— 按设计稿：错踪堆叠卡片 + 半透明简介 + 暖棕米白
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

  // ====== 正在阅读 ======
  Widget _buildReading(Document doc) {
    final prefs = context.watch<PreferencesProvider>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller!),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8, right: 8, bottom: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => setState(() => _currentDoc = null)),
                  Expanded(child: Text(doc.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
          if (!prefs.hidePageTurnButton) _buildPageTurnBar(),
        ],
      ),
    );
  }

  Widget _buildPageTurnBar() {
    return Positioned(
      left: 0, right: 0, bottom: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
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

  @override
  Widget build(BuildContext context) {
    final list = context.watch<DraftListProvider>();

    if (_currentDoc != null && _controller != null) {
      return _buildReading(_currentDoc!);
    }

    final published = list.docs.where((d) => d.isPublished && d.docMode == DocMode.layout).toList();

    // ====== 展示页：暖米白底 + 顶部栏 + 错踪卡片墙 ======
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: published.isEmpty
                ? const _EmptyHint()
                : _buildCardWall(published),
          ),
        ],
      ),
    );
  }

  // ====== 顶部栏：已发布 + 搜索 + 圆形头像 ======
  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 搜索
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD7C4A8)),
              ),
              child: const Icon(Icons.search, color: Color(0xFF8B5A2B), size: 20),
            ),
            const SizedBox(width: 12),
            // 标题
            const Text('已发布', style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.w700, fontSize: 20)),
            const Spacer(),
            // 圆形头像
            GestureDetector(
              onTap: () {
                context.read<DraftListProvider>().setPublishedFilter(null);
                Navigator.of(context).pop();
              },
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5A2B),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== 错踪卡片墙 ======
  // 设计稿理解：一张卡片叠在上一张右下角，斜着排，不是 wrap 换行
  Widget _buildCardWall(List<Document> docs) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final cardW = (constraints.maxWidth - 48) / 2; // 两列卡片
        final cardH = 240.0;
        final overlap = 24.0; // 下一张卡片向上偏移覆盖上一张
        final cols = 2;
        // 每列位置：第 r 行第 c 列
        final positions = <_CardPos>[];
        for (int i = 0; i < docs.length; i++) {
          final c = i % cols;
          final r = i ~/ cols;
          positions.add(_CardPos(c: c, r: r));
        }
        final totalRows = (docs.length / cols).ceil();
        final totalH = totalRows * cardH - (totalRows - 1) * overlap + 32;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: constraints.maxWidth,
            height: totalH,
            child: Stack(
              children: [
                for (int i = 0; i < docs.length; i++)
                  Positioned(
                    left: positions[i].c * (cardW + 16),
                    top: positions[i].r * (cardH - overlap),
                    child: SizedBox(
                      width: cardW,
                      height: cardH,
                      child: _PublishedCard(doc: docs[i], onTap: () => _openDoc(docs[i])),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CardPos { final int c, r; const _CardPos({required this.c, required this.r}); }

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book, size: 64, color: const Color(0xFFD7C4A8).withOpacity(0.6)),
          const SizedBox(height: 12),
          Text('暂无已发布的排版作品', style: TextStyle(color: const Color(0xFF795548).withOpacity(0.7))),
          const SizedBox(height: 4),
          Text('在草稿箱里把文档发布后会出现在这里', style: TextStyle(color: const Color(0xFF795548).withOpacity(0.5), fontSize: 12)),
        ],
      ),
    );
  }
}

/// 发布卡片：顶部渐变缩略区 + 半透明简介 + 主标题 + 模式标签
class _PublishedCard extends StatelessWidget {
  final Document doc;
  final VoidCallback onTap;
  const _PublishedCard({required this.doc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5A2B).withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 渐变缩略区
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF8B5A2B).withOpacity(0.16),
                      const Color(0xFFC89B5B).withOpacity(0.24),
                      const Color(0xFFF2E9DA).withOpacity(0.4),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.menu_book, size: 36, color: const Color(0xFF8B5A2B).withOpacity(0.35)),
                ),
              ),
            ),
            // 简介（半透明）+ 主标题
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_extractPreview(doc), maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: const Color(0xFF3E2723).withOpacity(0.4), height: 1.4)),
                  const SizedBox(height: 6),
                  Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF3E2723))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5A2B).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(doc.modeLabel, style: const TextStyle(fontSize: 11, color: Color(0xFF8B5A2B))),
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
    if (s.length > 40) s = s.substring(0, 40);
    return s.isEmpty ? '尚未添加内容简介' : s;
  }
}
