import '../db/app_db.dart';
import '../models/document.dart';

/// 文档仓库 —— 封装所有 Isar 读写
class DocumentRepository {
  DocumentRepository._();
  static final DocumentRepository instance = DocumentRepository._();

  Future<Isar> get _db => AppDb.instance;

  // ===== CRUD =====
  Future<List<Document>> listAll({DocMode? filterMode, bool? isPublished}) async {
    final db = await _db;
    var query = db.documents.where();
    if (filterMode != null) query = query.docModeEqualTo(filterMode);
    if (isPublished != null) query = query.isPublishedEqualTo(isPublished);
    return query.sortByUpdatedAtDesc().findAll();
  }

  Future<Document?> getById(Id id) async {
    final db = await _db;
    return db.documents.get(id);
  }

  Future<List<Document>> search(String keyword) async {
    final db = await _db;
    final all = await db.documents.where().findAll();
    final kw = keyword.trim().toLowerCase();
    if (kw.isEmpty) return all;
    return all.where((d) {
      return d.title.toLowerCase().contains(kw) ||
          d.rawTextContent.toLowerCase().contains(kw) ||
          d.layoutContent.toLowerCase().contains(kw);
    }).toList();
  }

  Future<Document> create({
    required String title,
    DocMode docMode = DocMode.normalWrite,
  }) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final doc = Document(
      id: Isar.autoIncrement,
      title: title.isEmpty ? '未命名文档' : title,
      docMode: docMode,
      createdAt: now,
      updatedAt: now,
    );
    if (docMode == DocMode.layout) {
      doc.layoutContent = '<page-setting bg="#FDF8F0"/><p>在此开始排版创作…</p>';
    }
    await db.writeTxn(() async {
      doc.id = await db.documents.put(doc);
    });
    return doc;
  }

  Future<void> save(Document doc) async {
    final db = await _db;
    doc.updatedAt = DateTime.now().millisecondsSinceEpoch;
    await db.writeTxn(() async {
      await db.documents.put(doc);
    });
  }

  Future<void> delete(Id id) async {
    final db = await _db;
    await db.writeTxn(() async {
      await db.documents.delete(id);
    });
  }

  Future<void> deleteBatch(List<Id> ids) async {
    final db = await _db;
    await db.writeTxn(() async {
      await db.documents.deleteAll(ids);
    });
  }
}
