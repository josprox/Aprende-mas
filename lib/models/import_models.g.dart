// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmoduleImport _$SubmoduleImportFromJson(Map<String, dynamic> json) =>
    SubmoduleImport(
      title: json['title'] as String,
      contentMd: json['contentMd'] as String,
    );

Map<String, dynamic> _$SubmoduleImportToJson(SubmoduleImport instance) =>
    <String, dynamic>{
      'title': instance.title,
      'contentMd': instance.contentMd,
    };

ModuleImport _$ModuleImportFromJson(Map<String, dynamic> json) => ModuleImport(
      title: json['title'] as String,
      shortDescription: json['shortDescription'] as String,
      submodules: (json['submodules'] as List<dynamic>)
          .map((e) => SubmoduleImport.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ModuleImportToJson(ModuleImport instance) =>
    <String, dynamic>{
      'title': instance.title,
      'shortDescription': instance.shortDescription,
      'submodules': instance.submodules,
    };

SubjectImport _$SubjectImportFromJson(Map<String, dynamic> json) =>
    SubjectImport(
      name: json['name'] as String,
      author: json['author'] as String,
      version: json['version'] as String,
      modules: (json['modules'] as List<dynamic>)
          .map((e) => ModuleImport.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectImportToJson(SubjectImport instance) =>
    <String, dynamic>{
      'name': instance.name,
      'author': instance.author,
      'version': instance.version,
      'modules': instance.modules,
    };
