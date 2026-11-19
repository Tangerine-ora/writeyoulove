import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
import 'layout_editor_page.dart';
import 'dev_editor_page.dart';
import 'normal_writer_page.dart';

/// 根据文档当前 docMode 自动路由到对应编辑器
class DocumentEditorRouter extends StatelessWidget {
  const DocumentEditorRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final doc = context.watch<DocumentProvider>().current;
    if (doc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    switch (doc.docMode) {
      case DocMode.normalWrite:
        return const NormalWriterPage();
      case DocMode.layout:
        return const LayoutEditorPage();
      case DocMode.developer:
        return const DevEditorPage();
    }
  }
}
