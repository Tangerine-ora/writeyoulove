import '../db/app_db.dart';
import '../models/preferences.dart';

class PreferencesRepository {
  PreferencesRepository._();
  static final PreferencesRepository instance = PreferencesRepository._();

  Future<Isar> get _db => AppDb.instance;

  Future<Preferences> get() async {
    final db = await _db;
    var p = await db.preferences.get(1);
    if (p == null) {
      p = Preferences()..id = 1;
      await db.writeTxn(() async {
        await db.preferences.put(p);
      });
    }
    return p;
  }

  Future<void> save(Preferences p) async {
    final db = await _db;
    await db.writeTxn(() async {
      await db.preferences.put(p);
    });
  }
}
