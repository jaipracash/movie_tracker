class OmdbMovieDetails {
  final String id;
  final String title;
  final String year;
  final String poster;
  final String runtime;
  final String released;
  final String plot;
  final String director;
  final String writer;
  final String language;
  final String country;
  final String genre;
  final String actors;
  final String imdbRating;
  final String rottenTomatoesRating;
  final String movieDbRating;

  OmdbMovieDetails({
    required this.id,
    required this.title,
    required this.year,
    required this.poster,
    required this.runtime,
    required this.released,
    required this.plot,
    required this.director,
    required this.writer,
    required this.language,
    required this.country,
    required this.genre,
    required this.actors,
    required this.imdbRating,
    required this.rottenTomatoesRating,
    required this.movieDbRating,
  });

  factory OmdbMovieDetails.fromJson(String id, Map<String, dynamic> json) {
    // Extract Rotten Tomatoes Rating
    String getRottenTomatoesRating(List<dynamic> ratings) {
      for (var rating in ratings) {
        if (rating['Source'] == 'Rotten Tomatoes') {
          return rating['Value'] ?? 'N/A';
        }
      }
      return 'N/A';
    }

    // Extract IMDb Rating
    String getMovieDbRating(List<dynamic> ratings) {
      for (var rating in ratings) {
        if (rating['Source'] == 'Internet Movie Database') {
          return rating['Value'] ?? 'N/A';
        }
      }
      return 'N/A';
    }

    return OmdbMovieDetails(
      id: id,
      title: json['Title'] ?? '',
      year: json['Year'] ?? '',
      poster: json['Poster'] ?? '',
      runtime: json['Runtime'] ?? '',
      released: json['Released'] ?? '',
      plot: json['Plot'] ?? '',
      director: json['Director'] ?? '',
      writer: json['Writer'] ?? '',
      language: json['Language'] ?? '',
      country: json['Country'] ?? '',
      genre: json['Genre'] ?? '',
      actors: json['Actors'] ?? '',
      imdbRating: json['imdbRating'] ?? '',
      rottenTomatoesRating: getRottenTomatoesRating(json['Ratings'] ?? []),
      movieDbRating: getMovieDbRating(json['Ratings'] ?? []),
    );
  }
}