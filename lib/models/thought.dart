class Thought {
  final String id;
  final String content;
  final String? tag;
  final bool isFavorite;
  final String? note;
  final String? imagePaths;
  final String? audioPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Thought({
    required this.id,
    required this.content,
    this.tag,
    this.isFavorite = false,
    this.note,
    this.imagePaths,
    this.audioPath,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  List<String> get imagePathList {
    if (imagePaths == null || imagePaths!.isEmpty) return [];
    return imagePaths!.split(',').where((p) => p.isNotEmpty).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'tag': tag,
      'is_favorite': isFavorite ? 1 : 0,
      'note': note,
      'image_paths': imagePaths,
      'audio_path': audioPath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Thought.fromMap(Map<String, dynamic> map) {
    return Thought(
      id: map['id'] as String,
      content: map['content'] as String,
      tag: map['tag'] as String?,
      isFavorite: (map['is_favorite'] as int?) == 1,
      note: map['note'] as String?,
      imagePaths: map['image_paths'] as String?,
      audioPath: map['audio_path'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Supabase 上传（不含图片/音频，使用 ISO 时间）
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'content': content,
      'tag': tag,
      'is_favorite': isFavorite,
      'note': note,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  // 从 Supabase 数据创建（ISO 时间格式）
  factory Thought.fromSupabaseMap(Map<String, dynamic> map) {
    return Thought(
      id: map['id'] as String,
      content: map['content'] as String,
      tag: map['tag'] as String?,
      isFavorite: (map['is_favorite'] as bool?) ?? false,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(map['updated_at'] as String).toLocal(),
    );
  }

  Thought copyWith({
    String? id,
    String? content,
    String? tag,
    bool? isFavorite,
    String? note,
    String? imagePaths,
    String? audioPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Thought(
      id: id ?? this.id,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      isFavorite: isFavorite ?? this.isFavorite,
      note: note ?? this.note,
      imagePaths: imagePaths ?? this.imagePaths,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
