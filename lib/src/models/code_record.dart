class CodeRecord {
  const CodeRecord({
    required this.id,
    required this.data,
    required this.type,
    required this.createdAt,
    this.isFavorite = false,
  });

  final String id;
  final String data;
  final String type;
  final DateTime createdAt;
  final bool isFavorite;

  CodeRecord copyWith({bool? isFavorite}) {
    return CodeRecord(
      id: id,
      data: data,
      type: type,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'data': data,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory CodeRecord.fromJson(Map<String, dynamic> json) {
    return CodeRecord(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      data: json['data'] as String? ?? '',
      type: json['type'] as String? ?? 'QR',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  String get title {
    final value = data.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (value.length <= 34) return value;
    return '${value.substring(0, 31)}…';
  }
}
