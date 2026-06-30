class PageResponse<T> {
  const PageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.size,
    required this.first,
    required this.last,
  });

  final List<T> content;
  final int totalElements;
  final int totalPages;

  final int number;
  final int size;
  final bool first;
  final bool last;

  bool get isEmpty => content.isEmpty;
  bool get hasNext => !last;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) fromJsonT,
  ) {
    final rawContent = (json['content'] as List<dynamic>? ?? const []);
    return PageResponse<T>(
      content: rawContent
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      number: (json['number'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? rawContent.length,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
    );
  }
}
