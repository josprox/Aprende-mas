class RepositoryItem {
  String get storeKey => '${sourceUrl.isEmpty ? 'joss-red' : sourceUrl}|$id';
  final int id;
  final int userId;
  final String title;
  final String description;
  final String filePath;
  final String version;
  final int isOnline;
  final String author;
  final String? createdAt;
  final String? updatedAt;
  final String sourceName;
  final String sourceUrl;

  const RepositoryItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.filePath,
    required this.version,
    required this.isOnline,
    required this.author,
    this.createdAt,
    this.updatedAt,
    this.sourceName = 'Joss Red',
    this.sourceUrl = '',
  });

  factory RepositoryItem.fromJson(
    Map<String, dynamic> json, {
    String sourceName = 'Joss Red',
    String sourceUrl = '',
  }) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return RepositoryItem(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id'] ?? json['userId']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      filePath:
          json['file_path']?.toString() ?? json['filePath']?.toString() ?? '',
      version: json['version']?.toString() ?? '1.0',
      isOnline: parseInt(json['is_online'] ?? json['isOnline'] ?? 1),
      author: json['author']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      sourceName: sourceName,
      sourceUrl: sourceUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'file_path': filePath,
      'version': version,
      'is_online': isOnline,
      'author': author,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'source_name': sourceName,
      'source_url': sourceUrl,
    };
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 1;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 1;
    }

    final currentPage = parseInt(
      json['current_page'] ?? json['page'] ?? json['currentPage'],
    );
    final lastPage = parseInt(
      json['last_page'] ?? json['total_pages'] ?? json['lastPage'],
    );
    final perPage = parseInt(
      json['per_page'] ?? json['limit'] ?? json['perPage'],
    );
    final total = parseInt(
      json['total'] ?? json['total_count'] ?? json['totalCount'],
    );

    return PaginationMeta(
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: total,
      nextPageUrl: json['next_page_url']?.toString(),
      prevPageUrl: json['prev_page_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'next_page_url': nextPageUrl,
      'prev_page_url': prevPageUrl,
    };
  }
}

class RepositoryListResponse {
  final List<RepositoryItem> data;
  final PaginationMeta meta;

  const RepositoryListResponse({required this.data, required this.meta});

  factory RepositoryListResponse.fromJson(
    Map<String, dynamic> json, {
    String sourceName = 'Joss Red',
    String sourceUrl = '',
  }) {
    final rawData = json['data'] as List<dynamic>? ?? [];
    final items = rawData
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => RepositoryItem.fromJson(
            e,
            sourceName: sourceName,
            sourceUrl: sourceUrl,
          ),
        )
        .toList();

    final metaJson =
        (json['meta'] ?? json['pagination']) as Map<String, dynamic>? ?? {};

    return RepositoryListResponse(
      data: items,
      meta: PaginationMeta.fromJson(metaJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}
