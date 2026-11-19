// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPreferencesCollection on Isar {
  IsarCollection<Preferences> get preferences => this.collection();
}

const PreferencesSchema = CollectionSchema(
  name: r'Preferences',
  id: 4252616732994050084,
  properties: {
    r'autoIndent': PropertySchema(
      id: 0,
      name: r'autoIndent',
      type: IsarType.bool,
    ),
    r'bgFillMode': PropertySchema(
      id: 1,
      name: r'bgFillMode',
      type: IsarType.byte,
      enumMap: _PreferencesbgFillModeEnumValueMap,
    ),
    r'defaultFontFamily': PropertySchema(
      id: 2,
      name: r'defaultFontFamily',
      type: IsarType.string,
    ),
    r'defaultFontSize': PropertySchema(
      id: 3,
      name: r'defaultFontSize',
      type: IsarType.double,
    ),
    r'hidePageTurnButton': PropertySchema(
      id: 4,
      name: r'hidePageTurnButton',
      type: IsarType.bool,
    ),
    r'homeEntry': PropertySchema(
      id: 5,
      name: r'homeEntry',
      type: IsarType.byte,
      enumMap: _PreferenceshomeEntryEnumValueMap,
    ),
    r'imageCompressEnabled': PropertySchema(
      id: 6,
      name: r'imageCompressEnabled',
      type: IsarType.bool,
    ),
    r'pageTurnAnimation': PropertySchema(
      id: 7,
      name: r'pageTurnAnimation',
      type: IsarType.bool,
    ),
    r'themeMode': PropertySchema(
      id: 8,
      name: r'themeMode',
      type: IsarType.byte,
      enumMap: _PreferencesthemeModeEnumValueMap,
    ),
    r'wordCountRule': PropertySchema(
      id: 9,
      name: r'wordCountRule',
      type: IsarType.byte,
      enumMap: _PreferenceswordCountRuleEnumValueMap,
    )
  },
  estimateSize: _preferencesEstimateSize,
  serialize: _preferencesSerialize,
  deserialize: _preferencesDeserialize,
  deserializeProp: _preferencesDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _preferencesGetId,
  getLinks: _preferencesGetLinks,
  attach: _preferencesAttach,
  version: '3.1.0+1',
);

int _preferencesEstimateSize(
  Preferences object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.defaultFontFamily.length * 3;
  return bytesCount;
}

void _preferencesSerialize(
  Preferences object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.autoIndent);
  writer.writeByte(offsets[1], object.bgFillMode.index);
  writer.writeString(offsets[2], object.defaultFontFamily);
  writer.writeDouble(offsets[3], object.defaultFontSize);
  writer.writeBool(offsets[4], object.hidePageTurnButton);
  writer.writeByte(offsets[5], object.homeEntry.index);
  writer.writeBool(offsets[6], object.imageCompressEnabled);
  writer.writeBool(offsets[7], object.pageTurnAnimation);
  writer.writeByte(offsets[8], object.themeMode.index);
  writer.writeByte(offsets[9], object.wordCountRule.index);
}

Preferences _preferencesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Preferences(
    id: id,
  );
  object.autoIndent = reader.readBool(offsets[0]);
  object.bgFillMode =
      _PreferencesbgFillModeValueEnumMap[reader.readByteOrNull(offsets[1])] ??
          BgFillMode.cover;
  object.defaultFontFamily = reader.readString(offsets[2]);
  object.defaultFontSize = reader.readDouble(offsets[3]);
  object.hidePageTurnButton = reader.readBool(offsets[4]);
  object.homeEntry =
      _PreferenceshomeEntryValueEnumMap[reader.readByteOrNull(offsets[5])] ??
          HomeEntry.drafts;
  object.imageCompressEnabled = reader.readBool(offsets[6]);
  object.pageTurnAnimation = reader.readBool(offsets[7]);
  object.themeMode =
      _PreferencesthemeModeValueEnumMap[reader.readByteOrNull(offsets[8])] ??
          AppThemeMode.warmBrown;
  object.wordCountRule = _PreferenceswordCountRuleValueEnumMap[
          reader.readByteOrNull(offsets[9])] ??
      WordCountRule.withFullWidthSpace;
  return object;
}

