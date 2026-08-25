class SubmoduleImport {
  final String title;
  final String contentMd;
  final List<SubmoduleImport> children;

  const SubmoduleImport({
    required this.title,
    required this.contentMd,
    this.children = const [],
  });

  factory SubmoduleImport.fromJson(Map<String, dynamic> json) {
    return SubmoduleImport(
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      contentMd:
          json['contentMd']?.toString() ??
          json['content_md']?.toString() ??
          json['content']?.toString() ??
          '',
      children:
          ((json['children'] ?? json['submodules'] ?? json['items'])
                      as List<dynamic>? ??
                  [])
              .whereType<Map<String, dynamic>>()
              .map(SubmoduleImport.fromJson)
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'contentMd': contentMd,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}

class ModuleImport {
  final String title;
  final String shortDescription;
  final List<SubmoduleImport> submodules;

  const ModuleImport({
    required this.title,
    required this.shortDescription,
    required this.submodules,
  });

  factory ModuleImport.fromJson(Map<String, dynamic> json) {
    final rawSubmodules =
        (json['children'] ?? json['submodules'] ?? json['items'])
            as List<dynamic>? ??
        [];
    final submodulesList = rawSubmodules
        .whereType<Map<String, dynamic>>()
        .map((e) => SubmoduleImport.fromJson(e))
        .toList();

    return ModuleImport(
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      shortDescription:
          json['shortDescription']?.toString() ??
          json['short_description']?.toString() ??
          json['description']?.toString() ??
          '',
      submodules: submodulesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'shortDescription': shortDescription,
      'children': submodules.map((e) => e.toJson()).toList(),
    };
  }
}

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

  factory SubjectImport.fromJson(Map<String, dynamic> json) {
    final rawModules =
        (json['modules'] ?? json['modulos'] ?? json['sections'])
            as List<dynamic>? ??
        [];
    final modulesList = rawModules
        .whereType<Map<String, dynamic>>()
        .map((e) => ModuleImport.fromJson(e))
        .toList();

    final name =
        json['name']?.toString() ??
        json['title']?.toString() ??
        json['subject_name']?.toString() ??
        json['materia']?.toString() ??
        'Materia';

    final version =
        json['version']?.toString() ??
        json['ver']?.toString() ??
        json['v']?.toString() ??
        '1.0';

    final author =
        json['author']?.toString() ?? json['autor']?.toString() ?? 'Joss Red';

    return SubjectImport(
      name: name,
      author: author,
      version: version,
      modules: modulesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': 2,
      'name': name,
      'author': author,
      'version': version,
      'modules': modules.map((e) => e.toJson()).toList(),
    };
  }
}
