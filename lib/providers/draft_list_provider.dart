import 'package:flutter/foundation.dart';

import '../db/repositories/document_repository.dart';
import '../models/document.dart';
import '../models/doc_mode.dart';

/// 草稿箱列表 Provider
class DraftListProvider with ChangeNotifier {
  List<Document> _docs = [];
  bool _loading = false;
  DocMode? _modeFilter;
  bool? _publishedFilter;
  String _keyword = '';

  List<Document> get docs => _docs;
  bool get loading => _loading;
  DocMode? get modeFilter => _modeFilter;
  bool? get publishedFilter => _publishedFilter;

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    var list = await DocumentRepository.instance.listAll(
      filterMode: _modeFilter,
      isPublished: _publishedFilter,
    );
    if (_keyword.trim().isNotEmpty) {
      list = await DocumentRepository.instance.search(_keyword);
    }
    _docs = list;
    _loading = false;
    notifyListeners();
  }

  void setModeFilter(DocMode? m) {
    _modeFilter = m;
    refresh();
  }

  void setPublishedFilter(bool? p) {
    _publishedFilter = p;
    refresh();
  }

  void setKeyword(String kw) {
    _keyword = kw;
    refresh();
  }

  Future<void> deleteBatch(List<String> ids) async {
    await DocumentRepository.instance.deleteBatch(ids);
    await refresh();
  }
}
