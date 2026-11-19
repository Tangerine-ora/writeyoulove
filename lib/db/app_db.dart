import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/component_template.dart';
import '../models/document.dart';
import '../models/preferences.dart';

/// 基于 JSON 文件的简单存储 —— 跨平台，无 Isar 依赖
class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();

  String? _dir;

  Future<String> get dir async {
    if (_dir != null) return _dir!;
    final d = await getApplicationDocumentsDirectory();
    _dir = d.path;
    return _dir!;
  }

  Future<String> get _documentsPath async => '${await dir}/wy_documents.json';
  Future<String> get _prefsPath async => '${await dir}/wy_preferences.json';
  Future<String> get _templatesPath async => '${await dir}/wy_templates.json';

  Future<List<Document>> loadAllDocuments() async {
    try {
      final content = await _readFile(await _documentsPath);
      if (content == null) return [];
      final list = jsonDecode(content) as List<dynamic>;
      return list.map((e) => Document.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAllDocuments(List<Document> docs) async {
    final list = docs.map((d) => d.toMap()).toList();
    await _writeFile(await _documentsPath, jsonEncode(list));
  }

  Future<Preferences> loadPreferences() async {
    try {
      final content = await _readFile(await _prefsPath);
      if (content == null) return Preferences();
      return Preferences.fromMap(jsonDecode(content) as Map<String, dynamic>);
    } catch (_) {
      return Preferences();
    }
  }

  Future<void> savePreferences(Preferences p) async {
    await _writeFile(await _prefsPath, jsonEncode(p.toMap()));
  }

  Future<List<ComponentTemplate>> loadTemplates() async {
    try {
      final content = await _readFile(await _templatesPath);
      if (content == null) return [];
      final list = jsonDecode(content) as List<dynamic>;
      return list.map((e) => ComponentTemplate.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAllTemplates(List<ComponentTemplate> ts) async {
    await _writeFile(await _templatesPath, jsonEncode(ts.map((t) => t.toMap()).toList()));
  }

  Future<String?> _readFile(String path) async {
    try {
      final f = File(path);
      if (!await f.exists()) return null;
      return await f.readAsString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeFile(String path, String content) async {
    await Directory(path.substring(0, path.lastIndexOf('/'))).create(recursive: true);
    await File(path).writeAsString(content, encoding: utf8);
  }
}
