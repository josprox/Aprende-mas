class SubmoduleImport {
  final String title;
  final String contentMd;

  const SubmoduleImport({required this.title, required this.contentMd});

  factory SubmoduleImport.fromJson(Map<String, dynamic> json) {
    return SubmoduleImport(
      title: json['title'] as String,
      contentMd: json['contentMd'] as String,
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
    return ModuleImport(
      title: json['title'] as String,
      shortDescription: json['shortDescription'] as String,
      submodules: (json['submodules'] as List<dynamic>)
          .map((e) => SubmoduleImport.fromJson(e as Map<String, dynamic>))
          .toList(),
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
    return SubjectImport(
      name: json['name'] as String,
      author: json['author'] as String,
      version: json['version'] as String,
      modules: (json['modules'] as List<dynamic>)
          .map((e) => ModuleImport.fromJson(e as Map<String, dynamic>))
          .toList(),
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
