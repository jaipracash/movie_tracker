class Poster {
  final String filePath;

  Poster({
    required this.filePath,
  });

  factory Poster.fromJson(Map<String, dynamic> json) {
    return Poster(
      filePath: json['file_path'],
    );
  }
}
