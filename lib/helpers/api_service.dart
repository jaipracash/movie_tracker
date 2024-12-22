import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_tracker/models/poster_models.dart';
import 'package:movie_tracker/models/view_all_movie_model.dart';
import '../models/movie_list_model.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = 'e245e9ec8ac73a4f3fcbfbcd944f872d';


  static Future<Map<String, dynamic>> getPopularMovies({int page = 1, String language = 'en-US',}) async {
    const String endpoint = '/movie/popular';
    final Uri url = Uri.parse('$_baseUrl$endpoint?api_key=$_apiKey&language=$language&page=$page');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }


  static Future<Map<String, dynamic>> getUpcomingMovies({int page = 1, String language = 'en-US',}) async {
    const String endpoint = '/movie/upcoming';
    final Uri url = Uri.parse('$_baseUrl$endpoint?api_key=$_apiKey&language=$language&page=$page');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  static Future<List<Movie>> getTamilMovies({int page = 1, String language = 'ta'}) async {
    const String endpoint = '/discover/movie';
    final Uri url = Uri.parse(
        '$_baseUrl$endpoint?api_key=$_apiKey&with_original_language=$language&sort_by=popularity.desc&page=$page');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load Tamil movies');
      }
    } catch (e) {
      throw Exception('Failed to load Tamil movies: $e');
    }
  }


  static Future<List<MovieList>> getMoviesList({int page = 1, required String movieType}) async {
    String url;

    if (movieType == 'upcoming') {
      url = 'https://api.themoviedb.org/3/movie/upcoming?api_key=$_apiKey&language=en-US&page=$page';
    } else if (movieType == 'popular') {
      url = 'https://api.themoviedb.org/3/movie/popular?api_key=$_apiKey&language=en-US&page=$page';
    } else {
      throw Exception('Invalid movieType: $movieType');
    }

    print('Requesting URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<MovieList>.from(data['results'].map((item) => MovieList.fromJson(item)));
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  static Future<List<Poster>> getBackgroundImages({required String movieId}) async {
    String endpoint = '/movie/$movieId/images';
    final Uri url = Uri.parse('$_baseUrl$endpoint?api_key=$_apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> backdropJson = data['backdrops'];

        return backdropJson.map((json) => Poster.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load background images');
      }
    } catch (e) {
      print('Error fetching background images: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    final String endpoint = '/movie/$movieId';
    final Uri url = Uri.parse('$_baseUrl$endpoint?api_key=$_apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load movie details');
      }
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
  }
}
