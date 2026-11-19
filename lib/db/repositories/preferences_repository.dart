import '../app_db.dart';
import '../../models/preferences.dart';

class PreferencesRepository {
  PreferencesRepository._();
  static final PreferencesRepository instance = PreferencesRepository._();

  final _db = AppDb.instance;

  Future<Preferences> get() => _db.loadPreferences();
  Future<void> save(Preferences p) => _db.savePreferences(p);
}
