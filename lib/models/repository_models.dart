class RepositoryItem {
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
  });

  factory RepositoryItem.fromJson(Map<String, dynamic> json) {
    return RepositoryItem(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      filePath: json['file_path'] as String,
      version: json['version'] as String,
      isOnline: json['is_online'] as int,
      author: json['author'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
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
    return PaginationMeta(
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      nextPageUrl: json['next_page_url'] as String?,
      prevPageUrl: json['prev_page_url'] as String?,
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

  factory RepositoryListResponse.fromJson(Map<String, dynamic> json) {
    return RepositoryListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => RepositoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}
