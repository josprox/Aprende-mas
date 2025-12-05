// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Desconocido'));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('1.0'));
  @override
  List<GeneratedColumn> get $columns => [id, name, author, version];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(Insertable<Subject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final int id;
  final String name;
  final String author;
  final String version;
  const Subject(
      {required this.id,
      required this.name,
      required this.author,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['author'] = Variable<String>(author);
    map['version'] = Variable<String>(version);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      name: Value(name),
      author: Value(author),
      version: Value(version),
    );
  }

  factory Subject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      author: serializer.fromJson<String>(json['author']),
      version: serializer.fromJson<String>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'author': serializer.toJson<String>(author),
      'version': serializer.toJson<String>(version),
    };
  }

  Subject copyWith({int? id, String? name, String? author, String? version}) =>
      Subject(
        id: id ?? this.id,
        name: name ?? this.name,
        author: author ?? this.author,
        version: version ?? this.version,
      );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      author: data.author.present ? data.author.value : this.author,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, author, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.name == this.name &&
          other.author == this.author &&
          other.version == this.version);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> author;
  final Value<String> version;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.author = const Value.absent(),
    this.version = const Value.absent(),
  });
  SubjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.author = const Value.absent(),
    this.version = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Subject> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? author,
    Expression<String>? version,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (author != null) 'author': author,
      if (version != null) 'version': version,
    });
  }

  SubjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? author,
      Value<String>? version}) {
    return SubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      version: version ?? this.version,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }
}

class $ModulesTable extends Modules with TableInfo<$ModulesTable, Module> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES subjects (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shortDescriptionMeta =
      const VerificationMeta('shortDescription');
  @override
  late final GeneratedColumn<String> shortDescription = GeneratedColumn<String>(
      'short_description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, subjectId, title, shortDescription];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'modules';
  @override
  VerificationContext validateIntegrity(Insertable<Module> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('short_description')) {
      context.handle(
          _shortDescriptionMeta,
          shortDescription.isAcceptableOrUnknown(
              data['short_description']!, _shortDescriptionMeta));
    } else if (isInserting) {
      context.missing(_shortDescriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Module map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Module(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subject_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      shortDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}short_description'])!,
    );
  }

  @override
  $ModulesTable createAlias(String alias) {
    return $ModulesTable(attachedDatabase, alias);
  }
}

class Module extends DataClass implements Insertable<Module> {
  final int id;
  final int subjectId;
  final String title;
  final String shortDescription;
  const Module(
      {required this.id,
      required this.subjectId,
      required this.title,
      required this.shortDescription});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subject_id'] = Variable<int>(subjectId);
    map['title'] = Variable<String>(title);
    map['short_description'] = Variable<String>(shortDescription);
    return map;
  }

  ModulesCompanion toCompanion(bool nullToAbsent) {
    return ModulesCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      title: Value(title),
      shortDescription: Value(shortDescription),
    );
  }

  factory Module.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Module(
      id: serializer.fromJson<int>(json['id']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      title: serializer.fromJson<String>(json['title']),
      shortDescription: serializer.fromJson<String>(json['shortDescription']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subjectId': serializer.toJson<int>(subjectId),
      'title': serializer.toJson<String>(title),
      'shortDescription': serializer.toJson<String>(shortDescription),
    };
  }

  Module copyWith(
          {int? id, int? subjectId, String? title, String? shortDescription}) =>
      Module(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        shortDescription: shortDescription ?? this.shortDescription,
      );
  Module copyWithCompanion(ModulesCompanion data) {
    return Module(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      title: data.title.present ? data.title.value : this.title,
      shortDescription: data.shortDescription.present
          ? data.shortDescription.value
          : this.shortDescription,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Module(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('shortDescription: $shortDescription')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, subjectId, title, shortDescription);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Module &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.title == this.title &&
          other.shortDescription == this.shortDescription);
}

class ModulesCompanion extends UpdateCompanion<Module> {
  final Value<int> id;
  final Value<int> subjectId;
  final Value<String> title;
  final Value<String> shortDescription;
  const ModulesCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.title = const Value.absent(),
    this.shortDescription = const Value.absent(),
  });
  ModulesCompanion.insert({
    this.id = const Value.absent(),
    required int subjectId,
    required String title,
    required String shortDescription,
  })  : subjectId = Value(subjectId),
        title = Value(title),
        shortDescription = Value(shortDescription);
  static Insertable<Module> custom({
    Expression<int>? id,
    Expression<int>? subjectId,
    Expression<String>? title,
    Expression<String>? shortDescription,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (title != null) 'title': title,
      if (shortDescription != null) 'short_description': shortDescription,
    });
  }

  ModulesCompanion copyWith(
      {Value<int>? id,
      Value<int>? subjectId,
      Value<String>? title,
      Value<String>? shortDescription}) {
    return ModulesCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (shortDescription.present) {
      map['short_description'] = Variable<String>(shortDescription.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModulesCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('shortDescription: $shortDescription')
          ..write(')'))
        .toString();
  }
}

class $SubmodulesTable extends Submodules
    with TableInfo<$SubmodulesTable, Submodule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubmodulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _moduleIdMeta =
      const VerificationMeta('moduleId');
  @override
  late final GeneratedColumn<int> moduleId = GeneratedColumn<int>(
      'module_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES modules (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMdMeta =
      const VerificationMeta('contentMd');
  @override
  late final GeneratedColumn<String> contentMd = GeneratedColumn<String>(
      'content_md', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, moduleId, title, contentMd];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'submodules';
  @override
  VerificationContext validateIntegrity(Insertable<Submodule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('module_id')) {
      context.handle(_moduleIdMeta,
          moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta));
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content_md')) {
      context.handle(_contentMdMeta,
          contentMd.isAcceptableOrUnknown(data['content_md']!, _contentMdMeta));
    } else if (isInserting) {
      context.missing(_contentMdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Submodule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Submodule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      moduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}module_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      contentMd: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_md'])!,
    );
  }

  @override
  $SubmodulesTable createAlias(String alias) {
    return $SubmodulesTable(attachedDatabase, alias);
  }
}