P _preferencesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (_PreferencesbgFillModeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          BgFillMode.cover) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (_PreferenceshomeEntryValueEnumMap[
              reader.readByteOrNull(offset)] ??
          HomeEntry.drafts) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (_PreferencesthemeModeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          AppThemeMode.warmBrown) as P;
    case 9:
      return (_PreferenceswordCountRuleValueEnumMap[
              reader.readByteOrNull(offset)] ??
          WordCountRule.withFullWidthSpace) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PreferencesbgFillModeEnumValueMap = {
  'cover': 0,
  'contain': 1,
  'repeat': 2,
};
const _PreferencesbgFillModeValueEnumMap = {
  0: BgFillMode.cover,
  1: BgFillMode.contain,
  2: BgFillMode.repeat,
};
const _PreferenceshomeEntryEnumValueMap = {
  'drafts': 0,
  'published': 1,
};
const _PreferenceshomeEntryValueEnumMap = {
  0: HomeEntry.drafts,
  1: HomeEntry.published,
};
const _PreferencesthemeModeEnumValueMap = {
  'warmBrown': 0,
  'dark': 1,
  'inkBlue': 2,
};
const _PreferencesthemeModeValueEnumMap = {
  0: AppThemeMode.warmBrown,
  1: AppThemeMode.dark,
  2: AppThemeMode.inkBlue,
};
const _PreferenceswordCountRuleEnumValueMap = {
  'withFullWidthSpace': 0,
  'withoutSpace': 1,
};
const _PreferenceswordCountRuleValueEnumMap = {
  0: WordCountRule.withFullWidthSpace,
  1: WordCountRule.withoutSpace,
};

