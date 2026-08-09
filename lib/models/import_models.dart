class SubmoduleImport {
  final String title;
  final String contentMd;

  const SubmoduleImport({required this.title, required this.contentMd});

  factory SubmoduleImport.fromJson(Map<String, dynamic> json) {
    return SubmoduleImport(
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      contentMd: json['contentMd']?.toString() ??
          json['content_md']?.toString() ??
          json['content']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'contentMd': contentMd};
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
    final rawSubmodules = (json['submodules'] ?? json['items']) as List<dynamic>? ?? [];
    final submodulesList = rawSubmodules
        .whereType<Map<String, dynamic>>()
        .map((e) => SubmoduleImport.fromJson(e))
        .toList();

    return ModuleImport(
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      shortDescription: json['shortDescription']?.toString() ??
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
      'submodules': submodules.map((e) => e.toJson()).toList(),
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
    final rawModules = (json['modules'] ?? json['sections']) as List<dynamic>? ?? [];
    final modulesList = rawModules
        .whereType<Map<String, dynamic>>()
        .map((e) => ModuleImport.fromJson(e))
        .toList();

    return SubjectImport(
      name: json['name']?.toString() ?? json['title']?.toString() ?? 'Materia',
      author: json['author']?.toString() ?? 'Joss Red',
      version: json['version']?.toString() ?? '1.0',
      modules: modulesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'author': author,
      'version': version,
      'modules': modules.map((e) => e.toJson()).toList(),
    };
  }
}
