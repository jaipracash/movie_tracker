class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String? overView;
  final String? year;


  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.overView,
    required this.year,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? json['original_name'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overView: json['overview'],
      year: json['release_date']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'overview': overView,
      'year': year
    };
  }
}

class MovieResponse {
  final List<Movie> movies;

  MovieResponse({required this.movies});

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    var movieList = (json['results'] as List?)
        ?.map((movieJson) => Movie.fromJson(movieJson))
        .toList() ?? [];  // Ensure movieList is never null

    return MovieResponse(movies: movieList);
  }

}
