class MovieList {
  final int id;
  final String? title;
  final String? posterPath;


  MovieList({
    required this.id,
    required this.title,
    required this.posterPath,
  });

  factory MovieList.fromJson(Map<String, dynamic> json) {
    return MovieList(
      id: json['id'],
      title: json['title'] ?? ' ',
      posterPath: json['poster_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
    };
  }
}

class MovieResponse {
  final List<MovieList> movies;

  MovieResponse({required this.movies});

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    var movieList = (json['results'] as List)
        .map((movieJson) => MovieList.fromJson(movieJson))
        .toList();

    return MovieResponse(movies: movieList);
  }
}