Id _preferencesGetId(Preferences object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _preferencesGetLinks(Preferences object) {
  return [];
}

void _preferencesAttach(
    IsarCollection<dynamic> col, Id id, Preferences object) {
  object.id = id;
}

extension PreferencesQueryWhereSort
    on QueryBuilder<Preferences, Preferences, QWhere> {
  QueryBuilder<Preferences, Preferences, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PreferencesQueryWhere
    on QueryBuilder<Preferences, Preferences, QWhereClause> {
  QueryBuilder<Preferences, Preferences, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PreferencesQueryFilter
    on QueryBuilder<Preferences, Preferences, QFilterCondition> {
  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      autoIndentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoIndent',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      bgFillModeEqualTo(BgFillMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bgFillMode',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      bgFillModeGreaterThan(
    BgFillMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bgFillMode',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      bgFillModeLessThan(
    BgFillMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bgFillMode',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      bgFillModeBetween(
    BgFillMode lower,
    BgFillMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bgFillMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontFamilyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontFamilyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontFamilyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontFamilyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultFontFamily',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontFamilyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'defaultFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontFamilyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'defaultFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontFamilyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'defaultFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontFamilyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'defaultFontFamily',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontFamilyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultFontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontFamilyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'defaultFontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontSizeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultFontSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontSizeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultFontSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontSizeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultFontSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      defaultFontSizeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultFontSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      hidePageTurnButtonEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hidePageTurnButton',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      homeEntryEqualTo(HomeEntry value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'homeEntry',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      homeEntryGreaterThan(
    HomeEntry value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'homeEntry',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      homeEntryLessThan(
    HomeEntry value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'homeEntry',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      homeEntryBetween(
    HomeEntry lower,
    HomeEntry upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'homeEntry',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      imageCompressEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageCompressEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      pageTurnAnimationEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageTurnAnimation',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      themeModeEqualTo(AppThemeMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      themeModeGreaterThan(
    AppThemeMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      themeModeLessThan(
    AppThemeMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      themeModeBetween(
    AppThemeMode lower,
    AppThemeMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themeMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      wordCountRuleEqualTo(WordCountRule value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wordCountRule',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      wordCountRuleGreaterThan(
    WordCountRule value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wordCountRule',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      wordCountRuleLessThan(
    WordCountRule value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wordCountRule',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      wordCountRuleBetween(
    WordCountRule lower,
    WordCountRule upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wordCountRule',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PreferencesQueryObject
    on QueryBuilder<Preferences, Preferences, QFilterCondition> {}

extension PreferencesQueryLinks
    on QueryBuilder<Preferences, Preferences, QFilterCondition> {}

extension PreferencesQuerySortBy
    on QueryBuilder<Preferences, Preferences, QSortBy> {
  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByAutoIndent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoIndent', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByAutoIndentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoIndent', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByBgFillMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgFillMode', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByBgFillModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgFillMode', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      sortByDefaultFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultFontFamily', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      sortByDefaultFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultFontFamily', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByDefaultFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultFontSize', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      sortByDefaultFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultFontSize', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      sortByHidePageTurnButton() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hidePageTurnButton', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      sortByHidePageTurnButtonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hidePageTurnButton', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByHomeEntry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeEntry', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByHomeEntryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeEntry', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      sortByImageCompressEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageCompressEnabled', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      sortByImageCompressEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageCompressEnabled', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      sortByPageTurnAnimation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageTurnAnimation', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      sortByPageTurnAnimationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageTurnAnimation', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> sortByWordCountRule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordCountRule', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      sortByWordCountRuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordCountRule', Sort.desc);
    });
  }
}

extension PreferencesQuerySortThenBy
    on QueryBuilder<Preferences, Preferences, QSortThenBy> {
  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByAutoIndent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoIndent', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByAutoIndentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoIndent', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByBgFillMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgFillMode', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByBgFillModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgFillMode', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      thenByDefaultFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultFontFamily', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      thenByDefaultFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultFontFamily', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByDefaultFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultFontSize', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      thenByDefaultFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultFontSize', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      thenByHidePageTurnButton() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hidePageTurnButton', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      thenByHidePageTurnButtonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hidePageTurnButton', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByHomeEntry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeEntry', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByHomeEntryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeEntry', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      thenByImageCompressEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageCompressEnabled', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      thenByImageCompressEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageCompressEnabled', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      thenByPageTurnAnimation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageTurnAnimation', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      thenByPageTurnAnimationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageTurnAnimation', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy> thenByWordCountRule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordCountRule', Sort.asc);
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterSortBy>
      thenByWordCountRuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordCountRule', Sort.desc);
    });
  }
}

extension PreferencesQueryWhereDistinct
    on QueryBuilder<Preferences, Preferences, QDistinct> {
  QueryBuilder<Preferences, Preferences, QDistinct> distinctByAutoIndent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoIndent');
    });
  }

  QueryBuilder<Preferences, Preferences, QDistinct> distinctByBgFillMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bgFillMode');
    });
  }

  QueryBuilder<Preferences, Preferences, QDistinct> distinctByDefaultFontFamily(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultFontFamily',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Preferences, Preferences, QDistinct>
      distinctByDefaultFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultFontSize');
    });
  }

  QueryBuilder<Preferences, Preferences, QDistinct>
      distinctByHidePageTurnButton() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hidePageTurnButton');
    });
  }

  QueryBuilder<Preferences, Preferences, QDistinct> distinctByHomeEntry() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'homeEntry');
    });
  }

  QueryBuilder<Preferences, Preferences, QDistinct>
      distinctByImageCompressEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageCompressEnabled');
    });
  }

  QueryBuilder<Preferences, Preferences, QDistinct>
      distinctByPageTurnAnimation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageTurnAnimation');
    });
  }

  QueryBuilder<Preferences, Preferences, QDistinct> distinctByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode');
    });
  }

  QueryBuilder<Preferences, Preferences, QDistinct> distinctByWordCountRule() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wordCountRule');
    });
  }
}

extension PreferencesQueryProperty
    on QueryBuilder<Preferences, Preferences, QQueryProperty> {
  QueryBuilder<Preferences, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Preferences, bool, QQueryOperations> autoIndentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoIndent');
    });
  }

  QueryBuilder<Preferences, BgFillMode, QQueryOperations> bgFillModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bgFillMode');
    });
  }

  QueryBuilder<Preferences, String, QQueryOperations>
      defaultFontFamilyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultFontFamily');
    });
  }

  QueryBuilder<Preferences, double, QQueryOperations>
      defaultFontSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultFontSize');
    });
  }

  QueryBuilder<Preferences, bool, QQueryOperations>
      hidePageTurnButtonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hidePageTurnButton');
    });
  }

  QueryBuilder<Preferences, HomeEntry, QQueryOperations> homeEntryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'homeEntry');
    });
  }

  QueryBuilder<Preferences, bool, QQueryOperations>
      imageCompressEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageCompressEnabled');
    });
  }

  QueryBuilder<Preferences, bool, QQueryOperations>
      pageTurnAnimationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageTurnAnimation');
    });
  }

  QueryBuilder<Preferences, AppThemeMode, QQueryOperations>
      themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }

  QueryBuilder<Preferences, WordCountRule, QQueryOperations>
      wordCountRuleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wordCountRule');
    });
  }
}
