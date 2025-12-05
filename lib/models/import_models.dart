import 'package:json_annotation/json_annotation.dart';

part 'import_models.g.dart';

@JsonSerializable()
class SubmoduleImport {
  final String title;
  final String contentMd;

  const SubmoduleImport({required this.title, required this.contentMd});

  factory SubmoduleImport.fromJson(Map<String, dynamic> json) =>
      _$SubmoduleImportFromJson(json);

  Map<String, dynamic> toJson() => _$SubmoduleImportToJson(this);
}

@JsonSerializable()
class ModuleImport {
  final String title;
  final String shortDescription;
  final List<SubmoduleImport> submodules;

  const ModuleImport({
    required this.title,
    required this.shortDescription,
    required this.submodules,
  });

  factory ModuleImport.fromJson(Map<String, dynamic> json) =>
      _$ModuleImportFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleImportToJson(this);
}

@JsonSerializable()
class SubjectImport {
  final String name;
  final String author;
  final String version;
  final List<ModuleImport> modules;

  const SubjectImport({
    required this.name,
    required this.author,
    required this.version,
    required this.modules,
  });

  factory SubjectImport.fromJson(Map<String, dynamic> json) =>
      _$SubjectImportFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectImportToJson(this);
}
