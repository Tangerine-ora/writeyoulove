import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/app_colors.dart';
import '../models/document.dart';
import '../models/preferences.dart';
import '../providers/preferences_provider.dart';

/// 排版独立只读预览页 —— 交互逻辑和发布页完全一致
/// 仅支持底部翻页按钮：不支持点击页面翻页、不支持键盘快捷键
class PreviewPage extends StatefulWidget {
  final Document doc;
  const PreviewPage({super.key, required this.doc});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  late final WebViewController _controller;
  int _currentPage = 0;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.creamWhite)
      ..loadFlutterAsset('assets/web/preview.html')
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) => _injectContent()),
      );
  }

  Future<void> _injectContent() async {
    await _controller.runJavaScript(
      'window.__WY_PREVIEW_LOAD__(${jsonEncode(widget.doc.layoutContent)}, true);',
    );
    final count = await _controller.runJavaScriptReturningResult('window.__WY_PAGE_COUNT__ || 1');
    setState(() => _totalPages = int.tryParse(count?.toString() ?? '1') ?? 1);
  }

  Future<void> _goPage(int idx) async {
    if (idx < 0 || idx >= _totalPages) return;
    setState(() => _currentPage = idx);
    await _controller.runJavaScript('window.__WY_GO_PAGE__($idx);');
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('预览 · ${widget.doc.title}'),
        automaticallyImplyLeading: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (!prefs.hidePageTurnButton) _buildPageTurnBar(),
        ],
      ),
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
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0 ? () => _goPage(_currentPage - 1) : null,
              ),
              Text('${_currentPage + 1} / $_totalPages'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages - 1 ? () => _goPage(_currentPage + 1) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
