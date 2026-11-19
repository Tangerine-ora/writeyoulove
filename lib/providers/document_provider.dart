import 'package:flutter/foundation.dart';

import '../db/repositories/document_repository.dart';
import '../models/document.dart';

/// 当前编辑文档 Provider
class DocumentProvider with ChangeNotifier {
  Document? _current;
  bool _loading = false;

  Document? get current => _current;
  bool get loading => _loading;
  bool get hasDocument => _current != null;

  Future<void> load(Id id) async {
    _loading = true;
    notifyListeners();
    _current = await DocumentRepository.instance.getById(id);
    _loading = false;
    notifyListeners();
  }

  Future<void> createNew({
    required String title,
    DocMode docMode = DocMode.normalWrite,
  }) async {
    _loading = true;
    notifyListeners();
    _current = await DocumentRepository.instance.create(
      title: title,
      docMode: docMode,
    );
    _loading = false;
    notifyListeners();
  }

  /// 保存当前文档（全量覆盖三套内容之一，由 docMode 决定）
  Future<void> saveCurrent({String? newContent}) async {
    if (_current == null) return;
    if (newContent != null) _current!.setCurrentContent(newContent);
    _current!.updatedAt = DateTime.now().millisecondsSinceEpoch;
    await DocumentRepository.instance.save(_current!);
    notifyListeners();
  }

  /// 切换模式（只改 docMode，三套内容都保留）
  /// 调用方负责：保存当前内容 → 弹出可能需要的版本提示
  Future<void> switchMode(DocMode newMode) async {
    if (_current == null || _current!.docMode == newMode) return;
    _current!.docMode = newMode;
    _current!.updatedAt = DateTime.now().millisecondsSinceEpoch;
    await DocumentRepository.instance.save(_current!);
    notifyListeners();
  }

  Future<void> publish({bool publish = true}) async {
    if (_current == null) return;
    _current!.isPublished = publish;
    _current!.updatedAt = DateTime.now().millisecondsSinceEpoch;
    await DocumentRepository.instance.save(_current!);
    notifyListeners();
  }

  void clear() {
    _current = null;
    notifyListeners();
  }
}
