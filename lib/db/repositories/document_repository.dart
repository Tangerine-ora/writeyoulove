import 'package:uuid/uuid.dart';

import '../app_db.dart';
import '../../models/document.dart';
import '../../models/doc_mode.dart';

/// 文档仓库 —— 基于 JSON 文件
class DocumentRepository {
  DocumentRepository._();
  static final DocumentRepository instance = DocumentRepository._();

  final _db = AppDb.instance;
  final _uuid = const Uuid();

  Future<List<Document>> _all() => _db.loadAllDocuments();

  Future<List<Document>> listAll({DocMode? filterMode, bool? isPublished}) async {
    var list = await _all();
    if (filterMode != null) list = list.where((d) => d.docMode == filterMode).toList();
    if (isPublished != null) list = list.where((d) => d.isPublished == isPublished).toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<Document?> getById(String id) async {
    final list = await _all();
    for (final d in list) {
      if (d.id == id) return d;
    }
    return null;
  }

  Future<List<Document>> search(String keyword) async {
    final all = await _all();
    final kw = keyword.trim().toLowerCase();
    if (kw.isEmpty) return all;
    return all.where((d) {
      return d.title.toLowerCase().contains(kw) ||
          d.rawTextContent.toLowerCase().contains(kw) ||
          d.layoutContent.toLowerCase().contains(kw);
    }).toList();
  }

  Future<Document> create({required String title, DocMode docMode = DocMode.normalWrite}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final doc = Document(
      id: _uuid.v4(),
      title: title.isEmpty ? '未命名文档' : title,
      docMode: docMode,
      createdAt: now,
      updatedAt: now,
    );
    if (docMode == DocMode.layout) {
      doc.layoutContent = '<page-setting bg="#FDF8F0"/><p>在此开始排版创作…</p>';
    }
    final all = await _all();
    all.add(doc);
    await _db.saveAllDocuments(all);
    return doc;
  }

  Future<void> save(Document doc) async {
    doc.updatedAt = DateTime.now().millisecondsSinceEpoch;
    final all = await _all();
    final idx = all.indexWhere((d) => d.id == doc.id);
    if (idx >= 0) {
      all[idx] = doc;
    } else {
      all.add(doc);
    }
    await _db.saveAllDocuments(all);
  }

  Future<void> delete(String id) async {
    final all = await _all();
    all.removeWhere((d) => d.id == id);
    await _db.saveAllDocuments(all);
  }

  Future<void> deleteBatch(List<String> ids) async {
    final all = await _all();
    all.removeWhere((d) => ids.contains(d.id));
    await _db.saveAllDocuments(all);
  }
}