class Submodule extends DataClass implements Insertable<Submodule> {
  final int id;
  final int moduleId;
  final String title;
  final String contentMd;
  const Submodule(
      {required this.id,
      required this.moduleId,
      required this.title,
      required this.contentMd});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['module_id'] = Variable<int>(moduleId);
    map['title'] = Variable<String>(title);
    map['content_md'] = Variable<String>(contentMd);
    return map;
  }

  SubmodulesCompanion toCompanion(bool nullToAbsent) {
    return SubmodulesCompanion(
      id: Value(id),
      moduleId: Value(moduleId),
      title: Value(title),
      contentMd: Value(contentMd),
    );
  }

  factory Submodule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Submodule(
      id: serializer.fromJson<int>(json['id']),
      moduleId: serializer.fromJson<int>(json['moduleId']),
      title: serializer.fromJson<String>(json['title']),
      contentMd: serializer.fromJson<String>(json['contentMd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'moduleId': serializer.toJson<int>(moduleId),
      'title': serializer.toJson<String>(title),
      'contentMd': serializer.toJson<String>(contentMd),
    };
  }

  Submodule copyWith(
          {int? id, int? moduleId, String? title, String? contentMd}) =>
      Submodule(
        id: id ?? this.id,
        moduleId: moduleId ?? this.moduleId,
        title: title ?? this.title,
        contentMd: contentMd ?? this.contentMd,
      );
  Submodule copyWithCompanion(SubmodulesCompanion data) {
    return Submodule(
      id: data.id.present ? data.id.value : this.id,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      title: data.title.present ? data.title.value : this.title,
      contentMd: data.contentMd.present ? data.contentMd.value : this.contentMd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Submodule(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('title: $title, ')
          ..write('contentMd: $contentMd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, moduleId, title, contentMd);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Submodule &&
          other.id == this.id &&
          other.moduleId == this.moduleId &&
          other.title == this.title &&
          other.contentMd == this.contentMd);
}

class SubmodulesCompanion extends UpdateCompanion<Submodule> {
  final Value<int> id;
  final Value<int> moduleId;
  final Value<String> title;
  final Value<String> contentMd;
  const SubmodulesCompanion({
    this.id = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.title = const Value.absent(),
    this.contentMd = const Value.absent(),
  });
  SubmodulesCompanion.insert({
    this.id = const Value.absent(),
    required int moduleId,
    required String title,
    required String contentMd,
  })  : moduleId = Value(moduleId),
        title = Value(title),
        contentMd = Value(contentMd);
  static Insertable<Submodule> custom({
    Expression<int>? id,
    Expression<int>? moduleId,
    Expression<String>? title,
    Expression<String>? contentMd,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (moduleId != null) 'module_id': moduleId,
      if (title != null) 'title': title,
      if (contentMd != null) 'content_md': contentMd,
    });
  }

  SubmodulesCompanion copyWith(
      {Value<int>? id,
      Value<int>? moduleId,
      Value<String>? title,
      Value<String>? contentMd}) {
    return SubmodulesCompanion(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      contentMd: contentMd ?? this.contentMd,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<int>(moduleId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (contentMd.present) {
      map['content_md'] = Variable<String>(contentMd.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubmodulesCompanion(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('title: $title, ')
          ..write('contentMd: $contentMd')
          ..write(')'))
        .toString();
  }
}

class $QuestionsTable extends Questions
    with TableInfo<$QuestionsTable, Question> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _moduleIdMeta =
      const VerificationMeta('moduleId');
  @override
  late final GeneratedColumn<int> moduleId = GeneratedColumn<int>(
      'module_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES modules (id) ON DELETE CASCADE'));
  static const VerificationMeta _questionTextMeta =
      const VerificationMeta('questionText');
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
      'question_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionAMeta =
      const VerificationMeta('optionA');
  @override
  late final GeneratedColumn<String> optionA = GeneratedColumn<String>(
      'option_a', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionBMeta =
      const VerificationMeta('optionB');
  @override
  late final GeneratedColumn<String> optionB = GeneratedColumn<String>(
      'option_b', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionCMeta =
      const VerificationMeta('optionC');
  @override
  late final GeneratedColumn<String> optionC = GeneratedColumn<String>(
      'option_c', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionDMeta =
      const VerificationMeta('optionD');
  @override
  late final GeneratedColumn<String> optionD = GeneratedColumn<String>(
      'option_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _correctAnswerMeta =
      const VerificationMeta('correctAnswer');
  @override
  late final GeneratedColumn<String> correctAnswer = GeneratedColumn<String>(
      'correct_answer', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _explanationTextMeta =
      const VerificationMeta('explanationText');
  @override
  late final GeneratedColumn<String> explanationText = GeneratedColumn<String>(
      'explanation_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        moduleId,
        questionText,
        optionA,
        optionB,
        optionC,
        optionD,
        correctAnswer,
        explanationText
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questions';
  @override
  VerificationContext validateIntegrity(Insertable<Question> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('module_id')) {
      context.handle(_moduleIdMeta,
          moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta));
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('question_text')) {
      context.handle(
          _questionTextMeta,
          questionText.isAcceptableOrUnknown(
              data['question_text']!, _questionTextMeta));
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('option_a')) {
      context.handle(_optionAMeta,
          optionA.isAcceptableOrUnknown(data['option_a']!, _optionAMeta));
    } else if (isInserting) {
      context.missing(_optionAMeta);
    }
    if (data.containsKey('option_b')) {
      context.handle(_optionBMeta,
          optionB.isAcceptableOrUnknown(data['option_b']!, _optionBMeta));
    } else if (isInserting) {
      context.missing(_optionBMeta);
    }
    if (data.containsKey('option_c')) {
      context.handle(_optionCMeta,
          optionC.isAcceptableOrUnknown(data['option_c']!, _optionCMeta));
    } else if (isInserting) {
      context.missing(_optionCMeta);
    }
    if (data.containsKey('option_d')) {
      context.handle(_optionDMeta,
          optionD.isAcceptableOrUnknown(data['option_d']!, _optionDMeta));
    } else if (isInserting) {
      context.missing(_optionDMeta);
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
          _correctAnswerMeta,
          correctAnswer.isAcceptableOrUnknown(
              data['correct_answer']!, _correctAnswerMeta));
    } else if (isInserting) {
      context.missing(_correctAnswerMeta);
    }
    if (data.containsKey('explanation_text')) {
      context.handle(
          _explanationTextMeta,
          explanationText.isAcceptableOrUnknown(
              data['explanation_text']!, _explanationTextMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Question map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Question(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      moduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}module_id'])!,
      questionText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_text'])!,
      optionA: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}option_a'])!,
      optionB: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}option_b'])!,
      optionC: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}option_c'])!,
      optionD: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}option_d'])!,
      correctAnswer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}correct_answer'])!,
      explanationText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}explanation_text'])!,
    );
  }

  @override
  $QuestionsTable createAlias(String alias) {
    return $QuestionsTable(attachedDatabase, alias);
  }
}

class Question extends DataClass implements Insertable<Question> {
  final int id;
  final int moduleId;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String explanationText;
  const Question(
      {required this.id,
      required this.moduleId,
      required this.questionText,
      required this.optionA,
      required this.optionB,
      required this.optionC,
      required this.optionD,
      required this.correctAnswer,
      required this.explanationText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['module_id'] = Variable<int>(moduleId);
    map['question_text'] = Variable<String>(questionText);
    map['option_a'] = Variable<String>(optionA);
    map['option_b'] = Variable<String>(optionB);
    map['option_c'] = Variable<String>(optionC);
    map['option_d'] = Variable<String>(optionD);
    map['correct_answer'] = Variable<String>(correctAnswer);
    map['explanation_text'] = Variable<String>(explanationText);
    return map;
  }

  QuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionsCompanion(
      id: Value(id),
      moduleId: Value(moduleId),
      questionText: Value(questionText),
      optionA: Value(optionA),
      optionB: Value(optionB),
      optionC: Value(optionC),
      optionD: Value(optionD),
      correctAnswer: Value(correctAnswer),
      explanationText: Value(explanationText),
    );
  }

  factory Question.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Question(
      id: serializer.fromJson<int>(json['id']),
      moduleId: serializer.fromJson<int>(json['moduleId']),
      questionText: serializer.fromJson<String>(json['questionText']),
      optionA: serializer.fromJson<String>(json['optionA']),
      optionB: serializer.fromJson<String>(json['optionB']),
      optionC: serializer.fromJson<String>(json['optionC']),
      optionD: serializer.fromJson<String>(json['optionD']),
      correctAnswer: serializer.fromJson<String>(json['correctAnswer']),
      explanationText: serializer.fromJson<String>(json['explanationText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'moduleId': serializer.toJson<int>(moduleId),
      'questionText': serializer.toJson<String>(questionText),
      'optionA': serializer.toJson<String>(optionA),
      'optionB': serializer.toJson<String>(optionB),
      'optionC': serializer.toJson<String>(optionC),
      'optionD': serializer.toJson<String>(optionD),
      'correctAnswer': serializer.toJson<String>(correctAnswer),
      'explanationText': serializer.toJson<String>(explanationText),
    };
  }

  Question copyWith(
          {int? id,
          int? moduleId,
          String? questionText,
          String? optionA,
          String? optionB,
          String? optionC,
          String? optionD,
          String? correctAnswer,
          String? explanationText}) =>
      Question(
        id: id ?? this.id,
        moduleId: moduleId ?? this.moduleId,
        questionText: questionText ?? this.questionText,
        optionA: optionA ?? this.optionA,
        optionB: optionB ?? this.optionB,
        optionC: optionC ?? this.optionC,
        optionD: optionD ?? this.optionD,
        correctAnswer: correctAnswer ?? this.correctAnswer,
        explanationText: explanationText ?? this.explanationText,
      );
  Question copyWithCompanion(QuestionsCompanion data) {
    return Question(
      id: data.id.present ? data.id.value : this.id,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      optionA: data.optionA.present ? data.optionA.value : this.optionA,
      optionB: data.optionB.present ? data.optionB.value : this.optionB,
      optionC: data.optionC.present ? data.optionC.value : this.optionC,
      optionD: data.optionD.present ? data.optionD.value : this.optionD,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
      explanationText: data.explanationText.present
          ? data.explanationText.value
          : this.explanationText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Question(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('questionText: $questionText, ')
          ..write('optionA: $optionA, ')
          ..write('optionB: $optionB, ')
          ..write('optionC: $optionC, ')
          ..write('optionD: $optionD, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('explanationText: $explanationText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, moduleId, questionText, optionA, optionB,
      optionC, optionD, correctAnswer, explanationText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Question &&
          other.id == this.id &&
          other.moduleId == this.moduleId &&
          other.questionText == this.questionText &&
          other.optionA == this.optionA &&
          other.optionB == this.optionB &&
          other.optionC == this.optionC &&
          other.optionD == this.optionD &&
          other.correctAnswer == this.correctAnswer &&
          other.explanationText == this.explanationText);
}

class QuestionsCompanion extends UpdateCompanion<Question> {
  final Value<int> id;
  final Value<int> moduleId;
  final Value<String> questionText;
  final Value<String> optionA;
  final Value<String> optionB;
  final Value<String> optionC;
  final Value<String> optionD;
  final Value<String> correctAnswer;
  final Value<String> explanationText;
  const QuestionsCompanion({
    this.id = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.questionText = const Value.absent(),
    this.optionA = const Value.absent(),
    this.optionB = const Value.absent(),
    this.optionC = const Value.absent(),
    this.optionD = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.explanationText = const Value.absent(),
  });
  QuestionsCompanion.insert({
    this.id = const Value.absent(),
    required int moduleId,
    required String questionText,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    this.explanationText = const Value.absent(),
  })  : moduleId = Value(moduleId),
        questionText = Value(questionText),
        optionA = Value(optionA),
        optionB = Value(optionB),
        optionC = Value(optionC),
        optionD = Value(optionD),
        correctAnswer = Value(correctAnswer);
  static Insertable<Question> custom({
    Expression<int>? id,
    Expression<int>? moduleId,
    Expression<String>? questionText,
    Expression<String>? optionA,
    Expression<String>? optionB,
    Expression<String>? optionC,
    Expression<String>? optionD,
    Expression<String>? correctAnswer,
    Expression<String>? explanationText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (moduleId != null) 'module_id': moduleId,
      if (questionText != null) 'question_text': questionText,
      if (optionA != null) 'option_a': optionA,
      if (optionB != null) 'option_b': optionB,
      if (optionC != null) 'option_c': optionC,
      if (optionD != null) 'option_d': optionD,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
      if (explanationText != null) 'explanation_text': explanationText,
    });
  }

  QuestionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? moduleId,
      Value<String>? questionText,
      Value<String>? optionA,
      Value<String>? optionB,
      Value<String>? optionC,
      Value<String>? optionD,
      Value<String>? correctAnswer,
      Value<String>? explanationText}) {
    return QuestionsCompanion(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      questionText: questionText ?? this.questionText,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanationText: explanationText ?? this.explanationText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<int>(moduleId.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (optionA.present) {
      map['option_a'] = Variable<String>(optionA.value);
    }
    if (optionB.present) {
      map['option_b'] = Variable<String>(optionB.value);
    }
    if (optionC.present) {
      map['option_c'] = Variable<String>(optionC.value);
    }
    if (optionD.present) {
      map['option_d'] = Variable<String>(optionD.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<String>(correctAnswer.value);
    }
    if (explanationText.present) {
      map['explanation_text'] = Variable<String>(explanationText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionsCompanion(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('questionText: $questionText, ')
          ..write('optionA: $optionA, ')
          ..write('optionB: $optionB, ')
          ..write('optionC: $optionC, ')
          ..write('optionD: $optionD, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('explanationText: $explanationText')
          ..write(')'))
        .toString();
  }
}

class $TestAttemptsTable extends TestAttempts
    with TableInfo<$TestAttemptsTable, TestAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _moduleIdMeta =
      const VerificationMeta('moduleId');
  @override
  late final GeneratedColumn<int> moduleId = GeneratedColumn<int>(
      'module_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES modules (id) ON DELETE CASCADE'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalQuestionsMeta =
      const VerificationMeta('totalQuestions');
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
      'total_questions', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _correctAnswersMeta =
      const VerificationMeta('correctAnswers');
  @override
  late final GeneratedColumn<int> correctAnswers = GeneratedColumn<int>(
      'correct_answers', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _currentQuestionIndexMeta =
      const VerificationMeta('currentQuestionIndex');
  @override
  late final GeneratedColumn<int> currentQuestionIndex = GeneratedColumn<int>(
      'current_question_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        moduleId,
        status,
        score,
        totalQuestions,
        correctAnswers,
        timestamp,
        currentQuestionIndex
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_attempts';
  @override
  VerificationContext validateIntegrity(Insertable<TestAttempt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('module_id')) {
      context.handle(_moduleIdMeta,
          moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta));
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    if (data.containsKey('total_questions')) {
      context.handle(
          _totalQuestionsMeta,
          totalQuestions.isAcceptableOrUnknown(
              data['total_questions']!, _totalQuestionsMeta));
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('correct_answers')) {
      context.handle(
          _correctAnswersMeta,
          correctAnswers.isAcceptableOrUnknown(
              data['correct_answers']!, _correctAnswersMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('current_question_index')) {
      context.handle(
          _currentQuestionIndexMeta,
          currentQuestionIndex.isAcceptableOrUnknown(
              data['current_question_index']!, _currentQuestionIndexMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestAttempt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      moduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}module_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score'])!,
      totalQuestions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_questions'])!,
      correctAnswers: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correct_answers'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      currentQuestionIndex: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}current_question_index'])!,
    );
  }

  @override
  $TestAttemptsTable createAlias(String alias) {
    return $TestAttemptsTable(attachedDatabase, alias);
  }
}

class TestAttempt extends DataClass implements Insertable<TestAttempt> {
  final int id;
  final int moduleId;
  final String status;
  final double score;
  final int totalQuestions;
  final int correctAnswers;
  final int timestamp;
  final int currentQuestionIndex;
  const TestAttempt(
      {required this.id,
      required this.moduleId,
      required this.status,
      required this.score,
      required this.totalQuestions,
      required this.correctAnswers,
      required this.timestamp,
      required this.currentQuestionIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['module_id'] = Variable<int>(moduleId);
    map['status'] = Variable<String>(status);
    map['score'] = Variable<double>(score);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['correct_answers'] = Variable<int>(correctAnswers);
    map['timestamp'] = Variable<int>(timestamp);
    map['current_question_index'] = Variable<int>(currentQuestionIndex);
    return map;
  }

  TestAttemptsCompanion toCompanion(bool nullToAbsent) {
    return TestAttemptsCompanion(
      id: Value(id),
      moduleId: Value(moduleId),
      status: Value(status),
      score: Value(score),
      totalQuestions: Value(totalQuestions),
      correctAnswers: Value(correctAnswers),
      timestamp: Value(timestamp),
      currentQuestionIndex: Value(currentQuestionIndex),
    );
  }

  factory TestAttempt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestAttempt(
      id: serializer.fromJson<int>(json['id']),
      moduleId: serializer.fromJson<int>(json['moduleId']),
      status: serializer.fromJson<String>(json['status']),
      score: serializer.fromJson<double>(json['score']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      correctAnswers: serializer.fromJson<int>(json['correctAnswers']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      currentQuestionIndex:
          serializer.fromJson<int>(json['currentQuestionIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'moduleId': serializer.toJson<int>(moduleId),
      'status': serializer.toJson<String>(status),
      'score': serializer.toJson<double>(score),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'correctAnswers': serializer.toJson<int>(correctAnswers),
      'timestamp': serializer.toJson<int>(timestamp),
      'currentQuestionIndex': serializer.toJson<int>(currentQuestionIndex),
    };
  }

  TestAttempt copyWith(
          {int? id,
          int? moduleId,
          String? status,
          double? score,
          int? totalQuestions,
          int? correctAnswers,
          int? timestamp,
          int? currentQuestionIndex}) =>
      TestAttempt(
        id: id ?? this.id,
        moduleId: moduleId ?? this.moduleId,
        status: status ?? this.status,
        score: score ?? this.score,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        correctAnswers: correctAnswers ?? this.correctAnswers,
        timestamp: timestamp ?? this.timestamp,
        currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      );
  TestAttempt copyWithCompanion(TestAttemptsCompanion data) {
    return TestAttempt(
      id: data.id.present ? data.id.value : this.id,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      status: data.status.present ? data.status.value : this.status,
      score: data.score.present ? data.score.value : this.score,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      correctAnswers: data.correctAnswers.present
          ? data.correctAnswers.value
          : this.correctAnswers,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      currentQuestionIndex: data.currentQuestionIndex.present
          ? data.currentQuestionIndex.value
          : this.currentQuestionIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestAttempt(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('status: $status, ')
          ..write('score: $score, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('timestamp: $timestamp, ')
          ..write('currentQuestionIndex: $currentQuestionIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, moduleId, status, score, totalQuestions,
      correctAnswers, timestamp, currentQuestionIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestAttempt &&
          other.id == this.id &&
          other.moduleId == this.moduleId &&
          other.status == this.status &&
          other.score == this.score &&
          other.totalQuestions == this.totalQuestions &&
          other.correctAnswers == this.correctAnswers &&
          other.timestamp == this.timestamp &&
          other.currentQuestionIndex == this.currentQuestionIndex);
}

class TestAttemptsCompanion extends UpdateCompanion<TestAttempt> {
  final Value<int> id;
  final Value<int> moduleId;
  final Value<String> status;
  final Value<double> score;
  final Value<int> totalQuestions;
  final Value<int> correctAnswers;
  final Value<int> timestamp;
  final Value<int> currentQuestionIndex;
  const TestAttemptsCompanion({
    this.id = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.status = const Value.absent(),
    this.score = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.currentQuestionIndex = const Value.absent(),
  });
  TestAttemptsCompanion.insert({
    this.id = const Value.absent(),
    required int moduleId,
    required String status,
    this.score = const Value.absent(),
    required int totalQuestions,
    this.correctAnswers = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.currentQuestionIndex = const Value.absent(),
  })  : moduleId = Value(moduleId),
        status = Value(status),
        totalQuestions = Value(totalQuestions);
  static Insertable<TestAttempt> custom({
    Expression<int>? id,
    Expression<int>? moduleId,
    Expression<String>? status,
    Expression<double>? score,
    Expression<int>? totalQuestions,
    Expression<int>? correctAnswers,
    Expression<int>? timestamp,
    Expression<int>? currentQuestionIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (moduleId != null) 'module_id': moduleId,
      if (status != null) 'status': status,
      if (score != null) 'score': score,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (correctAnswers != null) 'correct_answers': correctAnswers,
      if (timestamp != null) 'timestamp': timestamp,
      if (currentQuestionIndex != null)
        'current_question_index': currentQuestionIndex,
    });
  }

  TestAttemptsCompanion copyWith(
      {Value<int>? id,
      Value<int>? moduleId,
      Value<String>? status,
      Value<double>? score,
      Value<int>? totalQuestions,
      Value<int>? correctAnswers,
      Value<int>? timestamp,
      Value<int>? currentQuestionIndex}) {
    return TestAttemptsCompanion(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      status: status ?? this.status,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      timestamp: timestamp ?? this.timestamp,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<int>(moduleId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (correctAnswers.present) {
      map['correct_answers'] = Variable<int>(correctAnswers.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (currentQuestionIndex.present) {
      map['current_question_index'] = Variable<int>(currentQuestionIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('status: $status, ')
          ..write('score: $score, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('timestamp: $timestamp, ')
          ..write('currentQuestionIndex: $currentQuestionIndex')
          ..write(')'))
        .toString();
  }
}

class $UserAnswersTable extends UserAnswers
    with TableInfo<$UserAnswersTable, UserAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _testAttemptIdMeta =
      const VerificationMeta('testAttemptId');
  @override
  late final GeneratedColumn<int> testAttemptId = GeneratedColumn<int>(
      'test_attempt_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES test_attempts (id) ON DELETE CASCADE'));
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
      'question_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES questions (id) ON DELETE CASCADE'));
  static const VerificationMeta _selectedOptionMeta =
      const VerificationMeta('selectedOption');
  @override
  late final GeneratedColumn<String> selectedOption = GeneratedColumn<String>(
      'selected_option', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCorrectMeta =
      const VerificationMeta('isCorrect');
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
      'is_correct', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_correct" IN (0, 1))'));
  static const VerificationMeta _explanationTextMeta =
      const VerificationMeta('explanationText');
  @override
  late final GeneratedColumn<String> explanationText = GeneratedColumn<String>(
      'explanation_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        testAttemptId,
        questionId,
        selectedOption,
        isCorrect,
        explanationText
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_answers';
  @override
  VerificationContext validateIntegrity(Insertable<UserAnswer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('test_attempt_id')) {
      context.handle(
          _testAttemptIdMeta,
          testAttemptId.isAcceptableOrUnknown(
              data['test_attempt_id']!, _testAttemptIdMeta));
    } else if (isInserting) {
      context.missing(_testAttemptIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('selected_option')) {
      context.handle(
          _selectedOptionMeta,
          selectedOption.isAcceptableOrUnknown(
              data['selected_option']!, _selectedOptionMeta));
    } else if (isInserting) {
      context.missing(_selectedOptionMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(_isCorrectMeta,
          isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta));
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('explanation_text')) {
      context.handle(
          _explanationTextMeta,
          explanationText.isAcceptableOrUnknown(
              data['explanation_text']!, _explanationTextMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAnswer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      testAttemptId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}test_attempt_id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}question_id'])!,
      selectedOption: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}selected_option'])!,
      isCorrect: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_correct'])!,
      explanationText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}explanation_text']),
    );
  }

  @override
  $UserAnswersTable createAlias(String alias) {
    return $UserAnswersTable(attachedDatabase, alias);
  }
}

class UserAnswer extends DataClass implements Insertable<UserAnswer> {
  final int id;
  final int testAttemptId;
  final int questionId;
  final String selectedOption;
  final bool isCorrect;
  final String? explanationText;
  const UserAnswer(
      {required this.id,
      required this.testAttemptId,
      required this.questionId,
      required this.selectedOption,
      required this.isCorrect,
      this.explanationText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['test_attempt_id'] = Variable<int>(testAttemptId);
    map['question_id'] = Variable<int>(questionId);
    map['selected_option'] = Variable<String>(selectedOption);
    map['is_correct'] = Variable<bool>(isCorrect);
    if (!nullToAbsent || explanationText != null) {
      map['explanation_text'] = Variable<String>(explanationText);
    }
    return map;
  }

  UserAnswersCompanion toCompanion(bool nullToAbsent) {
    return UserAnswersCompanion(
      id: Value(id),
      testAttemptId: Value(testAttemptId),
      questionId: Value(questionId),
      selectedOption: Value(selectedOption),
      isCorrect: Value(isCorrect),
      explanationText: explanationText == null && nullToAbsent
          ? const Value.absent()
          : Value(explanationText),
    );
  }

  factory UserAnswer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAnswer(
      id: serializer.fromJson<int>(json['id']),
      testAttemptId: serializer.fromJson<int>(json['testAttemptId']),
      questionId: serializer.fromJson<int>(json['questionId']),
      selectedOption: serializer.fromJson<String>(json['selectedOption']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      explanationText: serializer.fromJson<String?>(json['explanationText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'testAttemptId': serializer.toJson<int>(testAttemptId),
      'questionId': serializer.toJson<int>(questionId),
      'selectedOption': serializer.toJson<String>(selectedOption),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'explanationText': serializer.toJson<String?>(explanationText),
    };
  }

  UserAnswer copyWith(
          {int? id,
          int? testAttemptId,
          int? questionId,
          String? selectedOption,
          bool? isCorrect,
          Value<String?> explanationText = const Value.absent()}) =>
      UserAnswer(
        id: id ?? this.id,
        testAttemptId: testAttemptId ?? this.testAttemptId,
        questionId: questionId ?? this.questionId,
        selectedOption: selectedOption ?? this.selectedOption,
        isCorrect: isCorrect ?? this.isCorrect,
        explanationText: explanationText.present
            ? explanationText.value
            : this.explanationText,
      );
  UserAnswer copyWithCompanion(UserAnswersCompanion data) {
    return UserAnswer(
      id: data.id.present ? data.id.value : this.id,
      testAttemptId: data.testAttemptId.present
          ? data.testAttemptId.value
          : this.testAttemptId,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      selectedOption: data.selectedOption.present
          ? data.selectedOption.value
          : this.selectedOption,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      explanationText: data.explanationText.present
          ? data.explanationText.value
          : this.explanationText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAnswer(')
          ..write('id: $id, ')
          ..write('testAttemptId: $testAttemptId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedOption: $selectedOption, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('explanationText: $explanationText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, testAttemptId, questionId, selectedOption,
      isCorrect, explanationText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAnswer &&
          other.id == this.id &&
          other.testAttemptId == this.testAttemptId &&
          other.questionId == this.questionId &&
          other.selectedOption == this.selectedOption &&
          other.isCorrect == this.isCorrect &&
          other.explanationText == this.explanationText);
}

class UserAnswersCompanion extends UpdateCompanion<UserAnswer> {
  final Value<int> id;
  final Value<int> testAttemptId;
  final Value<int> questionId;
  final Value<String> selectedOption;
  final Value<bool> isCorrect;
  final Value<String?> explanationText;
  const UserAnswersCompanion({
    this.id = const Value.absent(),
    this.testAttemptId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.selectedOption = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.explanationText = const Value.absent(),
  });
  UserAnswersCompanion.insert({
    this.id = const Value.absent(),
    required int testAttemptId,
    required int questionId,
    required String selectedOption,
    required bool isCorrect,
    this.explanationText = const Value.absent(),
  })  : testAttemptId = Value(testAttemptId),
        questionId = Value(questionId),
        selectedOption = Value(selectedOption),
        isCorrect = Value(isCorrect);
  static Insertable<UserAnswer> custom({
    Expression<int>? id,
    Expression<int>? testAttemptId,
    Expression<int>? questionId,
    Expression<String>? selectedOption,
    Expression<bool>? isCorrect,
    Expression<String>? explanationText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (testAttemptId != null) 'test_attempt_id': testAttemptId,
      if (questionId != null) 'question_id': questionId,
      if (selectedOption != null) 'selected_option': selectedOption,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (explanationText != null) 'explanation_text': explanationText,
    });
  }

  UserAnswersCompanion copyWith(
      {Value<int>? id,
      Value<int>? testAttemptId,
      Value<int>? questionId,
      Value<String>? selectedOption,
      Value<bool>? isCorrect,
      Value<String?>? explanationText}) {
    return UserAnswersCompanion(
      id: id ?? this.id,
      testAttemptId: testAttemptId ?? this.testAttemptId,
      questionId: questionId ?? this.questionId,
      selectedOption: selectedOption ?? this.selectedOption,
      isCorrect: isCorrect ?? this.isCorrect,
      explanationText: explanationText ?? this.explanationText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (testAttemptId.present) {
      map['test_attempt_id'] = Variable<int>(testAttemptId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (selectedOption.present) {
      map['selected_option'] = Variable<String>(selectedOption.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (explanationText.present) {
      map['explanation_text'] = Variable<String>(explanationText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAnswersCompanion(')
          ..write('id: $id, ')
          ..write('testAttemptId: $testAttemptId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedOption: $selectedOption, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('explanationText: $explanationText')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $ModulesTable modules = $ModulesTable(this);
  late final $SubmodulesTable submodules = $SubmodulesTable(this);
  late final $QuestionsTable questions = $QuestionsTable(this);
  late final $TestAttemptsTable testAttempts = $TestAttemptsTable(this);
  late final $UserAnswersTable userAnswers = $UserAnswersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [subjects, modules, submodules, questions, testAttempts, userAnswers];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('subjects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('modules', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('modules',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('submodules', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('modules',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('questions', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('modules',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('test_attempts', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('test_attempts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('user_answers', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('questions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('user_answers', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$SubjectsTableCreateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> author,
  Value<String> version,
});
typedef $$SubjectsTableUpdateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> author,
  Value<String> version,
});

class $$SubjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder> {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SubjectsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SubjectsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> author = const Value.absent(),
            Value<String> version = const Value.absent(),
          }) =>
              SubjectsCompanion(
            id: id,
            name: name,
            author: author,
            version: version,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> author = const Value.absent(),
            Value<String> version = const Value.absent(),
          }) =>
              SubjectsCompanion.insert(
            id: id,
            name: name,
            author: author,
            version: version,
          ),
        ));
}

class $$SubjectsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get author => $state.composableBuilder(
      column: $state.table.author,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter modulesRefs(
      ComposableFilter Function($$ModulesTableFilterComposer f) f) {
    final $$ModulesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.modules,
        getReferencedColumn: (t) => t.subjectId,
        builder: (joinBuilder, parentComposers) => $$ModulesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.modules, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$SubjectsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get author => $state.composableBuilder(
      column: $state.table.author,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ModulesTableCreateCompanionBuilder = ModulesCompanion Function({
  Value<int> id,
  required int subjectId,
  required String title,
  required String shortDescription,
});
typedef $$ModulesTableUpdateCompanionBuilder = ModulesCompanion Function({
  Value<int> id,
  Value<int> subjectId,
  Value<String> title,
  Value<String> shortDescription,
});

class $$ModulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ModulesTable,
    Module,
    $$ModulesTableFilterComposer,
    $$ModulesTableOrderingComposer,
    $$ModulesTableCreateCompanionBuilder,
    $$ModulesTableUpdateCompanionBuilder> {
  $$ModulesTableTableManager(_$AppDatabase db, $ModulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ModulesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ModulesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> subjectId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> shortDescription = const Value.absent(),
          }) =>
              ModulesCompanion(
            id: id,
            subjectId: subjectId,
            title: title,
            shortDescription: shortDescription,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int subjectId,
            required String title,
            required String shortDescription,
          }) =>
              ModulesCompanion.insert(
            id: id,
            subjectId: subjectId,
            title: title,
            shortDescription: shortDescription,
          ),
        ));
}

class $$ModulesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ModulesTable> {
  $$ModulesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get shortDescription => $state.composableBuilder(
      column: $state.table.shortDescription,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $state.db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$SubjectsTableFilterComposer(ComposerState(
                $state.db, $state.db.subjects, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter submodulesRefs(
      ComposableFilter Function($$SubmodulesTableFilterComposer f) f) {
    final $$SubmodulesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.submodules,
        getReferencedColumn: (t) => t.moduleId,
        builder: (joinBuilder, parentComposers) =>
            $$SubmodulesTableFilterComposer(ComposerState($state.db,
                $state.db.submodules, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter questionsRefs(
      ComposableFilter Function($$QuestionsTableFilterComposer f) f) {
    final $$QuestionsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.questions,
        getReferencedColumn: (t) => t.moduleId,
        builder: (joinBuilder, parentComposers) =>
            $$QuestionsTableFilterComposer(ComposerState(
                $state.db, $state.db.questions, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter testAttemptsRefs(
      ComposableFilter Function($$TestAttemptsTableFilterComposer f) f) {
    final $$TestAttemptsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.testAttempts,
        getReferencedColumn: (t) => t.moduleId,
        builder: (joinBuilder, parentComposers) =>
            $$TestAttemptsTableFilterComposer(ComposerState($state.db,
                $state.db.testAttempts, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ModulesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ModulesTable> {
  $$ModulesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get shortDescription => $state.composableBuilder(
      column: $state.table.shortDescription,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $state.db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$SubjectsTableOrderingComposer(ComposerState(
                $state.db, $state.db.subjects, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$SubmodulesTableCreateCompanionBuilder = SubmodulesCompanion Function({
  Value<int> id,
  required int moduleId,
  required String title,
  required String contentMd,
});
typedef $$SubmodulesTableUpdateCompanionBuilder = SubmodulesCompanion Function({
  Value<int> id,
  Value<int> moduleId,
  Value<String> title,
  Value<String> contentMd,
});

class $$SubmodulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubmodulesTable,
    Submodule,
    $$SubmodulesTableFilterComposer,
    $$SubmodulesTableOrderingComposer,
    $$SubmodulesTableCreateCompanionBuilder,
    $$SubmodulesTableUpdateCompanionBuilder> {
  $$SubmodulesTableTableManager(_$AppDatabase db, $SubmodulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SubmodulesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SubmodulesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> moduleId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> contentMd = const Value.absent(),
          }) =>
              SubmodulesCompanion(
            id: id,
            moduleId: moduleId,
            title: title,
            contentMd: contentMd,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int moduleId,
            required String title,
            required String contentMd,
          }) =>
              SubmodulesCompanion.insert(
            id: id,
            moduleId: moduleId,
            title: title,
            contentMd: contentMd,
          ),
        ));
}

class $$SubmodulesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SubmodulesTable> {
  $$SubmodulesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get contentMd => $state.composableBuilder(
      column: $state.table.contentMd,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ModulesTableFilterComposer get moduleId {
    final $$ModulesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.moduleId,
        referencedTable: $state.db.modules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ModulesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.modules, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$SubmodulesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SubmodulesTable> {
  $$SubmodulesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get contentMd => $state.composableBuilder(
      column: $state.table.contentMd,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ModulesTableOrderingComposer get moduleId {
    final $$ModulesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.moduleId,
        referencedTable: $state.db.modules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ModulesTableOrderingComposer(ComposerState(
                $state.db, $state.db.modules, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$QuestionsTableCreateCompanionBuilder = QuestionsCompanion Function({
  Value<int> id,
  required int moduleId,
  required String questionText,
  required String optionA,
  required String optionB,
  required String optionC,
  required String optionD,
  required String correctAnswer,
  Value<String> explanationText,
});
typedef $$QuestionsTableUpdateCompanionBuilder = QuestionsCompanion Function({
  Value<int> id,
  Value<int> moduleId,
  Value<String> questionText,
  Value<String> optionA,
  Value<String> optionB,
  Value<String> optionC,
  Value<String> optionD,
  Value<String> correctAnswer,
  Value<String> explanationText,
});

class $$QuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuestionsTable,
    Question,
    $$QuestionsTableFilterComposer,
    $$QuestionsTableOrderingComposer,
    $$QuestionsTableCreateCompanionBuilder,
    $$QuestionsTableUpdateCompanionBuilder> {
  $$QuestionsTableTableManager(_$AppDatabase db, $QuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$QuestionsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$QuestionsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> moduleId = const Value.absent(),
            Value<String> questionText = const Value.absent(),
            Value<String> optionA = const Value.absent(),
            Value<String> optionB = const Value.absent(),
            Value<String> optionC = const Value.absent(),
            Value<String> optionD = const Value.absent(),
            Value<String> correctAnswer = const Value.absent(),
            Value<String> explanationText = const Value.absent(),
          }) =>
              QuestionsCompanion(
            id: id,
            moduleId: moduleId,
            questionText: questionText,
            optionA: optionA,
            optionB: optionB,
            optionC: optionC,
            optionD: optionD,
            correctAnswer: correctAnswer,
            explanationText: explanationText,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int moduleId,
            required String questionText,
            required String optionA,
            required String optionB,
            required String optionC,
            required String optionD,
            required String correctAnswer,
            Value<String> explanationText = const Value.absent(),
          }) =>
              QuestionsCompanion.insert(
            id: id,
            moduleId: moduleId,
            questionText: questionText,
            optionA: optionA,
            optionB: optionB,
            optionC: optionC,
            optionD: optionD,
            correctAnswer: correctAnswer,
            explanationText: explanationText,
          ),
        ));
}

class $$QuestionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get questionText => $state.composableBuilder(
      column: $state.table.questionText,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get optionA => $state.composableBuilder(
      column: $state.table.optionA,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get optionB => $state.composableBuilder(
      column: $state.table.optionB,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get optionC => $state.composableBuilder(
      column: $state.table.optionC,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get optionD => $state.composableBuilder(
      column: $state.table.optionD,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get correctAnswer => $state.composableBuilder(
      column: $state.table.correctAnswer,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get explanationText => $state.composableBuilder(
      column: $state.table.explanationText,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ModulesTableFilterComposer get moduleId {
    final $$ModulesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.moduleId,
        referencedTable: $state.db.modules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ModulesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.modules, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter userAnswersRefs(
      ComposableFilter Function($$UserAnswersTableFilterComposer f) f) {
    final $$UserAnswersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.userAnswers,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder, parentComposers) =>
            $$UserAnswersTableFilterComposer(ComposerState($state.db,
                $state.db.userAnswers, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$QuestionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get questionText => $state.composableBuilder(
      column: $state.table.questionText,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get optionA => $state.composableBuilder(
      column: $state.table.optionA,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get optionB => $state.composableBuilder(
      column: $state.table.optionB,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get optionC => $state.composableBuilder(
      column: $state.table.optionC,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get optionD => $state.composableBuilder(
      column: $state.table.optionD,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get correctAnswer => $state.composableBuilder(
      column: $state.table.correctAnswer,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get explanationText => $state.composableBuilder(
      column: $state.table.explanationText,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ModulesTableOrderingComposer get moduleId {
    final $$ModulesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.moduleId,
        referencedTable: $state.db.modules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ModulesTableOrderingComposer(ComposerState(
                $state.db, $state.db.modules, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$TestAttemptsTableCreateCompanionBuilder = TestAttemptsCompanion
    Function({
  Value<int> id,
  required int moduleId,
  required String status,
  Value<double> score,
  required int totalQuestions,
  Value<int> correctAnswers,
  Value<int> timestamp,
  Value<int> currentQuestionIndex,
});
typedef $$TestAttemptsTableUpdateCompanionBuilder = TestAttemptsCompanion
    Function({
  Value<int> id,
  Value<int> moduleId,
  Value<String> status,
  Value<double> score,
  Value<int> totalQuestions,
  Value<int> correctAnswers,
  Value<int> timestamp,
  Value<int> currentQuestionIndex,
});

class $$TestAttemptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TestAttemptsTable,
    TestAttempt,
    $$TestAttemptsTableFilterComposer,
    $$TestAttemptsTableOrderingComposer,
    $$TestAttemptsTableCreateCompanionBuilder,
    $$TestAttemptsTableUpdateCompanionBuilder> {
  $$TestAttemptsTableTableManager(_$AppDatabase db, $TestAttemptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TestAttemptsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TestAttemptsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> moduleId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double> score = const Value.absent(),
            Value<int> totalQuestions = const Value.absent(),
            Value<int> correctAnswers = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<int> currentQuestionIndex = const Value.absent(),
          }) =>
              TestAttemptsCompanion(
            id: id,
            moduleId: moduleId,
            status: status,
            score: score,
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            timestamp: timestamp,
            currentQuestionIndex: currentQuestionIndex,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int moduleId,
            required String status,
            Value<double> score = const Value.absent(),
            required int totalQuestions,
            Value<int> correctAnswers = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<int> currentQuestionIndex = const Value.absent(),
          }) =>
              TestAttemptsCompanion.insert(
            id: id,
            moduleId: moduleId,
            status: status,
            score: score,
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            timestamp: timestamp,
            currentQuestionIndex: currentQuestionIndex,
          ),
        ));
}

class $$TestAttemptsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TestAttemptsTable> {
  $$TestAttemptsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get score => $state.composableBuilder(
      column: $state.table.score,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalQuestions => $state.composableBuilder(
      column: $state.table.totalQuestions,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get correctAnswers => $state.composableBuilder(
      column: $state.table.correctAnswers,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get currentQuestionIndex => $state.composableBuilder(
      column: $state.table.currentQuestionIndex,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ModulesTableFilterComposer get moduleId {
    final $$ModulesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.moduleId,
        referencedTable: $state.db.modules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ModulesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.modules, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter userAnswersRefs(
      ComposableFilter Function($$UserAnswersTableFilterComposer f) f) {
    final $$UserAnswersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.userAnswers,
        getReferencedColumn: (t) => t.testAttemptId,
        builder: (joinBuilder, parentComposers) =>
            $$UserAnswersTableFilterComposer(ComposerState($state.db,
                $state.db.userAnswers, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$TestAttemptsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TestAttemptsTable> {
  $$TestAttemptsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get score => $state.composableBuilder(
      column: $state.table.score,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalQuestions => $state.composableBuilder(
      column: $state.table.totalQuestions,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get correctAnswers => $state.composableBuilder(
      column: $state.table.correctAnswers,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get currentQuestionIndex => $state.composableBuilder(
      column: $state.table.currentQuestionIndex,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ModulesTableOrderingComposer get moduleId {
    final $$ModulesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.moduleId,
        referencedTable: $state.db.modules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ModulesTableOrderingComposer(ComposerState(
                $state.db, $state.db.modules, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$UserAnswersTableCreateCompanionBuilder = UserAnswersCompanion
    Function({
  Value<int> id,
  required int testAttemptId,
  required int questionId,
  required String selectedOption,
  required bool isCorrect,
  Value<String?> explanationText,
});
typedef $$UserAnswersTableUpdateCompanionBuilder = UserAnswersCompanion
    Function({
  Value<int> id,
  Value<int> testAttemptId,
  Value<int> questionId,
  Value<String> selectedOption,
  Value<bool> isCorrect,
  Value<String?> explanationText,
});

class $$UserAnswersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserAnswersTable,
    UserAnswer,
    $$UserAnswersTableFilterComposer,
    $$UserAnswersTableOrderingComposer,
    $$UserAnswersTableCreateCompanionBuilder,
    $$UserAnswersTableUpdateCompanionBuilder> {
  $$UserAnswersTableTableManager(_$AppDatabase db, $UserAnswersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UserAnswersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UserAnswersTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> testAttemptId = const Value.absent(),
            Value<int> questionId = const Value.absent(),
            Value<String> selectedOption = const Value.absent(),
            Value<bool> isCorrect = const Value.absent(),
            Value<String?> explanationText = const Value.absent(),
          }) =>
              UserAnswersCompanion(
            id: id,
            testAttemptId: testAttemptId,
            questionId: questionId,
            selectedOption: selectedOption,
            isCorrect: isCorrect,
            explanationText: explanationText,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int testAttemptId,
            required int questionId,
            required String selectedOption,
            required bool isCorrect,
            Value<String?> explanationText = const Value.absent(),
          }) =>
              UserAnswersCompanion.insert(
            id: id,
            testAttemptId: testAttemptId,
            questionId: questionId,
            selectedOption: selectedOption,
            isCorrect: isCorrect,
            explanationText: explanationText,
          ),
        ));
}

class $$UserAnswersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UserAnswersTable> {
  $$UserAnswersTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get selectedOption => $state.composableBuilder(
      column: $state.table.selectedOption,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isCorrect => $state.composableBuilder(
      column: $state.table.isCorrect,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get explanationText => $state.composableBuilder(
      column: $state.table.explanationText,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$TestAttemptsTableFilterComposer get testAttemptId {
    final $$TestAttemptsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.testAttemptId,
        referencedTable: $state.db.testAttempts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$TestAttemptsTableFilterComposer(ComposerState($state.db,
                $state.db.testAttempts, joinBuilder, parentComposers)));
    return composer;
  }

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $state.db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$QuestionsTableFilterComposer(ComposerState(
                $state.db, $state.db.questions, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$UserAnswersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UserAnswersTable> {
  $$UserAnswersTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get selectedOption => $state.composableBuilder(
      column: $state.table.selectedOption,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isCorrect => $state.composableBuilder(
      column: $state.table.isCorrect,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get explanationText => $state.composableBuilder(
      column: $state.table.explanationText,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$TestAttemptsTableOrderingComposer get testAttemptId {
    final $$TestAttemptsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.testAttemptId,
        referencedTable: $state.db.testAttempts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$TestAttemptsTableOrderingComposer(ComposerState($state.db,
                $state.db.testAttempts, joinBuilder, parentComposers)));
    return composer;
  }

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $state.db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$QuestionsTableOrderingComposer(ComposerState(
                $state.db, $state.db.questions, joinBuilder, parentComposers)));
    return composer;
  }
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$ModulesTableTableManager get modules =>
      $$ModulesTableTableManager(_db, _db.modules);
  $$SubmodulesTableTableManager get submodules =>
      $$SubmodulesTableTableManager(_db, _db.submodules);
  $$QuestionsTableTableManager get questions =>
      $$QuestionsTableTableManager(_db, _db.questions);
  $$TestAttemptsTableTableManager get testAttempts =>
      $$TestAttemptsTableTableManager(_db, _db.testAttempts);
  $$UserAnswersTableTableManager get userAnswers =>
      $$UserAnswersTableTableManager(_db, _db.userAnswers);
}

mixin _$StudyDaoMixin on DatabaseAccessor<AppDatabase> {
  $SubjectsTable get subjects => attachedDatabase.subjects;
  $ModulesTable get modules => attachedDatabase.modules;
  $SubmodulesTable get submodules => attachedDatabase.submodules;
  $QuestionsTable get questions => attachedDatabase.questions;
  $TestAttemptsTable get testAttempts => attachedDatabase.testAttempts;
  $UserAnswersTable get userAnswers => attachedDatabase.userAnswers;
}
